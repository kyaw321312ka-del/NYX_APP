// lib/pages/dashboardWidgets/section_header.dart
import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;
  final bool showSeeAll;

  const SectionHeader({
    super.key,
    required this.title,
    required this.onSeeAll,
    this.showSeeAll = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: 'Custom',
              fontSize: 18,
            ),
          ),
          if (showSeeAll)
            TextButton(
              onPressed: onSeeAll,
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text(
                "See All",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                  fontFamily: 'Custom',
                ),
              ),
            ),
        ],
      ),
    );
  }
}