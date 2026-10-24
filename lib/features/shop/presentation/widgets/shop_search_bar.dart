import 'package:flutter/material.dart';

class ShopSearchBar extends StatelessWidget {
  const ShopSearchBar({
    required this.controller,
    required this.onQueryChanged,
    required this.onSortTap,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onSortTap;

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0D1B2A);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, child) {
          return TextField(
            controller: controller,
            onChanged: onQueryChanged,
            style: const TextStyle(color: navy, fontSize: 14),
            cursorColor: navy,
            decoration: InputDecoration(
              hintText: 'Search products...',
              hintStyle: const TextStyle(
                color: Color(0xFF89909C),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: navy,
                size: 23,
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Filter or sort',
                    icon: const Icon(Icons.tune_rounded, color: navy, size: 22),
                    onPressed: onSortTap,
                  ),
                  if (value.text.isNotEmpty)
                    IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF737B89),
                        size: 20,
                      ),
                      onPressed: () {
                        controller.clear();
                        onQueryChanged('');
                      },
                    ),
                ],
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFFD8DDE5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFFD8DDE5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: navy, width: 1.3),
              ),
            ),
          );
        },
      ),
    );
  }
}
