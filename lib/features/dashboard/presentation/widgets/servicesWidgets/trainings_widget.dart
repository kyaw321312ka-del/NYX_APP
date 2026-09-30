// lib/pages/detailsPages/classesWidgets/trainings_widget.dart
import 'package:flutter/material.dart';
import 'package:nyxproject/features/training/domain/entities/Training.dart';
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: onRetry,
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

    if (trainings.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No trainings available'),
        ),
      );
    }

    final cacheWidth = (MediaQuery.sizeOf(context).width *
            MediaQuery.devicePixelRatioOf(context))
        .round();

    return Center(
      key: const ValueKey("training"),
      child: Column(
        children: List.generate(trainings.length, (index) {
          final training = trainings[index];
          return _buildTrainingCard(
            context,
            training.mainProgramBannerImageUrl,
            training.id,
            cacheWidth,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ClassDetails(
                  trainingId: training.id,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTrainingCard(
    BuildContext context,
    String imageUrl,
    int trainingId,
    int cacheWidth,
    VoidCallback onTap,
  ) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 180,
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 5,
                blurRadius: 5,
                offset: const Offset(7, 5),
              ),
            ],
          ),
          child: ClipRect(
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.fill,
                    width: double.infinity,
                    height: 180,
                    cacheWidth: cacheWidth,
                    gaplessPlayback: true,
                    filterQuality: FilterQuality.medium,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        "assets/classes/Badminton.png",
                        fit: BoxFit.fill,
                        width: double.infinity,
                        height: 180,
                      );
                    },
                  )
                : Image.asset(
                    "assets/classes/Badminton.png",
                    fit: BoxFit.fill,
                    width: double.infinity,
                    height: 180,
                  ),
          ),
        ),
      ),
    );
  }
}
