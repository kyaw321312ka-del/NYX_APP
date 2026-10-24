import 'package:flutter/material.dart';
import 'package:nyxproject/core/presentation/widgets/app_error_view.dart';
import 'package:nyxproject/features/shop/domain/entities/category.dart';
import 'package:nyxproject/features/shop/presentation/pages/shoppages/category_page.dart';

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

  static const Color _red = Color(0xFFEF3340);
  static const Color _muted = Color(0xFF7B8491);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 124,
        child: Center(
          child: SizedBox(
            width: 25,
            height: 25,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: _red),
          ),
        ),
      );
    }

    if (error != null) {
      return SizedBox(
        height: 124,
        child: AppErrorView(message: error!, onRetry: onRetry, compact: true),
      );
    }

    if (categories.isEmpty) {
      return SizedBox(
        height: 124,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.category_outlined,
                size: 28,
                color: _muted.withValues(alpha: 0.8),
              ),
              const SizedBox(height: 6),
              const Text(
                'No categories available',
                style: TextStyle(
                  color: _muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final category = categories[index];

          return _CategoryItem(
            category: category,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoryPage(
                    categoryName: category.name,
                    categoryId: category.id,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const _CategoryItem({required this.category, required this.onTap});

  static const Color _navy = Color(0xFF0D1B2A);
  static const Color _red = Color(0xFFEF3340);
  @override
  Widget build(BuildContext context) {
    final imageUrl = category.imageUrl.trim();

    return SizedBox(
      width: 82,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 4),
            child: Column(
              children: [
                // Category image
                Container(
                  width: 76,
                  height: 76,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFFE5EAF0),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _navy.withValues(alpha: 0.07),
                        blurRadius: 9,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(color: _navy),

                        if (imageUrl.isNotEmpty)
                          Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }

                              return const Center(
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.category_rounded,
                                  size: 30,
                                  color: Colors.white,
                                ),
                              );
                            },
                          )
                        else
                          const Center(
                            child: Icon(
                              Icons.category_rounded,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 9),

                // Category name
                Text(
                  category.name.trim(),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 11,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                // Small brand accent
                Container(
                  width: 16,
                  height: 2,
                  decoration: BoxDecoration(
                    color: _red,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
