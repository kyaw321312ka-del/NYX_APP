import 'package:flutter/material.dart';
import 'package:nyxproject/core/error/app_error_message.dart';
import 'package:nyxproject/core/presentation/widgets/app_error_view.dart';
import 'package:nyxproject/features/rental/data/datasources/RentelApi/walk_in_court_api.dart';
import 'package:nyxproject/features/rental/domain/entities/walk_in_court.dart'
    as model;
import 'package:nyxproject/features/rental/presentation/pages/walkin/walkin_court.dart'
    as walkin_details;

class WalkInScreen extends StatefulWidget {
  const WalkInScreen({super.key});

  @override
  State<WalkInScreen> createState() => _WalkInScreenState();
}

class _WalkInScreenState extends State<WalkInScreen> {
  static const Color _navy = Color(0xFF0D1B2A);
  static const Color _red = Color(0xFFEF3340);
  static const Color _background = Color(0xFFF7F8FA);
  static const Color _muted = Color(0xFF778191);

  List<model.WalkInCourt> courts = [];
  String? selectedVenue;
  String? errorMessage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourts();
  }

  Future<void> _loadCourts() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await WalkInCourtApi.getWalkInCourts();

      if (!mounted) return;

      if (result['success'] == true) {
        final loadedCourts = List<model.WalkInCourt>.from(result['data'] ?? []);

        setState(() {
          courts = loadedCourts;
          isLoading = false;

          if (selectedVenue != null &&
              !courts.any((court) => court.venueName == selectedVenue)) {
            selectedVenue = null;
          }
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = AppErrorMessage.from(
            result['message']?.toString() ?? 'Failed to load courts',
          );
        });
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = AppErrorMessage.from(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final venues =
        courts
            .map((court) => court.venueName)
            .where((venue) => venue.trim().isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    final filteredCourts = selectedVenue == null
        ? courts
        : courts.where((court) => court.venueName == selectedVenue).toList();

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadCourts,
          color: _red,
          backgroundColor: Colors.white,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 24, 18, 16),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isLoading && errorMessage == null) ...[
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Available courts',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: _navy,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Text(
                                '${filteredCourts.length} courts',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _muted,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        if (venues.isNotEmpty) _buildVenueFilter(venues),
                      ],
                    ],
                  ),
                ),
              ),

              if (isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator(color: _red)),
                )
              else if (errorMessage != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: AppErrorView(
                        message: errorMessage!,
                        onRetry: _loadCourts,
                      ),
                    ),
                  ),
                )
              else if (filteredCourts.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: _buildCourtCard(filteredCourts[index]),
                      );
                    }, childCount: filteredCourts.length),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVenueFilter(List<String> venues) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, color: _muted, size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: selectedVenue,
                isExpanded: true,
                hint: const Text('All venues'),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: _navy,
                ),
                borderRadius: BorderRadius.circular(14),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All venues'),
                  ),
                  ...venues.map(
                    (venue) => DropdownMenuItem<String?>(
                      value: venue,
                      child: Text(venue, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
                onChanged: (venue) {
                  setState(() => selectedVenue = venue);
                },
              ),
            ),
          ),
          if (selectedVenue != null)
            IconButton(
              tooltip: 'Clear filter',
              onPressed: () {
                setState(() => selectedVenue = null);
              },
              icon: const Icon(Icons.close_rounded, size: 19),
              color: _muted,
            ),
        ],
      ),
    );
  }

  Widget _buildCourtCard(model.WalkInCourt court) {
    final imageUrl = court.courtImages.isNotEmpty
        ? court.courtImages.first
        : null;

    final price = court.walkInPrice == null
        ? 'Price unavailable'
        : '${court.walkInPrice} Ks';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => walkin_details.WalkInCourt(court: court),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE8EAF0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 210,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildCourtImage(imageUrl),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.04),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.68),
                          ],
                          stops: const [0, 0.38, 1],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 14,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.sports_tennis_rounded,
                              color: _red,
                              size: 15,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'WALK-IN',
                              style: TextStyle(
                                color: _navy,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.7,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            court.venueName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            court.courtName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 15, 12, 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Walk-in price',
                            style: TextStyle(fontSize: 12, color: _muted),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            price,
                            style: const TextStyle(
                              color: _navy,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Show Details',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 7),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 16,
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

  Widget _buildCourtImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildImageFallback();
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, error, stackTrace) => _buildImageFallback(),
    );
  }

  Widget _buildImageFallback() {
    return Container(
      color: _navy,
      alignment: Alignment.center,
      child: const Icon(
        Icons.sports_tennis_rounded,
        color: Colors.white54,
        size: 54,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.sports_tennis_rounded,
                size: 36,
                color: _muted,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              selectedVenue == null
                  ? 'No courts available'
                  : 'No courts at this venue',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _navy,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please check again later or choose another venue.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: _muted, height: 1.5),
            ),
            if (selectedVenue != null) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => selectedVenue = null),
                child: const Text(
                  'View all venues',
                  style: TextStyle(color: _red, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
