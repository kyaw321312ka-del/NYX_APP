// lib/pages/detailsPages/widgets/servicesWidgets/rentals_widget.dart
import 'package:flutter/material.dart';
import 'package:nyxproject/features/rental/domain/entities/Venue.dart';
import 'package:nyxproject/features/rental/presentation/pages/rental/Courts.dart';

class RentalsWidget extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final List<Venue> venues;
  final bool isLoadingVenues;
  final String? venuesError;
  final VoidCallback onRetryVenues;

  const RentalsWidget({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.venues,
    required this.isLoadingVenues,
    this.venuesError,
    required this.onRetryVenues,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: const Text(
              "Court Rentals",
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
              "Book your own private court.",
              style: TextStyle(
                fontSize: 15,
                fontFamily: "Custom",
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildVenueList(context),
          const SizedBox(height: 10),
        ],
        key: const ValueKey("rentals"),
      ),
    );
  }

  Widget _buildVenueList(BuildContext context) {
    if (isLoadingVenues) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (venuesError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                venuesError!,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: onRetryVenues,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (venues.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No venues available'),
        ),
      );
    }

    return Column(
      children: venues.map((venue) {
        return _buildVenueCard(context, venue);
      }).toList(),
    );
  }

  Widget _buildVenueCard(BuildContext context, Venue venue) {
    return GestureDetector(
      onTap: () {
        // Navigate to Courts page with venueId and venueName
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Courts(
              venueId: venue.id,
              venueName: venue.venueName,
            ),
          ),
        );
      },
      child: Container(
        height: screenHeight * 0.45,
        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.0125, vertical: screenHeight * 0.01),
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
                child: venue.venueImageUrl.isNotEmpty
                    ? Image.network(
                        venue.venueImageUrl,
                        fit: BoxFit.cover,
                        height: screenHeight * 0.3,
                        width: screenWidth,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: screenHeight * 0.3,
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
                        height: screenHeight * 0.3,
                        width: screenWidth,
                        color: Colors.grey,
                        child: const Icon(
                          Icons.sports,
                          size: 50,
                          color: Colors.white54,
                        ),
                      ),
              ),
            ),
            Positioned(
              left: screenWidth * 0.025,
              bottom: screenHeight * 0.07,
              child: Text(
                venue.venueName,
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
              bottom: screenHeight * 0.07,
              child: Text(
                "${venue.price.toString()} Ks",
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
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
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
}