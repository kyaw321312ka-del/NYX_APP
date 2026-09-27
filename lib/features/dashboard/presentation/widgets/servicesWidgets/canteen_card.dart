// lib/pages/detailsPages/classesWidgets/canteen_card.dart
import 'package:flutter/material.dart';
import 'package:nyxproject/features/dashboard/domain/Canteen.dart';

class CanteenCard extends StatelessWidget {
  final Canteen item;
  final double screenWidth;
  final double screenHeight;
  final VoidCallback? onTap;

  const CanteenCard({
    super.key,
    required this.item,
    required this.screenWidth,
    required this.screenHeight,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 13, 27, 42),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 2,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                child: item.imageUrl.isNotEmpty
                    ? Image.network(
                        item.imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade800,
                            child: const Icon(
                              Icons.fastfood,
                              size: 50,
                              color: Colors.white54,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey.shade800,
                        child: const Icon(
                          Icons.fastfood,
                          size: 50,
                          color: Colors.white54,
                        ),
                      ),
              ),
            ),
            // Product Info
            Container(
              padding: EdgeInsets.all(screenWidth * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontFamily: "Custom",
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.categoryName,
                    style: TextStyle(
                      fontFamily: "Custom",
                      fontSize: screenWidth * 0.035,
                      color: Colors.white70,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${item.price} Ks",
                        style: TextStyle(
                          fontFamily: "Custom",
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      if (!item.available)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade700,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "Sold Out",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}