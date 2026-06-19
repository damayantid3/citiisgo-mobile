import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerPlaceholder extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const ShimmerPlaceholder({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFE2E8F0), // Slate 200
        highlightColor: const Color(0xFFF1F5F9), // Slate 100
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}

class ShimmerCardList extends StatelessWidget {
  final int itemCount;
  final double height;

  const ShimmerCardList({
    super.key,
    this.itemCount = 3,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Row(
            children: [
              ShimmerPlaceholder(width: 80, height: 80, borderRadius: 12),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerPlaceholder(width: 140, height: 16, borderRadius: 4),
                    SizedBox(height: 8),
                    ShimmerPlaceholder(width: 180, height: 12, borderRadius: 4),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ShimmerPlaceholder(width: 40, height: 12, borderRadius: 4),
                        ShimmerPlaceholder(width: 70, height: 14, borderRadius: 4),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ShimmerGridPopular extends StatelessWidget {
  final int itemCount;

  const ShimmerGridPopular({
    super.key,
    this.itemCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Container(
            width: 145,
            margin: const EdgeInsets.only(left: 20, right: 4),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerPlaceholder(width: double.infinity, height: 90, borderRadius: 12),
                SizedBox(height: 10),
                ShimmerPlaceholder(width: 100, height: 12, borderRadius: 4),
                SizedBox(height: 6),
                ShimmerPlaceholder(width: 70, height: 10, borderRadius: 4),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerPlaceholder(width: 30, height: 10, borderRadius: 4),
                    ShimmerPlaceholder(width: 50, height: 10, borderRadius: 4),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
