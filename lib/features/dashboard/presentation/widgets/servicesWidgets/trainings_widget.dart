// lib/pages/detailsPages/classesWidgets/trainings_widget.dart

import 'package:flutter/material.dart';
import 'package:nyxproject/core/presentation/widgets/cors_safe_network_image.dart';
import 'package:nyxproject/core/presentation/widgets/app_error_view.dart';
import 'package:nyxproject/features/training/domain/entities/training.dart';
import 'package:nyxproject/features/training/presentation/pages/classes/class_details.dart';

class TrainingsWidget extends StatelessWidget {
  final List<Training> trainings;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;

  const TrainingsWidget({
    super.key,
    required this.trainings,
    required this.isLoading,
    this.error,
    required this.onRetry,
  });

  static const Color _navy = Color(0xFF0D1B2A);
  static const Color _red = Color(0xFFEF3340);
  static const Color _background = Color(0xFFF7F8FA);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(color: _red, strokeWidth: 2.5),
        ),
      );
    }

    if (error != null) {
      return AppErrorView(message: error!, onRetry: onRetry);
    }

    if (trainings.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      key: const ValueKey('training'),
      color: _background,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: trainings.length,
        separatorBuilder: (_, _) => const SizedBox(height: 18),
        itemBuilder: (context, index) {
          final training = trainings[index];

          return _buildTrainingCard(
            context,
            training.mainProgramBannerImageUrl,
            training.id,
          );
        },
      ),
    );
  }

  Widget _buildTrainingCard(
    BuildContext context,
    String imageUrl,
    int trainingId,
  ) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cacheWidth = (screenWidth * MediaQuery.devicePixelRatioOf(context))
        .round();

    return RepaintBoundary(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ClassDetails(trainingId: trainingId),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE9EDF2)),
              boxShadow: [
                BoxShadow(
                  color: _navy.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Training banner
                SizedBox(
                  height: 190,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildBannerImage(imageUrl, cacheWidth),

                      // Dark gradient for a polished banner.
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.02),
                              Colors.black.withValues(alpha: 0.05),
                              _navy.withValues(alpha: 0.72),
                            ],
                            stops: const [0.0, 0.35, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Card footer
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ready to improve?',
                              style: TextStyle(
                                color: _navy,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Explore this training program',
                              style: TextStyle(
                                color: Color(0xFF7B8491),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'View Details',
                        style: TextStyle(
                          color: _red,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBannerImage(String imageUrl, int cacheWidth) {
    if (imageUrl.trim().isEmpty) {
      return _buildFallbackImage();
    }

    return CorsSafeNetworkImage.network(
      imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      cacheWidth: cacheWidth,
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
    return Image.asset(
      'assets/classes/Badminton.png',
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (_, _, _) {
        return Container(
          color: _navy,
          child: const Center(
            child: Icon(
              Icons.sports_tennis_rounded,
              size: 64,
              color: Colors.white54,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 84,
              width: 84,
              decoration: BoxDecoration(
                color: const Color(0xFFFDEBED),
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Icon(
                Icons.sports_tennis_rounded,
                size: 40,
                color: _red,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Trainings Available',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _navy,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'There are no training programs to show right now. '
              'Please check back later.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF7B8491),
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
