import 'package:provider/provider.dart';
import 'package:nyxproject/features/user/data/datasources/session_manager.dart';
import 'package:nyxproject/features/cart/presentation/bloc/cart_service.dart';
import 'package:nyxproject/features/user/presentation/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:nyxproject/features/rental/data/datasources/RentelApi/AvaiSlotTimeApi.dart';
import 'package:nyxproject/features/rental/data/datasources/RentelApi/VenueApi.dart';
import 'package:nyxproject/features/rental/domain/entities/AvaiSlotTime.dart';
import 'package:nyxproject/features/rental/presentation/pages/rental/booking_form.dart';
import 'package:nyxproject/features/rental/domain/entities/Venue.dart';
import 'package:nyxproject/features/rental/domain/entities/Court.dart';

class CourtDetails extends StatefulWidget {
  final Venue? selectedVenue;
  final Court? selectedCourt;
  final int? venueId;

  const CourtDetails({
    super.key,
    this.selectedVenue,
    this.selectedCourt,
    this.venueId,
  });

  @override
  State<CourtDetails> createState() => _CourtDetailsState();
}

class _CourtDetailsState extends State<CourtDetails> {
  bool _isChecked = false;
  int currentIndex = 0;
  int selectedVenueIndex = 0;
  DateTime selectedDate = DateTime.now();
  bool _isChecked2 = false;

  List<Venue> venues = [];
  bool _isLoadingVenues = true;
  String? _venuesError;

  List<AvailableSlot> _availableSlots = [];
  AvailableSlot? selectedTimeSlot;
  bool _isLoadingSlots = false;
  String? _slotsError;

  Map<String, int> equipmentQuantities = {};
  Map<String, String> equipmentPrices = {};
  Map<String, int> equipmentMaxQty = {};
  Map<String, int> equipmentIds = {};

  List<String> galleryImages = [];
  bool _isLoadingGallery = true;

  double get courtPrice {
    if (widget.selectedCourt != null) {
      return widget.selectedCourt!.hourlyPrice.toDouble();
    }
    if (widget.selectedVenue != null) {
      return widget.selectedVenue!.price.toDouble();
    }
    if (venues.isNotEmpty && selectedVenueIndex < venues.length) {
      return venues[selectedVenueIndex].price.toDouble();
    }
    return 25000;
  }

  String get courtName {
    if (widget.selectedCourt != null) {
      return widget.selectedCourt!.courtName;
    }
    if (widget.selectedVenue != null) {
      return widget.selectedVenue!.venueName;
    }
    if (venues.isNotEmpty && selectedVenueIndex < venues.length) {
      return venues[selectedVenueIndex].venueName;
    }
    return "Badminton Court";
  }

  int get sessionCount => selectedTimeSlot != null ? 1 : 0;

  double getSessionPrice() {
    if (selectedTimeSlot == null) return 0;
    double basePrice = courtPrice;
    return basePrice;
  }

  List<DateTime> getAvailableDates() {
    List<DateTime> dates = [];
    for (int i = 0; i < 5; i++) {
      dates.add(DateTime.now().add(Duration(days: i)));
    }
    return dates;
  }

  String _formatTime(String time) {
    if (time.isEmpty) return "";
    List<String> parts = time.split(':');
    int hour = int.parse(parts[0]);
    return "$hour:${parts[1]}";
  }

  @override
  void initState() {
    super.initState();
    _loadGalleryFromCourt();
    _loadEquipmentFromCourt();
    _loadAvailableSlots();
    if (widget.selectedCourt == null && widget.selectedVenue == null) {
      _loadVenues();
    } else {
      _isLoadingVenues = false;
    }
  }

  void _loadGalleryFromCourt() {
    if (widget.selectedCourt != null &&
        widget.selectedCourt!.gallery != null &&
        widget.selectedCourt!.gallery!.isNotEmpty) {
      galleryImages = widget.selectedCourt!.gallery!
          .map((g) => g.courtImageUrl)
          .where((url) => url.isNotEmpty)
          .toList();
      _isLoadingGallery = false;
      if (galleryImages.isEmpty) {
        _useDefaultImages();
      }
    } else {
      _useDefaultImages();
    }
  }

  void _useDefaultImages() {
    galleryImages = [
      "assets/classes/Badminton.png",
      "assets/classes/Futsal.png",
      "assets/classes/Tennis.png",
    ];
    _isLoadingGallery = false;
  }

  Future<void> _loadVenues() async {
    if (!mounted) return;
    setState(() {
      _isLoadingVenues = true;
      _venuesError = null;
    });
    try {
      final result = await VenueApi.getAllVenues();
      if (!mounted) return;
      if (result['success'] == true) {
        setState(() {
          venues = result['data'] ?? [];
          _isLoadingVenues = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _venuesError = result['message'] ?? 'Failed to load venues';
          _isLoadingVenues = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _venuesError = 'Error loading venues: $e';
        _isLoadingVenues = false;
      });
    }
  }

  Future<void> _loadAvailableSlots() async {
    if (widget.selectedCourt == null) return;
    setState(() {
      _isLoadingSlots = true;
      _slotsError = null;
    });
    try {
      String formattedDate =
          "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
      final result = await AvailableSlotApi.getAvailableSlots(
        widget.selectedCourt!.id,
        formattedDate,
      );
      if (!mounted) return;
      if (result['success'] == true) {
        setState(() {
          _availableSlots = result['data'] ?? [];
          _isLoadingSlots = false;
        });
      } else {
        setState(() {
          _slotsError = result['message'] ?? 'Failed to load available slots';
          _isLoadingSlots = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _slotsError = 'Error loading available slots: $e';
        _isLoadingSlots = false;
      });
    }
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
              _banner(screenWidth, screenHeight),
              // _location(screenWidth, screenHeight),
              SizedBox(height: screenHeight * 0.01),
              _bookDate(screenWidth, screenHeight),
              SizedBox(height: screenHeight * 0.01),
              _timeSchedule(screenWidth, screenHeight),
              if (widget.selectedCourt == null && widget.selectedVenue == null)
                _venueSelection(screenWidth, screenHeight),
              _schedule(screenWidth, screenHeight),
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
                courtName,
                style: TextStyle(
                  fontFamily: "Custom",
                  color: Colors.white,
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "${courtPrice.toStringAsFixed(0)} Ks / hour",
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

  Widget _banner(double screenWidth, double screenHeight) {
    if (_isLoadingGallery) {
      return SizedBox(
        height: screenHeight * 0.28,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (galleryImages.isEmpty) {
      return SizedBox(
        height: screenHeight * 0.28,
        child: Container(
          color: Colors.grey.shade800,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported,
                  size: 50,
                  color: Colors.white54,
                ),
                SizedBox(height: 10),
                Text(
                  "No images available",
                  style: TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CarouselSlider(
          items: galleryImages.map((imageUrl) {
            return Container(
              margin: EdgeInsets.all(screenWidth * 0.01),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: imageUrl.startsWith('http')
                      ? NetworkImage(imageUrl) as ImageProvider
                      : AssetImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            );
          }).toList(),
          options: CarouselOptions(
            height: screenHeight * 0.28,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 900),
            enlargeCenterPage: true,
            viewportFraction: 1,
            onPageChanged: (index, reason) {
              if (mounted) {
                setState(() {
                  currentIndex = index;
                });
              }
            },
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: galleryImages.asMap().entries.map((item) {
            return Container(
              height: screenHeight * 0.008,
              width: screenWidth * 0.02,
              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.005),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentIndex == item.key ? Colors.red : Colors.grey,
              ),
            );
          }).toList(),
        ),
      ],
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
              "No.(111), Hlaing Township, Yangon.",
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
      height: screenHeight * 0.16,
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.01,
        horizontal: screenWidth * 0.01,
      ),
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
      decoration: BoxDecoration(color: const Color.fromARGB(255, 13, 27, 42)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  color: Colors.white,
                  size: screenWidth * 0.05,
                ),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  "Select a reservation date",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
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
                    if (mounted) {
                      setState(() {
                        selectedDate = dates[index];
                        selectedTimeSlot = null;
                      });
                      _loadAvailableSlots();
                    }
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
                        color: isSelected ? Colors.red : Colors.grey.shade300,
                        width: 1,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Icons.timer,
            color: const Color.fromARGB(255, 71, 250, 77),
            size: screenWidth * 0.07,
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Text(
              "Select Time Slot",
              style: TextStyle(
                fontFamily: "Custom",
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (selectedTimeSlot != null)
            Text(
              "1 selected",
              style: TextStyle(
                color: Colors.red,
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _venueSelection(double screenWidth, double screenHeight) {
    if (_isLoadingVenues) {
      return Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_venuesError != null) {
      return Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          children: [
            Text(_venuesError!, style: const TextStyle(color: Colors.red)),
            SizedBox(height: screenHeight * 0.01),
            ElevatedButton(
              onPressed: () {
                if (mounted) _loadVenues();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (venues.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: const Text('No venues available'),
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select Court",
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          SizedBox(
            height: screenHeight * 0.12,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: venues.length,
              itemBuilder: (context, index) {
                final venue = venues[index];
                bool isSelected = selectedVenueIndex == index;
                return GestureDetector(
                  onTap: () {
                    if (mounted) {
                      setState(() {
                        selectedVenueIndex = index;
                      });
                    }
                  },
                  child: Container(
                    width: screenWidth * 0.4,
                    margin: EdgeInsets.only(right: screenWidth * 0.02),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.red : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? Colors.red : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            venue.venueImageUrl,
                            width: screenWidth * 0.15,
                            height: screenHeight * 0.1,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: screenWidth * 0.15,
                                height: screenHeight * 0.1,
                                color: Colors.grey,
                                child: const Icon(Icons.sports),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                venue.venueName,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: screenWidth * 0.035,
                                ),
                              ),
                              Text(
                                "${venue.price.toString()} Ks",
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white70
                                      : Colors.red,
                                  fontSize: screenWidth * 0.03,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _schedule(double screenWidth, double screenHeight) {
    if (_isLoadingSlots) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_slotsError != null) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              Text(
                _slotsError!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _loadAvailableSlots,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (_availableSlots.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            "No available time slots for selected date",
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    List<String> formattedSlots = _availableSlots.map((slot) {
      return "${_formatTime(slot.startTime)} - ${_formatTime(slot.endTime)}";
    }).toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: formattedSlots.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: screenWidth * 0.02,
              mainAxisSpacing: screenHeight * 0.01,
              childAspectRatio: 2.2,
            ),
            itemBuilder: (context, index) {
              bool isSelected = selectedTimeSlot == _availableSlots[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedTimeSlot = _availableSlots[index];
                  });
                },
                child: Container(
                  margin: EdgeInsets.all(screenWidth * 0.01),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.red : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? Colors.red : Colors.grey.shade400,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      formattedSlots[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Custom",
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          if (selectedTimeSlot != null)
            Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.01),
              child: Text(
                "Selected: 1 session - Total: ${courtPrice.toStringAsFixed(0)} Ks",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _rentalSection(double screenWidth, double screenHeight) {
    if (equipmentQuantities.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.02,
        vertical: screenHeight * 0.01,
      ),
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
                "Equipment Rental",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "Custom",
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "Optional",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: screenWidth * 0.035,
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.015),
          ...equipmentQuantities.keys.map((equipment) {
            return Padding(
              padding: EdgeInsets.only(bottom: screenHeight * 0.01),
              child: _rentalAccessories(
                equipment,
                equipmentPrices[equipment]!,
                equipmentQuantities[equipment]!,
                equipmentMaxQty[equipment] ?? 99,
                screenWidth,
                screenHeight,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _rentalAccessories(
    String text,
    String price,
    int quantity,
    int maxQty,
    double screenWidth,
    double screenHeight,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.02,
        vertical: screenHeight * 0.008,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Row(
        children: [
          SizedBox(
            width: screenWidth * 0.25,
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontFamily: "Custom",
                fontSize: screenWidth * 0.035,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: screenWidth * 0.05),
          Text(
            price,
            style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
          ),
          SizedBox(width: screenWidth * 0.05),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (equipmentQuantities[text]! > 0)
                      equipmentQuantities[text] =
                          equipmentQuantities[text]! - 1;
                  });
                },
                child: const Icon(Icons.remove, color: Colors.white, size: 18),
              ),
              SizedBox(width: screenWidth * 0.02),
              Text(
                equipmentQuantities[text].toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (equipmentQuantities[text]! < maxQty)
                      equipmentQuantities[text] =
                          equipmentQuantities[text]! + 1;
                  });
                },
                child: const Icon(Icons.add, color: Colors.white, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _loadEquipmentFromCourt() {
    equipmentQuantities.clear();
    equipmentPrices.clear();
    equipmentMaxQty.clear();
    equipmentIds.clear();
    if (widget.selectedCourt != null &&
        widget.selectedCourt!.equipment != null &&
        widget.selectedCourt!.equipment!.isNotEmpty) {
      for (var item in widget.selectedCourt!.equipment!) {
        equipmentQuantities[item.productName] = 0;
        equipmentPrices[item.productName] = "${item.rentalPrice} Ks/hour";
        equipmentMaxQty[item.productName] = item.qtyTotal;
        equipmentIds[item.productName] = item.id;
      }
    }
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
                color: Colors.grey.shade600,
                fontFamily: "Custom",
                fontSize: screenWidth * 0.03,
              ),
            ),
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
            vertical: screenHeight * 0.015,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: () {
          _checkLoginAndProceed();
        },
        child: Text(
          "Booking Now",
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

  void _checkLoginAndProceed() {
    if (selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a time slot'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final sessionService = Provider.of<SessionService>(context, listen: false);
    if (sessionService.isLoggedIn() && sessionService.getToken() != null) {
      List<int> timeSlotIds = [selectedTimeSlot!.id];

      // Safe handling of venueId
      int venueId = 1; // default
      if (widget.venueId != null) {
        venueId = widget.venueId!;
      } else if (widget.selectedCourt != null &&
          widget.selectedCourt!.venueId != null) {
        venueId = widget.selectedCourt!.venueId;
      }

      print("DEBUG CourtDetails: venueId = $venueId");
      print("DEBUG CourtDetails: courtId = ${widget.selectedCourt?.id ?? 1}");

      final bookingData = {
        'courtName': courtName,
        'courtPrice': courtPrice,
        'selectedDate': selectedDate,
        'selectedTimeSlot': selectedTimeSlot,
        'timeSlotIds': timeSlotIds,
        'sessionCount': 1,
        'sessionPrice': getSessionPrice(),
        'totalCharges': getSessionPrice(),
        'equipmentQuantities': equipmentQuantities,
        'equipmentPrices': equipmentPrices,
        'equipmentIds': equipmentIds,
        'venueId': venueId,
        'courtId': widget.selectedCourt?.id ?? 1,
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => bookingForm(bookingData: bookingData),
        ),
      );
    } else {
      _showLoginRequiredDialog();
    }
  }

  void _showLoginRequiredDialog() {
    final sessionService = Provider.of<SessionService>(context, listen: false);
    final cartService = Provider.of<CartService>(context, listen: false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Login Required"),
        content: const Text("Please login to continue with your booking."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(
                    sessionService: sessionService,
                    cartService: cartService,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Login Now"),
          ),
        ],
      ),
    );
  }
}
