// lib/pages/detailsPages/classesWidgets/canteen_widget.dart

import 'package:flutter/material.dart';
import 'package:nyxproject/features/dashboard/domain/entities/canteen.dart';
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

  static const Color _background = Color(0xFFF7F8FA);

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('canteen'),
      width: double.infinity,
      color: _background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CanteenGrid(
            items: items,
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            isLoading: isLoading,
            error: error,
            onRetry: onRetry,
          ),
        ],
      ),
    );
  }
}
