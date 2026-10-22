// lib/pages/detailsPages/widgets/servicesWidgets/rentals_widget.dart

import 'package:flutter/material.dart';
import 'package:nyxproject/core/presentation/widgets/app_error_view.dart';
import 'package:nyxproject/features/rental/domain/entities/venue.dart';
import 'package:nyxproject/features/rental/presentation/pages/rental/courts.dart';

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

  static const Color _navy = Color(0xFF0D1B2A);
  static const Color _red = Color(0xFFEF3340);
  static const Color _background = Color(0xFFF7F8FA);
  static const Color _muted = Color(0xFF7B8491);

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('rentals'),
      color: _background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildVenueList(context), const SizedBox(height: 20)],
      ),
    );
  }

  Widget _buildVenueList(BuildContext context) {
    if (isLoadingVenues) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(36),
          child: CircularProgressIndicator(color: _red, strokeWidth: 2.5),
        ),
      );
    }

    if (venuesError != null) {
      return AppErrorView(message: venuesError!, onRetry: onRetryVenues);
    }

    if (venues.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: venues.length,
      separatorBuilder: (_, _) => const SizedBox(height: 18),
      itemBuilder: (context, index) {
        return _buildVenueCard(context, venues[index]);
      },
    );
  }

  Widget _buildVenueCard(BuildContext context, Venue venue) {
    final imageHeight = (screenWidth * 0.48).clamp(170.0, 230.0);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openVenue(context, venue),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE9EDF2)),
            boxShadow: [
              BoxShadow(
                color: _navy.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Venue image and overlay
              SizedBox(
                height: imageHeight,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildVenueImage(venue.venueImageUrl),

                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.12),
                            Colors.transparent,
                            _navy.withValues(alpha: 0.78),
                          ],
                          stops: const [0.0, 0.42, 1.0],
                        ),
                      ),
                    ),

                    // Rental badge

                    // Venue name
                    Positioned(
                      left: 17,
                      right: 17,
                      bottom: 17,
                      child: Text(
                        venue.venueName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                          letterSpacing: -0.3,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Price and action
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDEBED),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.payments_outlined,
                        color: _red,
                        size: 23,
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Starting price',
                            style: TextStyle(
                              color: _muted,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${venue.price} Ks',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _navy,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _red,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View Courts',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 15,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVenueImage(String imageUrl) {
    if (imageUrl.trim().isEmpty) {
      return _buildFallbackImage();
    }

    return Image.network(
      imageUrl,
      width: double.infinity,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, _, _) => _buildFallbackImage(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return Container(
          color: const Color(0xFFE9EDF2),
          child: const Center(
            child: CircularProgressIndicator(color: _red, strokeWidth: 2),
          ),
        );
      },
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      color: _navy,
      child: const Center(
        child: Icon(
          Icons.sports_tennis_rounded,
          color: Colors.white54,
          size: 60,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 82,
              width: 82,
              decoration: BoxDecoration(
                color: const Color(0xFFFDEBED),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.sports_tennis_rounded,
                color: _red,
                size: 40,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No Venues Available',
              style: TextStyle(
                color: _navy,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'There are no court rental venues available right now. '
              'Please check again later.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _muted, fontSize: 13, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  void _openVenue(BuildContext context, Venue venue) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Courts(venueId: venue.id, venueName: venue.venueName),
      ),
    );
  }
}
