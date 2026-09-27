// lib/pages/detailsPages/widgets/classesWidgets/canteen_grid.dart
import 'package:flutter/material.dart';
import 'package:nyxproject/features/dashboard/domain/Canteen.dart';
import 'package:nyxproject/features/dashboard/presentation/widgets/servicesWidgets/canteen_card.dart';

class CanteenGrid extends StatelessWidget {
  final List<Canteen> items;
  final double screenWidth;
  final double screenHeight;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;

  const CanteenGrid({
    super.key,
    required this.items,
    required this.screenWidth,
    required this.screenHeight,
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

    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No canteen items available'),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.02,
        vertical: screenHeight * 0.01,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return CanteenCard(
          item: item,
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          onTap: () {
            print('Tapped on: ${item.name}');
          },
        );
      },
    );
  }
}