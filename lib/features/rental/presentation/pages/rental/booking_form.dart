import 'package:flutter/material.dart';
import 'package:nyxproject/features/rental/presentation/pages/rental/rental_payment.dart';
import 'package:nyxproject/features/user/data/datasources/session_manager.dart';
import 'package:provider/provider.dart';

class bookingForm extends StatefulWidget {
  final Map<String, dynamic>? bookingData;

  const bookingForm({super.key, this.bookingData});

  @override
  State<bookingForm> createState() => _bookingFormState();
}

class _bookingFormState extends State<bookingForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  String? Court;
  String? TimeSlot;
  double sessionPrice = 0;
  double courtFee = 0;
  double rentalFees = 0;
  double totalCharges = 0;
  String selectedCourtName = "";
  String selectedTimeSlotDisplay = "";
  String selectedDateDisplay = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadBookingData();
    calculateTotal();
  }

  void _loadBookingData() {
    if (widget.bookingData != null) {
      setState(() {
        selectedCourtName = widget.bookingData!['courtName'] ?? "";
        sessionPrice = widget.bookingData!['sessionPrice'] ?? 0;
        courtFee = widget.bookingData!['courtPrice'] ?? sessionPrice;
        totalCharges = widget.bookingData!['totalCharges'] ?? 0;

        // Format date
        DateTime? date = widget.bookingData!['selectedDate'];
        if (date != null) {
          selectedDateDisplay =
              "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
          dobController.text = selectedDateDisplay;
        }

        // Format time slot
        var timeSlot = widget.bookingData!['selectedTimeSlot'];
        if (timeSlot != null) {
          selectedTimeSlotDisplay =
              "${_formatTime(timeSlot.startTime)} - ${_formatTime(timeSlot.endTime)}";
          TimeSlot = selectedTimeSlotDisplay;
        }

        // Load equipment quantities
        var equipment = widget.bookingData!['equipmentQuantities'];
        if (equipment != null && equipment.isNotEmpty) {
          // Calculate rental fees
          var prices = widget.bookingData!['equipmentPrices'];
          for (var entry in equipment.entries) {
            if (entry.value > 0) {
              String priceStr = prices[entry.key] ?? "0 Ks/hour";
              int price = int.tryParse(priceStr.split(' ')[0]) ?? 0;
              rentalFees += price * entry.value;
            }
          }
        }
      });
    }
  }

  String _formatTime(String time) {
    if (time.isEmpty) return "";
    List<String> parts = time.split(':');
    int hour = int.parse(parts[0]);
    return "$hour:${parts[1]}";
  }

  void _loadUserData() {
    final sessionService = Provider.of<SessionService>(context, listen: false);
    final user = sessionService.getStoredUser();

    if (user != null) {
      nameController.text = user.name ?? '';
      phoneController.text = user.phone ?? '';
    }
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        dobController.text =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void calculateTotal() {
    setState(() {
      totalCharges = sessionPrice + rentalFees;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    remarkController.dispose();
    dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(screenWidth, screenHeight),
              SizedBox(height: screenHeight * 0.02),
              _formInput1(
                "Name",
                "Enter your name",
                nameController,
                screenWidth,
                screenHeight,
              ),
              SizedBox(height: screenHeight * 0.015),
              _formInput1(
                "Phone Number",
                "09 xxx xxx xxx",
                phoneController,
                screenWidth,
                screenHeight,
              ),
              SizedBox(height: screenHeight * 0.015),
              _displaySelectedCourt(screenWidth, screenHeight),
              SizedBox(height: screenHeight * 0.015),
              _dateInput(screenWidth, screenHeight),
              SizedBox(height: screenHeight * 0.015),
              _displaySelectedTimeSlot(screenWidth, screenHeight),
              SizedBox(height: screenHeight * 0.015),
              _formInput1(
                "Court Fee (per hour)",
                "Auto Fill",
                null,
                screenWidth,
                screenHeight,
                value: "${courtFee.toStringAsFixed(0)} Ks",
                enabled: false,
              ),
              SizedBox(height: screenHeight * 0.015),
              _formInput1(
                "Rental Fees",
                "Auto Fill",
                null,
                screenWidth,
                screenHeight,
                value: "$rentalFees Ks",
                enabled: false,
              ),
              SizedBox(height: screenHeight * 0.015),
              _formInput1(
                "Total Charges (MMK)",
                "Auto Fill",
                null,
                screenWidth,
                screenHeight,
                value: "${totalCharges.toStringAsFixed(0)} Ks",
                enabled: false,
              ),
              SizedBox(height: screenHeight * 0.015),
              _formInput2(
                "Remark",
                "Write remark",
                remarkController,
                screenWidth,
                screenHeight,
              ),
              SizedBox(height: screenHeight * 0.03),
              _confirm(screenWidth, screenHeight),
              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  Widget _displaySelectedCourt(double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Selected Court",
            style: TextStyle(
              color: const Color.fromARGB(255, 13, 27, 42),
              fontWeight: FontWeight.w500,
              fontFamily: 'Custom',
              fontSize: screenWidth * 0.045,
            ),
          ),
          SizedBox(height: screenHeight * 0.008),
          Container(
            height: screenHeight * 0.06,
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 13, 27, 42),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                selectedCourtName,
                style: TextStyle(
                  fontFamily: "Custom",
                  color: Colors.white,
                  fontSize: screenWidth * 0.04,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _displaySelectedTimeSlot(double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Selected Time Slot",
            style: TextStyle(
              color: const Color.fromARGB(255, 13, 27, 42),
              fontWeight: FontWeight.w500,
              fontFamily: 'Custom',
              fontSize: screenWidth * 0.045,
            ),
          ),
          SizedBox(height: screenHeight * 0.008),
          Container(
            height: screenHeight * 0.06,
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 13, 27, 42),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                TimeSlot ?? "Not selected",
                style: TextStyle(
                  fontFamily: "Custom",
                  color: Colors.white,
                  fontSize: screenWidth * 0.04,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(double screenWidth, double screenHeight) {
    return Container(
      color: const Color.fromARGB(255, 13, 27, 42),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.02,
        vertical: screenHeight * 0.01,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: screenWidth * 0.055,
            ),
          ),
          SizedBox(width: screenWidth * 0.05),
          Text(
            "BOOKING FORM",
            style: TextStyle(
              fontFamily: "Custom",
              color: Colors.white,
              fontSize: screenWidth * 0.055,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _formInput1(
    String title,
    String hint,
    TextEditingController? controller,
    double screenWidth,
    double screenHeight, {
    String? value,
    bool enabled = true,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: const Color.fromARGB(255, 13, 27, 42),
              fontWeight: FontWeight.w500,
              fontFamily: 'Custom',
              fontSize: screenWidth * 0.045,
            ),
          ),
          SizedBox(height: screenHeight * 0.008),
          Container(
            height: screenHeight * 0.06,
            child: TextFormField(
              controller: controller,
              enabled: enabled,
              style: TextStyle(
                fontFamily: "Custom",
                color: Colors.white,
                fontSize: screenWidth * 0.04,
              ),
              decoration: InputDecoration(
                hintText: value ?? hint,
                hintStyle: TextStyle(
                  fontSize: screenWidth * 0.035,
                  color: Colors.grey.shade400,
                ),
                filled: true,
                fillColor: const Color.fromARGB(255, 13, 27, 42),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _formInput2(
    String title,
    String hint,
    TextEditingController controller,
    double screenWidth,
    double screenHeight,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: const Color.fromARGB(255, 13, 27, 42),
              fontWeight: FontWeight.w500,
              fontFamily: 'Custom',
              fontSize: screenWidth * 0.045,
            ),
          ),
          SizedBox(height: screenHeight * 0.008),
          Container(
            height: screenHeight * 0.12,
            child: TextFormField(
              controller: controller,
              maxLines: 3,
              style: TextStyle(
                fontFamily: "Custom",
                color: Colors.white,
                fontSize: screenWidth * 0.04,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  fontSize: screenWidth * 0.035,
                  color: Colors.grey.shade400,
                ),
                filled: true,
                fillColor: const Color.fromARGB(255, 13, 27, 42),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _input(
    String text,
    double screenWidth,
    double screenHeight, {
    bool enabled = true,
  }) {
    return Container(
      height: screenHeight * 0.06,
      child: TextFormField(
        enabled: enabled,
        initialValue: text,
        style: TextStyle(
          fontFamily: "Custom",
          color: Colors.white,
          fontSize: screenWidth * 0.04,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color.fromARGB(255, 13, 27, 42),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _dateInput(double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Booking Date",
            style: TextStyle(
              color: const Color.fromARGB(255, 13, 27, 42),
              fontWeight: FontWeight.w500,
              fontFamily: 'Custom',
              fontSize: screenWidth * 0.045,
            ),
          ),
          SizedBox(height: screenHeight * 0.008),
          Container(
            height: screenHeight * 0.06,
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 13, 27, 42),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                dobController.text.isEmpty ? "Select date" : dobController.text,
                style: TextStyle(
                  fontFamily: "Custom",
                  color: dobController.text.isEmpty
                      ? Colors.grey.shade400
                      : Colors.white,
                  fontSize: screenWidth * 0.04,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _selection2(String main, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
      child: Text(
        main,
        style: TextStyle(
          fontFamily: "Custom",
          color: const Color.fromARGB(255, 13, 27, 42),
          fontSize: screenWidth * 0.04,
        ),
      ),
    );
  }

  Widget _confirm(double screenWidth, double screenHeight) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.1,
            vertical: screenHeight * 0.015,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: () {
          // Prepare updated booking data
          
          final updatedBookingData = {
            'courtName': selectedCourtName,
            'courtPrice': courtFee,
            'sessionPrice': sessionPrice,
            'selectedDate': widget.bookingData?['selectedDate'],
            'selectedTimeSlot': widget.bookingData?['selectedTimeSlot'],
            // 'timeSlotIds': timeSlotIds,
            'sessionCount': widget.bookingData?['sessionCount'] ?? 1,
            'totalCharges': totalCharges,
            'equipmentQuantities':
                widget.bookingData?['equipmentQuantities'] ?? {},
            'equipmentPrices': widget.bookingData?['equipmentPrices'] ?? {},
            'equipmentIds':
                widget.bookingData?['equipmentIds'] ?? {}, // Add this line
            'remark': remarkController.text,
            'name': nameController.text,
            'phone': phoneController.text,
            'venueId': widget.bookingData?['venueId'] ?? 1,
            'courtId': widget.bookingData?['courtId'] ?? 1,
          };
          // Use rentalPayment as a constructor (with capital R and P)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  rentalPayment(bookingData: updatedBookingData),
            ),
          );
        },
        child: Text(
          "Confirm",
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Custom",
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
