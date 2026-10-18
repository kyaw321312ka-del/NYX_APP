import 'package:flutter/material.dart';
import 'package:nyxproject/features/rental/presentation/pages/walkin/walkinbooking_form.dart';

class WalkInCourts extends StatefulWidget {
  const WalkInCourts({super.key});

  @override
  State<WalkInCourts> createState() => _WalkInCourtsState();
}

class _WalkInCourtsState extends State<WalkInCourts> {
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
              _courtCard(screenWidth, screenHeight),
              // _buildCourtList(screenWidth, screenHeight),
              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildCourtList(double screenWidth, double screenHeight) {
  // if (_isLoading) {
  //   return const Center(
  //     child: Padding(
  //       padding: EdgeInsets.all(20),
  //       child: CircularProgressIndicator(),
  //     ),
  //   );
  // }

  // if (_error != null) {
  // return Center(
  //   child: Padding(
  //     padding: const EdgeInsets.all(20),
  //     child: Column(
  //       children: [
  //         Text(
  //           "Courts",
  //           style: const TextStyle(color: Colors.red),
  //           textAlign: TextAlign.center,
  //         ),
  //         const SizedBox(height: 10),
  //         ElevatedButton(
  //           onPressed: () {},
  //           style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
  //           child: const Text('Retry', style: TextStyle(color: Colors.white)),
  //         ),
  //       ],
  //     ),
  //   ),
  // );
  // }

  // if (_courts.isEmpty) {
  //   return const Center(
  //     child: Padding(
  //       padding: EdgeInsets.all(20),
  //       child: Text('No courts available'),
  //     ),
  //   );
  // }

  // return Column(
  //   children: _courts.map((court) {
  //     return _courtCard(context, court, screenWidth, screenHeight);
  //   }).toList(),
  // );
  // }

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
              "Courts",
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
            "Choose your Court to play comfortably.",
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

  Widget _courtCard(double screenWidth, double screenHeight) {
    // Get the first gallery image or use placeholder
    // court.gallery != null && court.gallery!.isNotEmpty
    //     ? court.gallery!.first.courtImageUrl
    // : '';

    // Format open and close times
    // String openTime = _formatTime(court.openAt);
    // String closeTime = _formatTime(court.closeAt);

    // print("DEBUG CourtCard: court.id = ${court.id}");
    // print("DEBUG CourtCard: court.venueId = ${court.venueId}");
    // print("DEBUG CourtCard: widget.venueId = ${widget.venueId}");

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.025,
        vertical: screenHeight * 0.01,
      ),
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
            child:
                // imageUrl.isNotEmpty
                //     ? Image.network(
                //         imageUrl,
                //         fit: BoxFit.cover,
                //         height: screenHeight * 0.2,
                //         width: screenWidth,
                //         errorBuilder: (context, error, stackTrace) {
                //           return Container(
                //             height: screenHeight * 0.2,
                //             width: screenWidth,
                //             color: Colors.grey,
                //             child: const Icon(
                //               Icons.sports,
                //               size: 50,
                //               color: Colors.white54,
                //             ),
                //           );
                //         },
                //       )
                Container(
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
                // Court name
                Text(
                  "Badminton Courts",
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
                    Icon(
                      Icons.access_time,
                      color: Colors.white70,
                      size: screenWidth * 0.04,
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      "9:00 - 20:00",
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
                    Icon(
                      Icons.attach_money,
                      color: Colors.red,
                      size: screenWidth * 0.04,
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      "25,000 Ks / hour",
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
                          // int venueIdToPass = widget.venueId;
                          // print(
                          //   "DEBUG: Passing venueId = $venueIdToPass to CourtDetails",
                          // );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WalkInBookingForm(
                                // selectedCourt: court,
                                // venueId: venueIdToPass,
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Court details are not available on this screen',
                              ),
                            ),
                          );
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
}
