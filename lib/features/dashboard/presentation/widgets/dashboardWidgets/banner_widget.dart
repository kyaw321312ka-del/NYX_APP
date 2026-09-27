// lib/pages/dashboardWidgets/banner_widget.dart
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
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CarouselSlider(
          items: widget.images
              .map(
                (item) => Container(
                  margin: const EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: item.startsWith('http')
                          ? NetworkImage(item)
                          : AssetImage(item) as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )
              .toList(),
          options: CarouselOptions(
            height: 180,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 900),
            enlargeCenterPage: true,
            aspectRatio: 16 / 9,
            viewportFraction: 1,
            onPageChanged: (index, reason) {
              setState(() {
                currentIndex = index;
              });
              widget.onPageChanged(index);
            },
          ),
        ),
        if (widget.images.isNotEmpty) const SizedBox(height: 5),
        if (widget.images.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.images
                .asMap()
                .entries
                .map(
                  (item) => Container(
                    height: 7,
                    width: 7,
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: currentIndex == item.key
                          ? Colors.black
                          : Colors.grey,
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}
