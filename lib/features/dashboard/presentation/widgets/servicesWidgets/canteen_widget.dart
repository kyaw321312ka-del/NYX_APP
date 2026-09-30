// lib/pages/detailsPages/classesWidgets/canteen_widget.dart
import 'package:flutter/material.dart';
import 'package:nyxproject/features/dashboard/domain/entities/Canteen.dart';
import 'package:nyxproject/features/dashboard/presentation/widgets/servicesWidgets/canteen_grid.dart';

class CanteenWidget extends StatelessWidget {
  final List<Canteen> items;
  final double screenWidth;
  final double screenHeight;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;

  const CanteenWidget({
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
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _canteenHeader(),
          CanteenGrid(
            items: items,
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            isLoading: isLoading,
            error: error,
            onRetry: onRetry,
          ),
          const SizedBox(height: 10),
        ],
        key: const ValueKey("canteen"),
      ),
    );
  }

  Widget _canteenHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Canteen Menu",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: 'Custom',
            ),
          ),
          if (items.isNotEmpty)
            Text(
              '${items.length} items',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontFamily: 'Custom',
              ),
            ),
        ],
      ),
    );
  }
}