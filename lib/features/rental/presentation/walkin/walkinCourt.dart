import 'package:flutter/material.dart';
import 'package:nyxproject/features/rental/domain/WalkInCourt.dart' as model;
import 'package:nyxproject/features/rental/presentation/walkin/walkinbooking_form.dart';

class WalkInCourt extends StatefulWidget {
  final model.WalkInCourt court;

  const WalkInCourt({super.key, required this.court});

  @override
  State<WalkInCourt> createState() => _WalkInCourtState();
}

class _WalkInCourtState extends State<WalkInCourt> {
  DateTime selectedDate = DateTime.now();
  int currentIndex = 0;
  bool _isChecked2 = false;
  late final Map<String, int> equipmentQuantities;
  late final Map<String, String> equipmentPrices;
  late final Map<String, int> equipmentMaxQty;
  late final Map<String, int> equipmentIds;

  @override
  void initState() {
    super.initState();
    equipmentQuantities = {
      for (final item in widget.court.equipment) item.name: 0,
    };
    equipmentPrices = {
      for (final item in widget.court.equipment)
        item.name: '${item.price} Ks/hour',
    };
    equipmentMaxQty = {
      for (final item in widget.court.equipment) item.name: item.maxQuantity,
    };
    equipmentIds = {
      for (final item in widget.court.equipment)
        if (item.id != null) item.name: item.id!,
    };
  }

  List<DateTime> getAvailableDates() {
    List<DateTime> dates = [];
    for (int i = 0; i < 5; i++) {
      dates.add(DateTime.now().add(Duration(days: i)));
    }
    return dates;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _header(screenWidth, screenHeight),
              _banner(screenWidth, screenHeight),
              SizedBox(height: screenHeight * 0.01),
              _location(screenWidth, screenHeight),
              SizedBox(height: screenHeight * 0.01),
              _courtDetails(screenWidth),
              SizedBox(height: screenHeight * 0.01),
              _bookDate(screenWidth, screenHeight),

              SizedBox(height: screenHeight * 0.01),
              _rentalSection(screenWidth, screenHeight),
              SizedBox(height: screenHeight * 0.01),
              _valid(screenWidth, screenHeight),
              _confirm(screenWidth, screenHeight),
              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(double screenWidth, double screenHeight) {
    return Container(
      color: const Color.fromARGB(255, 13, 27, 42),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.015,
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
              size: screenWidth * 0.05,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          SizedBox(width: screenWidth * 0.03),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.court.courtName,
                style: TextStyle(
                  fontFamily: "Custom",
                  color: Colors.white,
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                widget.court.walkInPrice == null
                    ? "Walk-in price unavailable"
                    : "${widget.court.walkInPrice} Ks / hour",
                style: TextStyle(
                  fontFamily: "Custom",
                  color: Colors.white70,
                  fontSize: screenWidth * 0.03,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _location(double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.01,
        horizontal: screenWidth * 0.03,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Icons.location_on_sharp,
            color: Colors.red,
            size: screenWidth * 0.07,
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Text(
              widget.court.venueName,
              style: TextStyle(
                fontFamily: "Custom",
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _banner(double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      width: screenWidth,
      height: screenHeight * 0.25,
      decoration: BoxDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: widget.court.courtImages.isNotEmpty
            ? Image.network(
                widget.court.courtImages.first,
                fit: BoxFit.cover,
                height: screenHeight * 0.25,
                width: screenWidth,
                errorBuilder: (context, error, stackTrace) =>
                    _fallbackImage(screenWidth, screenHeight),
              )
            : _fallbackImage(screenWidth, screenHeight),
      ),
    );
  }

  Widget _courtDetails(double screenWidth) {
    final court = widget.court;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _detailRow('Status', court.status),
              _detailRow('Court ID', court.courtId?.toString()),
              _detailRow('Walk-in ID', court.walkInId?.toString()),
              _detailRow(
                'Opening hours',
                court.openAt != null && court.closeAt != null
                    ? '${court.openAt} - ${court.closeAt}'
                    : null,
              ),
              _detailRow('Capacity', court.capacity?.toString()),
              _detailRow('Booked', court.bookedCount?.toString()),
              _detailRow('Remaining', court.remainingCapacity?.toString()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value ?? 'Not available'),
        ],
      ),
    );
  }

  Widget _fallbackImage(double screenWidth, double screenHeight) {
    return Image.asset(
      "assets/images/badminton_court.jpg",
      fit: BoxFit.cover,
      height: screenHeight * 0.25,
      width: screenWidth,
    );
  }

  Widget _bookDate(double screenWidth, double screenHeight) {
    List<DateTime> dates = getAvailableDates();
    List<String> getWeekDays() {
      List<String> weekDays = [];
      DateTime now = DateTime.now();
      for (int i = 0; i < 5; i++) {
        DateTime date = now.add(Duration(days: i));
        weekDays.add(_getDayName(date.weekday));
      }
      return weekDays;
    }

    List<String> weekDays = getWeekDays();

    return Container(
      height: screenHeight * 0.14,
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.01,
        horizontal: screenWidth * 0.01,
      ),
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
      decoration: BoxDecoration(
        // color: const Color.fromARGB(255, 13, 27, 42),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  color: Colors.black,
                  size: screenWidth * 0.05,
                ),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  "Select a reservation date",
                  style: TextStyle(
                    fontFamily: "Custom",
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 13, 27, 42),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(dates.length, (index) {
                bool isSelected =
                    selectedDate.day == dates[index].day &&
                    selectedDate.month == dates[index].month &&
                    selectedDate.year == dates[index].year;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDate = dates[index];
                    });
                  },
                  child: Container(
                    width: screenWidth * 0.17,
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.01,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.red : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? Colors.red
                            : Color.fromARGB(255, 13, 27, 42),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          weekDays[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black54,
                            fontSize: screenWidth * 0.032,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.003),
                        Text(
                          dates[index].day.toString(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return "Mon";
      case 2:
        return "Tue";
      case 3:
        return "Wed";
      case 4:
        return "Thu";
      case 5:
        return "Fri";
      case 6:
        return "Sat";
      case 7:
        return "Sun";
      default:
        return "Mon";
    }
  }

  Widget _timeSchedule(double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.01,
        horizontal: screenWidth * 0.03,
      ),
    );
  }

  Widget _rentalSection(double screenWidth, double screenHeight) {
    if (equipmentQuantities.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 13, 27, 42),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Equipment Rental',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Custom',
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Optional',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: screenWidth * 0.035,
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.015),
          ...equipmentQuantities.keys.map(
            (equipment) => Padding(
              padding: EdgeInsets.only(bottom: screenHeight * 0.01),
              child: _equipmentRow(
                equipment,
                equipmentPrices[equipment]!,
                equipmentMaxQty[equipment]!,
                screenWidth,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _equipmentRow(
    String name,
    String price,
    int maxQuantity,
    double screenWidth,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.035,
                  ),
                ),
                Text(
                  'Available: $maxQuantity',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: screenWidth * 0.028,
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.035,
            ),
          ),
          IconButton(
            onPressed: equipmentQuantities[name]! > 0
                ? () => setState(
                    () => equipmentQuantities[name] =
                        equipmentQuantities[name]! - 1,
                  )
                : null,
            icon: const Icon(Icons.remove, color: Colors.white, size: 18),
          ),
          Text(
            '${equipmentQuantities[name]}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: equipmentQuantities[name]! < maxQuantity
                ? () => setState(
                    () => equipmentQuantities[name] =
                        equipmentQuantities[name]! + 1,
                  )
                : null,
            icon: const Icon(Icons.add, color: Colors.white, size: 18),
          ),
        ],
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
            vertical: screenHeight * 0.01,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: () {
          final bookingData = {
            'courtName': widget.court.courtName,
            'walk_in_price': widget.court.walkInPrice,
            'courtPrice': double.tryParse(widget.court.walkInPrice ?? '0') ?? 0,
            'selectedDate': selectedDate,
            'venue_name': widget.court.venueName,
            'open_at': widget.court.openAt,
            'close_at': widget.court.closeAt,
            'equipmentQuantities': equipmentQuantities,
            'equipmentPrices': equipmentPrices,
            'equipmentIds': equipmentIds,
            'venueId': widget.court.venueId,
            'courtId': widget.court.courtId,
            'walkInId': widget.court.walkInId,
          };
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WalkInBookingForm(bookingData: bookingData),
            ),
          );
        },
        child: Text(
          "Booking Now",
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Custom",
            fontSize: screenWidth * 0.04,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _valid(double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
      child: Row(
        children: [
          Checkbox(
            value: _isChecked2,
            onChanged: (bool? value) {
              if (mounted)
                setState(() {
                  _isChecked2 = value!;
                });
            },
            activeColor: Colors.red,
          ),
          Expanded(
            child: Text(
              "I have read and agree to follow the court rules & safety guidelines.",
              style: TextStyle(
                color: Colors.grey.shade800,
                fontFamily: "Custom",
                fontSize: screenWidth * 0.03,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
