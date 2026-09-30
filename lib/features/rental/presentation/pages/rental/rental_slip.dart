import 'package:flutter/material.dart';
import 'package:nyxproject/features/rental/domain/entities/RentalBooking.dart';
import 'package:nyxproject/features/dashboard/presentation/pages/main_dashboard.dart';
import 'package:nyxproject/features/cart/presentation/bloc/cart_service.dart';
import 'package:nyxproject/features/user/data/datasources/session_manager.dart';
import 'package:provider/provider.dart';

class rentalSlip extends StatefulWidget {
  final Map<String, dynamic>? bookingData;
  final String? paymentMethod;
  final String? transactionNumber;
  final RentalBooking? rentalBooking;
  final String? courtName;

  const rentalSlip({
    super.key,
    this.bookingData,
    this.paymentMethod,
    this.transactionNumber,
    this.rentalBooking,
    this.courtName,
  });

  @override
  State<rentalSlip> createState() => _rentalSlipState();
}

class _rentalSlipState extends State<rentalSlip> {
  String orderNo =
      "#" + DateTime.now().millisecondsSinceEpoch.toString().substring(8, 13);
  String date =
      DateTime.now().day.toString().padLeft(2, '0') +
      "/" +
      DateTime.now().month.toString().padLeft(2, '0') +
      "/" +
      DateTime.now().year.toString();
  String time =
      DateTime.now().hour.toString().padLeft(2, '0') +
      ":" +
      DateTime.now().minute.toString().padLeft(2, '0');

  List<RentalItem> _rentalItems = [];

  @override
  void initState() {
    super.initState();
    _extractRentalItems();
  }

  void _extractRentalItems() {
    final bookingData = widget.bookingData ?? {};

    // First try to get from API response model
    if (widget.rentalBooking != null &&
        widget.rentalBooking!.items.isNotEmpty) {
      _rentalItems = widget.rentalBooking!.items
          .where((item) => item.quantity != null && item.quantity! > 0)
          .toList();
    }

    // If no API items, use equipment from bookingData (local)
    if (_rentalItems.isEmpty) {
      final equipmentQuantities = bookingData['equipmentQuantities'] ?? {};
      final equipmentPrices = bookingData['equipmentPrices'] ?? {};

      for (var entry in equipmentQuantities.entries) {
        if (entry.value > 0) {
          // Safely convert to int
          int priceValue =
              int.tryParse(
                equipmentPrices[entry.key]?.split(' ')[0].replaceAll(',', '') ??
                    '0',
              ) ??
              0;
          int quantityValue = entry.value is int
              ? entry.value
              : (entry.value as num).toInt();

          _rentalItems.add(
            RentalItem(
              equipment: entry.key,
              quantity: quantityValue,
              price: priceValue,
              total: priceValue * quantityValue,
            ),
          );
        }
      }
    }
  }

  String _formatTime(String time) {
    if (time.isEmpty) return "";
    List<String> parts = time.split(':');
    int hour = int.parse(parts[0]);
    return "$hour:${parts[1]}";
  }

  @override
  Widget build(BuildContext context) {
    final bookingData = widget.bookingData ?? {};
    final paymentMethod = widget.paymentMethod ?? "N/A";
    final transactionNumber = widget.transactionNumber ?? "N/A";
    final rentalBooking = widget.rentalBooking;

    // Extract booking details
    String courtName =
        widget.courtName ??
        rentalBooking?.courtName ??
        bookingData['courtName']?.toString() ??
        'Court';
    String selectedDate = rentalBooking?.date ?? "";
    if (selectedDate.isEmpty && bookingData['selectedDate'] != null) {
      DateTime dateObj = bookingData['selectedDate'];
      selectedDate =
          "${dateObj.day.toString().padLeft(2, '0')}-${dateObj.month.toString().padLeft(2, '0')}-${dateObj.year}";
    } else if (selectedDate.isEmpty) {
      selectedDate = bookingData['date']?.toString() ?? date;
    }

    // Get time slot display - priority: API response > booking data
    String timeSlot = "";

    // Try to get from API response first
    if (rentalBooking != null && rentalBooking.items.isNotEmpty) {
      // If API has time slot info, you can extract it
      timeSlot = bookingData['timeSlotDisplay'] ?? "N/A";
    } else {
      // Get from booking data
      timeSlot =
          bookingData['timeSlotDisplay'] ??
          (bookingData['selectedTimeSlot'] != null
              ? "${_formatTime(bookingData['selectedTimeSlot'].startTime)} - ${_formatTime(bookingData['selectedTimeSlot'].endTime)}"
              : "N/A");
    }

    int sessions = bookingData['sessionCount'] ?? 1;
    double totalAmount =
        rentalBooking?.total?.toDouble() ??
        (bookingData['totalCharges'] is double
            ? bookingData['totalCharges']
            : (bookingData['totalCharges'] ?? 0).toDouble());

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 15),
              _voucher(
                courtName,
                selectedDate,
                timeSlot,
                sessions,
                totalAmount,
                paymentMethod,
                transactionNumber,
              ),
              const SizedBox(height: 15),
              _buttons(),
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
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
          ),
          const Expanded(
            child: Text(
              "Booking Confirmation",
              style: TextStyle(
                fontFamily: "Custom",
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _voucher(
    String courtName,
    String selectedDate,
    String timeSlot,
    int sessions,
    double totalAmount,
    String paymentMethod,
    String transactionNumber,
  ) {
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
              "Booking Placed Successfully!",
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
              "Thank you for booking with us.",
              style: TextStyle(
                fontFamily: "Custom",
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _infoRow("Booking No :", orderNo),
          const SizedBox(height: 8),
          _infoRow("Date :", date),
          const SizedBox(height: 8),
          _infoRow("Time :", time),
          const SizedBox(height: 8),
          _infoRow("Court :", courtName),
          const SizedBox(height: 8),
          _infoRow("Booking Date :", selectedDate),
          const SizedBox(height: 8),
          _infoRow("Time Slot :", timeSlot),
          const SizedBox(height: 8),
          _infoRow("Sessions :", "$sessions session${sessions > 1 ? 's' : ''}"),
          const SizedBox(height: 15),
          if (_rentalItems.isNotEmpty) ...[
            const Divider(color: Colors.white54),
            const SizedBox(height: 10),
            const Text(
              "Rental Equipment",
              style: TextStyle(
                fontFamily: "Custom",
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _rentalHeader(),
            ..._rentalItems.map((item) => _rentalItemRow(item)),
            const SizedBox(height: 10),
          ],
          const Divider(color: Colors.white54),
          const SizedBox(height: 10),
          _infoRow("Payment Method :", paymentMethod),
          if (transactionNumber.isNotEmpty && transactionNumber != "N/A")
            _infoRow("Transaction No :", transactionNumber),
          const SizedBox(height: 15),
          const Divider(color: Colors.white54),
          const SizedBox(height: 10),
          _priceRow(
            "Total Amount :",
            "${totalAmount.toStringAsFixed(0)} Ks",
            isBold: true,
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _rentalHeader() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "Equipment",
              style: TextStyle(
                fontFamily: "Custom",
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 45),
          Text(
            "Qty",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: "Custom",
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 80),
          Text(
            "Price",
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: "Custom",
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rentalItemRow(RentalItem item) {
    int priceValue = item.price ?? 0;
    int quantity = item.quantity ?? 0;
    int totalPrice = item.total ?? (priceValue * quantity);

    if (quantity == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              item.equipment ?? 'Unknown',
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
              quantity.toString(),
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
              "$totalPrice Ks",
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
              color: isBold
                  ? const Color.fromARGB(255, 51, 252, 57)
                  : Colors.white,
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
                final sessionService = Provider.of<SessionService>(
                  context,
                  listen: false,
                );
                final cartService = Provider.of<CartService>(
                  context,
                  listen: false,
                );

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
              icon: const Icon(Icons.receipt, size: 22),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Booking confirmed!"),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              label: const Text(
                "View Receipt",
                style: TextStyle(
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
