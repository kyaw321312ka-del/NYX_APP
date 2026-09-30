import 'package:flutter/material.dart';
import 'package:nyxproject/features/rental/data/datasources/RentelApi/BookingOrderListApi.dart';
import 'package:nyxproject/features/rental/domain/entities/BookingOrderList.dart';
import 'package:nyxproject/features/user/data/datasources/session_manager.dart';
import 'package:nyxproject/features/cart/presentation/bloc/cart_service.dart';
import 'package:provider/provider.dart';
import 'package:nyxproject/features/user/presentation/pages/login.dart';

class myBookingList extends StatefulWidget {
  const myBookingList({super.key});

  @override
  State<myBookingList> createState() => _myBookingListState();
}

class _myBookingListState extends State<myBookingList> {
  final List<String> statusFilter = [
    "All",
    "Pending",
    "Completed",
    "Cancel",
  ];

  String _selectedStatus = "All";
  List<BookingOrder> _allBookings = [];
  List<BookingOrder> _filteredBookings = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
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

  Future<void> _fetchBookings() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final sessionService = Provider.of<SessionService>(context, listen: false);
      final token = sessionService.getToken();

      if (token == null) {
        _redirectToLogin();
        return;
      }

      final result = await BookingOrderListApi.getMobileBookings(token: token);

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          _allBookings = result['data'] ?? [];
          _applyFilter();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to load bookings';
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
      _filteredBookings = List.from(_allBookings);
    } else {
      // For now, since API doesn't have status, show all or filter based on some logic
      // You can add status field to your BookingOrder model later
      _filteredBookings = List.from(_allBookings);
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
    if (dateTimeString == null || dateTimeString.isEmpty) return 'N/A';
    try {
      List<String> parts = dateTimeString.split(' ');
      if (parts.isNotEmpty) {
        return parts[0];
      }
      return dateTimeString;
    } catch (e) {
      return dateTimeString;
    }
  }

  void _navigateToBookingDetails(BookingOrder booking) {
    _showBookingDetailsDialog(booking);
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
            Text('Loading bookings...'),
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
              onPressed: _fetchBookings,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_selectedStatus == "All" 
                ? 'No bookings found' 
                : 'No $_selectedStatus bookings found'),
            const SizedBox(height: 8),
            const Text(
              'Your booking history will appear here',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _filteredBookings.length,
      itemBuilder: (context, index) {
        final booking = _filteredBookings[index];
        final bookingId = booking.id.toString();
        final date = _formatDate(booking.date);
        final total = booking.total.toString();
        final itemCount = booking.items.length;
        // Status can be added later to the model
        final status = "Completed";
        
        return _bookingCard(
          bookingId: bookingId,
          date: date,
          total: total,
          itemCount: itemCount,
          status: status,
          onTap: () => _navigateToBookingDetails(booking),
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
              "My Bookings",
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

  Widget _bookingCard({
    required String bookingId,
    required String date,
    required String total,
    required int itemCount,
    required String status,
    required VoidCallback onTap,
  }) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'cancel':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
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
              child: const Icon(Icons.sports, color: Colors.white, size: 28),
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
                        "Booking #$bookingId",
                        style: const TextStyle(
                          fontFamily: "Custom",
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontFamily: "Custom",
                            color: statusColor,
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
                      const Icon(Icons.sports, size: 12, color: Colors.grey),
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

  void _showBookingDetailsDialog(BookingOrder booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Booking #${booking.id}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow("Court", booking.courtName),
              _detailRow("Date", booking.date),
              _detailRow("Booked On", _formatDate(booking.createAt)),
              _detailRow("Payment Method", booking.paymentMethod),
              _detailRow("Customer", booking.customer),
              const Divider(),
              const Text("Rental Items", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...booking.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${item.equipment ?? 'Item'} x ${item.quantity ?? 0}"),
                    Text("${(item.total ?? 0).toString()} Ks"),
                  ],
                ),
              )),
              const Divider(),
              _detailRow("Court Fee", "${booking.courtFee} Ks"),
              _detailRow("Total", "${booking.total} Ks", isBold: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }
}