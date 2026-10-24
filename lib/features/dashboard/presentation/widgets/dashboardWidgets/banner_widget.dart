import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class BannerWidget extends StatefulWidget {
  final List<String> images;
  final Function(int) onPageChanged;

  const BannerWidget({
    super.key,
    required this.images,
    required this.onPageChanged,
  });

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  static const Color _navy = Color(0xFF0D1B2A);
  static const Color _red = Color(0xFFEF3340);

  int currentIndex = 0;

  @override
  void didUpdateWidget(covariant BannerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.images.length != widget.images.length) {
      currentIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CarouselSlider.builder(
          itemCount: widget.images.length,
          itemBuilder: (context, index, realIndex) {
            final image = widget.images[index].trim();

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: _navy,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: _navy.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Banner image
                    if (image.isNotEmpty)
                      Image(
                        image: image.startsWith('http')
                            ? NetworkImage(image)
                            : AssetImage(image) as ImageProvider,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImageFallback();
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }

                          return Container(
                            color: _navy,
                            alignment: Alignment.center,
                            child: const SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                color: _red,
                                strokeWidth: 2.5,
                              ),
                            ),
                          );
                        },
                      )
                    else
                      _buildImageFallback(),

                    // Dark gradient for a cinematic banner look
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x08000000),
                            Color(0x20000000),
                            Color(0x66000000),
                          ],
                        ),
                      ),
                    ),

                    // Small NYX accent
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        width: 24,
                        height: 4,
                        decoration: BoxDecoration(
                          color: _red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          options: CarouselOptions(
            height: 190,
            viewportFraction: 0.94,
            enlargeCenterPage: false,
            autoPlay: widget.images.length > 1,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 700),
            autoPlayCurve: Curves.easeInOut,
            enableInfiniteScroll: widget.images.length > 1,
            pauseAutoPlayOnTouch: true,
            pauseAutoPlayOnManualNavigate: true,
            onPageChanged: (index, reason) {
              if (currentIndex != index) {
                setState(() {
                  currentIndex = index;
                });
              }

              widget.onPageChanged(index);
            },
          ),
        ),

        const SizedBox(height: 12),

        // Modern page indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.images.length, (index) {
            final isActive = currentIndex == index;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              width: isActive ? 22 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: isActive ? _red : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildImageFallback() {
    return Container(
      color: _navy,
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: Colors.white70, size: 42),
    );
  }
}
