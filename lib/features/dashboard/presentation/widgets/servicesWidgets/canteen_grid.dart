// lib/pages/detailsPages/widgets/classesWidgets/canteen_grid.dart

import 'package:flutter/material.dart';
import 'package:nyxproject/core/presentation/widgets/app_error_view.dart';
import 'package:nyxproject/features/dashboard/domain/entities/canteen.dart';
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

  static const Color _navy = Color(0xFF0D1B2A);
  static const Color _red = Color(0xFFEF3340);
  static const Color _muted = Color(0xFF7B8491);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: CircularProgressIndicator(color: _red, strokeWidth: 2.5),
        ),
      );
    }

    if (error != null) {
      return AppErrorView(message: error!, onRetry: onRetry);
    }

    if (items.isEmpty) {
      return _buildEmptyState();
    }

    final horizontalPadding = screenWidth < 360 ? 12.0 : 16.0;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 14,
        childAspectRatio: _calculateAspectRatio(screenWidth),
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return RepaintBoundary(
          child: CanteenCard(
            key: ValueKey(item.id),
            item: item,
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            onTap: () {},
          ),
        );
      },
    );
  }

  double _calculateAspectRatio(double width) {
    if (width < 360) return 0.68;
    if (width < 420) return 0.72;
    return 0.76;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: const Color(0xFFFDEBED),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.restaurant_menu_rounded,
                color: _red,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Menu Items Yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _navy,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Food and drinks will appear here when available.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _muted, fontSize: 13, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
