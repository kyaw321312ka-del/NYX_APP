import 'package:flutter/material.dart';
import 'package:nyxproject/features/rental/data/RentelApi/WalkInCourtApi.dart';
import 'package:nyxproject/features/rental/domain/WalkInCourt.dart';
import 'package:nyxproject/features/rental/presentation/walkin/walkinCourt.dart'
  as walkin_details;

class WalkInScreen extends StatefulWidget {
  const WalkInScreen({super.key});

  @override
  State<WalkInScreen> createState() => _WalkInScreenState();
}

class _WalkInScreenState extends State<WalkInScreen> {
  List<WalkInCourt> courts = [];
  String? selectedVenue;
  String? errorMessage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourts();
  }

  Future<void> _loadCourts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final result = await WalkInCourtApi.getWalkInCourts();
    if (!mounted) return;

    setState(() {
      isLoading = false;
      if (result['success'] == true) {
        courts = List<WalkInCourt>.from(result['data'] ?? []);
        if (selectedVenue != null &&
            !courts.any((court) => court.venueName == selectedVenue)) {
          selectedVenue = null;
        }
      } else {
        errorMessage = result['message']?.toString() ?? 'Failed to load courts';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: const Text(
                "Walk-In",
                style: TextStyle(
                  fontSize: 19,
                  fontFamily: "Custom",
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: const Text(
                "Enjoy your private court.",
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: "Custom",
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildCourtList(context),
            const SizedBox(height: 10),
          ],
        ),
    );
  }

  // Widget _buildVenueList() {
  // if (isLoadingVenues) {
  //   return const Center(
  //     child: Padding(
  //       padding: EdgeInsets.all(20),
  //       child: CircularProgressIndicator(),
  //     ),
  //   );
  // }

  // if (venuesError != null) {
  //   return Center(
  //     child: Padding(
  //       padding: const EdgeInsets.all(20),
  //       child: Column(
  //         children: [
  //           Text(venuesError!, style: const TextStyle(color: Colors.red)),
  //           const SizedBox(height: 10),
  //           ElevatedButton(
  //             onPressed: onRetryVenues,
  //             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
  //             child: const Text(
  //               'Retry',
  //               style: TextStyle(color: Colors.white),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // if (venues.isEmpty) {
  //   return const Center(
  //     child: Padding(
  //       padding: EdgeInsets.all(20),
  //       child: Text('No venues available'),
  //     ),
  //   );
  // }

  //   return _buildVenueCard(context);
  // }

  Widget _buildCourtList(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          children: [
            Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _loadCourts, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (courts.isEmpty) {
      return const Center(child: Text('No courts available'));
    }

    final venues = courts
        .map((court) => court.venueName)
        .where((venue) => venue.isNotEmpty)
        .toSet()
        .toList();
    final filteredCourts = selectedVenue == null
        ? courts
        : courts.where((court) => court.venueName == selectedVenue).toList();

    return Column(
      children: [
        if (venues.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: DropdownButtonFormField<String?>(
              initialValue: selectedVenue,
              decoration: const InputDecoration(
                labelText: 'Filter by venue',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All venues'),
                ),
                ...venues.map(
                  (venue) => DropdownMenuItem<String?>(
                    value: venue,
                    child: Text(venue),
                  ),
                ),
              ],
              onChanged: (venue) => setState(() => selectedVenue = venue),
            ),
          ),
        const SizedBox(height: 10),
        if (filteredCourts.isEmpty)
          const Text('No courts available for this venue')
        else
          ...filteredCourts.map((court) => _buildVenueCard(context, court)),
      ],
    );
  }

  Widget _buildVenueCard(BuildContext context, WalkInCourt court) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    double screenHeight = MediaQuery.sizeOf(context).height;
    return GestureDetector(
      onTap: () {
        // Navigate to Courts page with venueId and venueName
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) =>
        //         Courts(venueId: venue.id, venueName: venue.venueName),
        //   ),
        // );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => walkin_details.WalkInCourt(court: court),
          ),
        );
      },
      child: Container(
        height: screenHeight * 0.33,
        margin: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.0125,
          vertical: screenHeight * 0.01,
        ),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 13, 27, 42),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: _buildCourtImage(
                  court,
                  screenWidth,
                  screenHeight,
                ),
              ),
            ),
            Positioned(
              left: screenWidth * 0.025,
              bottom: screenHeight * 0.08,
              child: Text(
                court.courtName,
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontFamily: "Custom",
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              right: screenWidth * 0.025,
              bottom: screenHeight * 0.08,
              child: Text(
                court.walkInPrice == null
                    ? 'Not available'
                    : '${court.walkInPrice} Ks',
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontFamily: "Custom",
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              bottom: screenHeight * 0.01,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                width: screenWidth * 0.95,
                height: screenHeight * 0.06,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text(
                  "Show Details",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: "Custom",
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourtImage(
    WalkInCourt court,
    double screenWidth,
    double screenHeight,
  ) {
    final imageUrl = court.courtImages.isNotEmpty
        ? court.courtImages.first
        : null;

    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildImageFallback(screenWidth, screenHeight);
    }

    return Image.network(
      imageUrl,
                  fit: BoxFit.cover,
                  height: screenHeight * 0.25,
                  width: screenWidth,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildImageFallback(screenWidth, screenHeight);
                  },
                );
  }

  Widget _buildImageFallback(double screenWidth, double screenHeight) {
    return Image.asset(
      "assets/images/badminton_court.jpg",
      fit: BoxFit.cover,
      height: screenHeight * 0.25,
      width: screenWidth,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: screenHeight * 0.25,
          width: screenWidth,
          color: Colors.grey,
          child: const Icon(
            Icons.sports,
            size: 50,
            color: Colors.white54,
          ),
        );
      },
    );
  }
}
