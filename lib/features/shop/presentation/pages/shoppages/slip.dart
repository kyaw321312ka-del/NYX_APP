import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:nyxproject/features/dashboard/presentation/pages/main_dashboard.dart';
import 'package:nyxproject/features/cart/presentation/bloc/cart_service.dart';
import 'package:nyxproject/features/user/data/datasources/session_manager.dart';
import 'package:provider/provider.dart';

class slipPage extends StatefulWidget {
  final String? paymentMethod;
  final String? transactionNumber;
  final double? totalAmount;
  final List<CartItem>? cartItems;
  final Map<String, String>? contactInfo;
  final Map<String, dynamic>? orderResponse;
  final double? taxRate;
  final double? taxAmount;
  final double? subTotal;

  const slipPage({
    super.key,
    this.paymentMethod,
    this.transactionNumber,
    this.totalAmount,
    this.cartItems,
    this.contactInfo,
    this.orderResponse,
    this.taxRate,
    this.taxAmount,
    this.subTotal,
  });

  @override
  State<slipPage> createState() => _slipPageState();
}

class _slipPageState extends State<slipPage> {
  final GlobalKey _repaintKey = GlobalKey();
  bool _isSharing = false;
  
  String _orderNo = "";
  String date = DateTime.now().day.toString().padLeft(2, '0') + "/" +
      DateTime.now().month.toString().padLeft(2, '0') + "/" +
      DateTime.now().year.toString();
  String time = DateTime.now().hour.toString().padLeft(2, '0') + ":" +
      DateTime.now().minute.toString().padLeft(2, '0');

  double subTotal = 0;
  double tax = 0;
  double deliveryFee = 0;
  double total = 0;
  double taxRate = 5;

  @override
  void initState() {
    super.initState();
    _calculateTotals();
    _getOrderNumber();
  }

  void _getOrderNumber() {
    // Try to get order_id from orderResponse
    if (widget.orderResponse != null) {
      // Check different possible paths for order_id
      if (widget.orderResponse!.containsKey('data')) {
        final data = widget.orderResponse!['data'];
        if (data is List && data.isNotEmpty) {
          _orderNo = data[0]['order_id']?.toString() ?? 
                     data[0]['id']?.toString() ?? 
                     "#${DateTime.now().millisecondsSinceEpoch.toString().substring(8, 13)}";
        } else if (data is Map<String, dynamic>) {
          _orderNo = data['order_id']?.toString() ?? 
                     data['id']?.toString() ?? 
                     "#${DateTime.now().millisecondsSinceEpoch.toString().substring(8, 13)}";
        }
      } else if (widget.orderResponse!.containsKey('order_id')) {
        _orderNo = widget.orderResponse!['order_id'].toString();
      } else if (widget.orderResponse!.containsKey('id')) {
        _orderNo = widget.orderResponse!['id'].toString();
      } else {
        _orderNo = "#${DateTime.now().millisecondsSinceEpoch.toString().substring(8, 13)}";
      }
    } else {
      _orderNo = "#${DateTime.now().millisecondsSinceEpoch.toString().substring(8, 13)}";
    }
  }

  void _calculateTotals() {
    // FIRST PRIORITY: Use values passed from Payment page
    if (widget.subTotal != null && widget.subTotal! > 0) {
      subTotal = widget.subTotal!;
    }
    
    if (widget.taxAmount != null && widget.taxAmount! > 0) {
      tax = widget.taxAmount!;
    }
    
    if (widget.taxRate != null && widget.taxRate! > 0) {
      taxRate = widget.taxRate!;
    }
    
    if (widget.totalAmount != null && widget.totalAmount! > 0) {
      total = widget.totalAmount!;
    }
    
    // Calculate missing values if needed
    if (subTotal > 0 && tax == 0 && taxRate > 0) {
      tax = subTotal * (taxRate / 100);
    }
    
    if (subTotal > 0 && tax > 0 && total == 0) {
      total = subTotal + tax + deliveryFee;
    }
    
    if (subTotal == 0 && total > 0 && taxRate > 0) {
      subTotal = total / (1 + taxRate / 100);
      tax = total - subTotal;
    }
    
    // SECOND PRIORITY: Use orderResponse values
    if (widget.orderResponse != null && subTotal == 0) {
      final orderData = widget.orderResponse!['data'];
      if (orderData is List && orderData.isNotEmpty) {
        subTotal = (orderData[0]['subtotal'] ?? orderData[0]['Sub_total'] ?? 0).toDouble();
        tax = (orderData[0]['tax'] ?? 0).toDouble();
        deliveryFee = (orderData[0]['delivery_fee'] ?? 0).toDouble();
        total = (orderData[0]['total'] ?? orderData[0]['Total'] ?? 0).toDouble();
        
        if (tax > 0 && subTotal > 0) {
          taxRate = (tax / subTotal) * 100;
        }
        return;
      } else if (orderData is Map<String, dynamic>) {
        subTotal = (orderData['subtotal'] ?? orderData['Sub_total'] ?? 0).toDouble();
        tax = (orderData['tax'] ?? 0).toDouble();
        deliveryFee = (orderData['delivery_fee'] ?? 0).toDouble();
        total = (orderData['total'] ?? orderData['Total'] ?? 0).toDouble();
        
        if (tax > 0 && subTotal > 0) {
          taxRate = (tax / subTotal) * 100;
        }
        return;
      }
    }
    
    // LAST RESORT: Calculate from cartItems
    if (widget.cartItems != null && widget.cartItems!.isNotEmpty && subTotal == 0) {
      subTotal = widget.cartItems!.fold(
        0,
        (sum, item) => sum + (item.product.price * item.quantity),
      );
      if (taxRate > 0) {
        tax = subTotal * (taxRate / 100);
      } else {
        tax = subTotal * 0.05;
      }
      total = subTotal + tax + deliveryFee;
    }
  }

  Future<void> _shareReceipt() async {
    setState(() {
      _isSharing = true;
    });
    
    try {
      RenderRepaintBoundary boundary = _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      
      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/receipt_${DateTime.now().millisecondsSinceEpoch}.png').create();
      await imagePath.writeAsBytes(pngBytes);
      
      await Share.shareXFiles(
        [XFile(imagePath.path)],
        text: "Order Receipt #$_orderNo\nTotal: ${total.toStringAsFixed(0)} Ks",
        subject: "Order Receipt",
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Receipt shared successfully!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error sharing receipt: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  @override
 @override
Widget build(BuildContext context) {
  final orderNumber = _orderNo.isNotEmpty 
      ? _orderNo 
      : widget.orderResponse?['order_number'] ?? 
        widget.orderResponse?['data']?[0]?['order_id']?.toString() ??
        "#${DateTime.now().millisecondsSinceEpoch.toString().substring(8, 13)}";
        
  final orderDate = widget.orderResponse?['order_date'] ?? 
                    widget.orderResponse?['data']?[0]?['create_at'] != null
                        ? _formatDate(widget.orderResponse!['data'][0]['create_at'])
                        : date;
  final orderTime = widget.orderResponse?['order_time'] ?? time;

  return Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 15),
            RepaintBoundary(
              key: _repaintKey,
              child: _voucher(orderNumber, orderDate, orderTime),
            ),
            const SizedBox(height: 15),
            _buttons(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
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
              "Order Confirmation",
              style: TextStyle(
                fontFamily: "Custom",
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateTimeString) {
    if (dateTimeString == null) return date;
    try {
      final dateObj = DateTime.parse(dateTimeString);
      return '${dateObj.day.toString().padLeft(2, '0')}/${dateObj.month.toString().padLeft(2, '0')}/${dateObj.year}';
    } catch (e) {
      return date;
    }
  }

  Widget _voucher(String orderNumber, String orderDate, String orderTime) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 13, 27, 42),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          const Center(
            child: Text(
              "Order Placed Successfully!",
              style: TextStyle(
                fontFamily: "Custom",
                color: Color.fromARGB(255, 51, 252, 57),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 5),
          const Center(
            child: Text(
              "Thank you for shopping with us.",
              style: TextStyle(
                fontFamily: "Custom",
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (widget.contactInfo != null) ...[
            _infoRow("Name:", widget.contactInfo!['name'] ?? 'N/A'),
            const SizedBox(height: 8),
            _infoRow("Phone:", widget.contactInfo!['phone'] ?? 'N/A'),
            const SizedBox(height: 8),
            _infoRow("Email:", widget.contactInfo!['email'] ?? 'N/A'),
            const SizedBox(height: 8),
            _infoRow("Address:", widget.contactInfo!['address'] ?? 'N/A'),
            const SizedBox(height: 15),
            const Divider(color: Colors.white54),
            const SizedBox(height: 10),
          ],
          _infoRow("Order No :", orderNumber),
          const SizedBox(height: 8),
          _infoRow("Date :", orderDate),
          const SizedBox(height: 8),
          _infoRow("Time :", orderTime),
          const SizedBox(height: 8),
          _infoRow("Payment :", widget.paymentMethod ?? "Cash on Delivery"),
          if (widget.transactionNumber != null && widget.transactionNumber!.isNotEmpty)
            _infoRow("Transaction No :", widget.transactionNumber!),
          const SizedBox(height: 15),
          const Divider(color: Colors.white54),
          const SizedBox(height: 10),
          const Text(
            "Order Items",
            style: TextStyle(
              fontFamily: "Custom",
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _productHeader(),
          const SizedBox(height: 5),
          _productList(),
          const SizedBox(height: 10),
          const Divider(color: Colors.white54),
          const SizedBox(height: 10),
          _priceRow("Sub Total :", "${subTotal.toStringAsFixed(0)} Ks"),
          _priceRow("Tax (${taxRate.toStringAsFixed(0)}%) :", "${tax.toStringAsFixed(0)} Ks"),
          if (deliveryFee > 0) 
            _priceRow("Delivery Fee :", "${deliveryFee.toStringAsFixed(0)} Ks"),
          const SizedBox(height: 8),
          const Divider(color: Colors.white54),
          _priceRow("Total :", "${total.toStringAsFixed(0)} Ks", isBold: true),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: "Custom",
            color: Colors.white70,
            fontSize: 15,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontFamily: "Custom",
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _productHeader() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "Product",
              style: TextStyle(
                fontFamily: "Custom",
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: 45,
            child: Text(
              "Qty",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "Custom",
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              "Price",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: "Custom",
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _productList() {
    if (widget.cartItems != null && widget.cartItems!.isNotEmpty) {
      return Column(
        children: widget.cartItems!.map((item) {
          return _productRow(
            item.product.productName,
            item.quantity.toString(),
            (item.product.price * item.quantity).toStringAsFixed(0),
          );
        }).toList(),
      );
    }
    
    if (widget.orderResponse != null) {
      List<dynamic> itemsList = [];
      
      if (widget.orderResponse!.containsKey('data')) {
        final data = widget.orderResponse!['data'];
        if (data is List && data.isNotEmpty) {
          itemsList = data[0]['items'] ?? data[0]['order_items'] ?? [];
        } else if (data is Map<String, dynamic>) {
          itemsList = data['items'] ?? data['order_items'] ?? [];
        }
      } else if (widget.orderResponse!.containsKey('items')) {
        itemsList = widget.orderResponse!['items'] ?? [];
      } else if (widget.orderResponse!.containsKey('order_items')) {
        itemsList = widget.orderResponse!['order_items'] ?? [];
      }
      
      if (itemsList.isNotEmpty) {
        return Column(
          children: itemsList.map((item) {
            final productName = item['product_name']?.toString() ?? 
                               item['name']?.toString() ?? 
                               'Unknown';
            final quantity = item['quantity']?.toString() ?? '0';
            final price = item['total']?.toString() ?? 
                         (item['price'] != null 
                             ? (double.parse(item['price'].toString()) * int.parse(quantity)).toStringAsFixed(0)
                             : '0');
            return _productRow(productName, quantity, price);
          }).toList(),
        );
      }
    }
    
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Text(
          "No items found",
          style: TextStyle(
            fontFamily: "Custom",
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _productRow(String name, String qty, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              name,
              style: const TextStyle(
                fontFamily: "Custom",
                color: Colors.white,
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 45,
            child: Text(
              qty,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: "Custom",
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              "$price Ks",
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: "Custom",
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: "Custom",
              color: isBold ? Colors.white : Colors.white70,
              fontSize: isBold ? 16 : 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontFamily: "Custom",
              color: isBold ? const Color.fromARGB(255, 51, 252, 57) : Colors.white,
              fontSize: isBold ? 18 : 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buttons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 13, 27, 42),
                iconColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: const Icon(Icons.home, size: 22),
              onPressed: () {
                final sessionService = Provider.of<SessionService>(context, listen: false);
                final cartService = Provider.of<CartService>(context, listen: false);
                
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainDashboard(
                      sessionService: sessionService,
                      cartService: cartService,
                    ),
                  ),
                  (route) => false,
                );
              },
              label: const Text(
                "Home",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Custom',
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                iconColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: _isSharing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.share, size: 22),
              onPressed: _isSharing ? null : _shareReceipt,
              label: Text(
                _isSharing ? "Sharing..." : "Share Receipt",
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Custom',
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}