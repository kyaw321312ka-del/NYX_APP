import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nyxproject/features/orders/data/datasources/OrderApi.dart';
import 'package:nyxproject/features/user/data/datasources/session_manager.dart';
import 'package:nyxproject/features/cart/presentation/bloc/cart_service.dart';
import 'package:nyxproject/features/shop/presentation/pages/shoppages/slip.dart';
import 'package:nyxproject/features/user/presentation/pages/login.dart';

class orderHistory extends StatefulWidget {
  const orderHistory({super.key});

  @override
  State<orderHistory> createState() => _orderHistoryState();
}

class _orderHistoryState extends State<orderHistory> {
  final List<String> statusFilter = [
    "All",
    "Pending",
    "Completed",
    "Cancel",
  ];

  String _selectedStatus = "All";
  List<dynamic> _allOrders = [];
  List<dynamic> _filteredOrders = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  void _redirectToLogin() async {
    final sessionService = Provider.of<SessionService>(context, listen: false);
    final cartService = Provider.of<CartService>(context, listen: false);
    await sessionService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(
            sessionService: sessionService,
            cartService: cartService,
          ),
        ),
        (route) => false,
      );
    }
  }

  Future<void> _fetchOrders() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final sessionService = Provider.of<SessionService>(context, listen: false);
      final user = sessionService.getStoredUser();
      final userId = user?.id ?? 0;
      final token = sessionService.getToken();

      if (userId == 0) {
        _redirectToLogin();
        return;
      }

      final result = await OrderApi.fetchOrders(userId: userId, token: token);

      if (!mounted) return;

      if (result['unauthorized'] == true) {
        _redirectToLogin();
        return;
      }

      if (result['success']) {
        setState(() {
          _allOrders = result['data'] ?? [];
          _applyFilter();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to load orders';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    if (_selectedStatus == "All") {
      _filteredOrders = List.from(_allOrders);
    } else {
      _filteredOrders = _allOrders.where((order) {
        final orderStatus = order['order_status']?.toString().toLowerCase() ?? '';
        return orderStatus == _selectedStatus.toLowerCase();
      }).toList();
    }
    setState(() {});
  }

  void _changeFilter(String status) {
    setState(() {
      _selectedStatus = status;
    });
    _applyFilter();
  }

  String _formatDate(String? dateTimeString) {
    if (dateTimeString == null) return 'N/A';
    try {
      return dateTimeString;
    } catch (e) {
      return dateTimeString;
    }
  }

  String _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'green';
      case 'pending':
        return 'orange';
      case 'cancelled':
      case 'cancel':
        return 'red';
      default:
        return 'grey';
    }
  }

  void _navigateToSlipPage(Map<String, dynamic> order) {
    final paymentMethod = order['payment_method']?.toString() ?? 'Cash on Delivery';
    final total = order['Total'] ?? 0;

    final contactInfo = <String, String>{
      'name': order['customer_name']?.toString() ?? 'N/A',
      'phone': order['phone']?.toString() ?? 'N/A',
      'email': order['email']?.toString() ?? 'N/A',
      'address': order['delivery_address']?.toString() ?? 'N/A',
      'remark': order['remark']?.toString() ?? '',
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => slipPage(
          paymentMethod: paymentMethod,
          transactionNumber: order['transaction_number']?.toString(),
          totalAmount: total is int ? total.toDouble() : (total as double? ?? 0.0),
          contactInfo: contactInfo,
          orderResponse: order,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            const SizedBox(height: 10),
            _filterBar(),
            const SizedBox(height: 10),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading orders...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchOrders,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_selectedStatus == "All" 
                ? 'No orders found' 
                : 'No $_selectedStatus orders found'),
            const SizedBox(height: 8),
            const Text(
              'Your order history will appear here',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _filteredOrders.length,
      itemBuilder: (context, index) {
        final order = _filteredOrders[index];
        final orderId = order['order_id']?.toString() ?? '#${index + 1}';
        final date = _formatDate(order['Date']);
        final total = order['Total']?.toString() ?? '0';
        final itemCount = order['items']?.length ?? 0;
        final orderStatus = order['order_status']?.toString() ?? 'pending';
        final statusColor = _getStatusColor(orderStatus);
        
        return _orderCard(
          orderId: orderId,
          date: date,
          total: total,
          itemCount: itemCount,
          status: orderStatus,
          statusColor: statusColor,
          onTap: () => _navigateToSlipPage(order),
        );
      },
    );
  }

  Widget _header() {
    return Container(
      color: const Color.fromARGB(255, 13, 27, 42),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          ),
          const Expanded(
            child: Text(
              "Orders History",
              style: TextStyle(
                fontFamily: "Custom",
                color: Colors.white,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _filterBar() {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: statusFilter.length,
        itemBuilder: (context, index) {
          final status = statusFilter[index];
          final isSelected = status == _selectedStatus;

          return GestureDetector(
            onTap: () => _changeFilter(status),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF0D1B2A)
                    : Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  status,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _orderCard({
    required String orderId,
    required String date,
    required String total,
    required int itemCount,
    required String status,
    required String statusColor,
    required VoidCallback onTap,
  }) {
    Color color;
    switch (statusColor) {
      case 'green':
        color = Colors.green;
        break;
      case 'orange':
        color = Colors.orange;
        break;
      case 'red':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF0D1B2A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.receipt_long, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Order #$orderId",
                        style: const TextStyle(
                          fontFamily: "Custom",
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status[0].toUpperCase() + status.substring(1),
                          style: TextStyle(
                            fontFamily: "Custom",
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: const TextStyle(
                          fontFamily: "Custom",
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.shopping_bag, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '$itemCount items',
                        style: const TextStyle(
                          fontFamily: "Custom",
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total: $total Ks',
                    style: const TextStyle(
                      fontFamily: "Custom",
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}