import 'package:flutter/material.dart';

/// Gambar dari internet + tampilan loading & error.
class NetworkImageBox extends StatelessWidget {
  final String? url;
  final double height;
  final double? width;
  final BorderRadius borderRadius;

  const NetworkImageBox({
    super.key,
    required this.url,
    this.height = 160,
    this.width,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      height: height,
      width: width ?? double.infinity,
      color: Colors.grey.shade300,
      child: const Icon(Icons.home_work_outlined, size: 40, color: Colors.grey),
    );

    if (url == null || url!.isEmpty) {
      return ClipRRect(borderRadius: borderRadius, child: placeholder);
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.network(
        url!,
        height: height,
        width: width ?? double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            height: height,
            width: width ?? double.infinity,
            child: const Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (context, error, stackTrace) => placeholder,
      ),
    );
  }
}