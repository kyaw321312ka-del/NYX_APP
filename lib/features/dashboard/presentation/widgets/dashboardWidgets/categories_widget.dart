// lib/pages/dashboardWidgets/categories_widget.dart
import 'package:flutter/material.dart';
import 'package:nyxproject/features/shop/domain/Category.dart';
import 'package:nyxproject/features/shop/presentation/shoppages/categoryPage.dart';

class CategoriesWidget extends StatelessWidget {
  final List<Category> categories;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;

  const CategoriesWidget({
    super.key,
    required this.categories,
    required this.isLoading,
    this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return SizedBox(
        height: 100,
        child: Center(
          child: Text(
            error!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (categories.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(child: Text('No categories available')),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryPage(
                    categoryName: category.name,
                    categoryId: category.id,
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 15),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromARGB(255, 13, 27, 42),
                    ),
                    child: category.imageUrl.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              category.imageUrl,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.category,
                                  size: 40,
                                  color: Colors.white,
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons.category,
                            size: 40,
                            color: Colors.white,
                          ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 80,
                    child: Text(
                      category.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black,
                        fontFamily: 'Custom',
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}