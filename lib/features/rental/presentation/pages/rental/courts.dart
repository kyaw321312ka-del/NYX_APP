import 'package:flutter/material.dart';
import 'package:nyxproject/core/error/app_error_message.dart';
import 'package:nyxproject/core/presentation/widgets/app_error_view.dart';
import 'package:nyxproject/features/rental/data/datasources/RentelApi/CourtApi.dart';
import 'package:nyxproject/features/rental/domain/entities/Court.dart';
import 'package:nyxproject/features/rental/presentation/pages/rental/court_details.dart';

class Courts extends StatefulWidget {
  final int venueId;
  final String venueName;

  const Courts({
    super.key,
    required this.venueId,
    required this.venueName,
  });

  @override
  State<Courts> createState() => _CourtsState();
}

class _CourtsState extends State<Courts> {
  List<Court> _courts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    print("DEBUG Courts: venueId = ${widget.venueId}");
    print("DEBUG Courts: venueName = ${widget.venueName}");
    _loadCourts();
  }

  Future<void> _loadCourts() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await CourtApi.getCourtsByVenueId(widget.venueId);

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          _courts = result['data'] ?? [];
          _isLoading = false;
        });
        print('Loaded ${_courts.length} courts for venue ${widget.venueId}');
      } else {
        setState(() {
          _error = AppErrorMessage.from(
            result['message'] ?? 'Failed to load courts',
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = AppErrorMessage.from(e);
        _isLoading = false;
      });
    }
  }

  String _formatTime(String time) {
    if (time.isEmpty) return "";
    List<String> parts = time.split(':');
    int hour = int.parse(parts[0]);
    String minute = parts[1];
    String period = hour >= 12 ? "PM" : "AM";
    int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return "$displayHour:$minute $period";
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
              SizedBox(height: screenHeight * 0.01),
              _courtHeader(screenWidth, screenHeight),
              SizedBox(height: screenHeight * 0.015),
              _buildCourtList(screenWidth, screenHeight),
              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourtList(double screenWidth, double screenHeight) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return AppErrorView(
        message: _error!,
        onRetry: _loadCourts,
      );
    }

    if (_courts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No courts available'),
        ),
      );
    }

    return Column(
      children: _courts.map((court) {
        return _courtCard(
          context,
          court,
          screenWidth,
          screenHeight,
        );
      }).toList(),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
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
          Expanded(
            child: Text(
              widget.venueName,
              style: TextStyle(
                fontFamily: "Custom",
                color: Colors.white,
                fontSize: screenWidth * 0.055,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _courtHeader(double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Choose Court",
            style: TextStyle(
              fontFamily: "Custom",
              fontSize: screenWidth * 0.055,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: screenHeight * 0.005),
          Text(
            "Choose your court to play comfortably.",
            style: TextStyle(
              fontFamily: "Custom",
              fontSize: screenWidth * 0.04,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _courtCard(
    BuildContext context,
    Court court,
    double screenWidth,
    double screenHeight,
  ) {
    // Get the first gallery image or use placeholder
    String imageUrl = court.gallery != null && court.gallery!.isNotEmpty
        ? court.gallery!.first.courtImageUrl
        : '';

    // Format open and close times
    String openTime = _formatTime(court.openAt);
    String closeTime = _formatTime(court.closeAt);

    print("DEBUG CourtCard: court.id = ${court.id}");
    print("DEBUG CourtCard: court.venueId = ${court.venueId}");
    print("DEBUG CourtCard: widget.venueId = ${widget.venueId}");

    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.025, vertical: screenHeight * 0.01),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 13, 27, 42),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Court Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    height: screenHeight * 0.2,
                    width: screenWidth,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: screenHeight * 0.2,
                        width: screenWidth,
                        color: Colors.grey,
                        child: const Icon(
                          Icons.sports,
                          size: 50,
                          color: Colors.white54,
                        ),
                      );
                    },
                  )
                : Container(
                    height: screenHeight * 0.2,
                    width: screenWidth,
                    color: Colors.grey,
                    child: const Icon(
                      Icons.sports,
                      size: 50,
                      color: Colors.white54,
                    ),
                  ),
          ),
          
          // Court Info
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Court Name
                Text(
                  court.courtName,
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontFamily: "Custom",
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                
                // Operating Hours
                Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.white70, size: screenWidth * 0.04),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      "$openTime - $closeTime",
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        fontFamily: "Custom",
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.008),
                
                // Price
                Row(
                  children: [
                    Icon(Icons.attach_money, color: Colors.red, size: screenWidth * 0.04),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      "${court.hourlyPrice.toString()} Ks / hour",
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontFamily: "Custom",
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.015),
                
                // Buttons
                Row(
                  children: [
                    // Booking Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // Ensure venueId is not null
                          int venueIdToPass = widget.venueId;
                          print("DEBUG: Passing venueId = $venueIdToPass to CourtDetails");
                          
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CourtDetails(
                                selectedCourt: court,
                                venueId: venueIdToPass,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: screenHeight * 0.045,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: Text(
                              "Book Now",
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                fontFamily: "Custom",
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    // Court Details Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _showCourtDetailsDialog(context, court, screenWidth, screenHeight);
                        },
                        child: Container(
                          height: screenHeight * 0.045,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: Text(
                              "Details",
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                fontFamily: "Custom",
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCourtDetailsDialog(BuildContext context, Court court, double screenWidth, double screenHeight) {
    String openTime = _formatTime(court.openAt);
    String closeTime = _formatTime(court.closeAt);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          court.courtName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // About
              Text(
                "About",
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                court.aboutCourt.isNotEmpty ? court.aboutCourt : "No description available",
                style: TextStyle(fontSize: screenWidth * 0.035),
              ),
              const SizedBox(height: 15),
              
              // Price
              Row(
                children: [
                  const Icon(Icons.attach_money, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Price: ${court.hourlyPrice} Ks / hour",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              
              // Operating Hours
              Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Text("Open: $openTime - $closeTime"),
                ],
              ),
              const SizedBox(height: 15),
              
              // Pros
              if (court.pros != null && court.pros!.isNotEmpty) ...[
                Text(
                  "Pros",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 5),
                ...court.pros!.map((p) => Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 4),
                  child: Text("✓ ${p.name}"),
                )),
                const SizedBox(height: 10),
              ],
              
              // Cons
              if (court.cons != null && court.cons!.isNotEmpty) ...[
                Text(
                  "Cons",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 5),
                ...court.cons!.map((c) => Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 4),
                  child: Text("✗ ${c.name}"),
                )),
                const SizedBox(height: 10),
              ],
              
              // Rules
              if (court.rules != null && court.rules!.isNotEmpty) ...[
                Text(
                  "Rules",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 5),
                ...court.rules!.map((r) => Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 4),
                  child: Text("• ${r.name}: ${r.detail}"),
                )),
                const SizedBox(height: 10),
              ],
              
              // Services
              if (court.services != null && court.services!.isNotEmpty) ...[
                Text(
                  "Services",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 5),
                ...court.services!.map((s) => Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 4),
                  child: Text("• ${s.name}"),
                )),
              ],
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
}