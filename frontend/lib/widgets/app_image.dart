import 'package:flutter/material.dart';
import '../services/cloudinary_images.dart';

/// Cloud images retain the bundled original as an offline/error fallback.
class AppImage extends StatelessWidget {
  final String source;
  final double? width, height;
  final BoxFit? fit;
  final AlignmentGeometry alignment;
  final Color? color;
  final BlendMode? colorBlendMode;
  final ImageErrorWidgetBuilder? errorBuilder;
  const AppImage.asset(
    this.source, {
    super.key,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
    this.color,
    this.colorBlendMode,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final bundledSource = source.startsWith('assets/')
        ? source
        : cloudinaryImages.entries
              .where((entry) => entry.value == source)
              .map((entry) => entry.key)
              .firstOrNull;
    Widget fallback(BuildContext context, Object error, StackTrace? stack) {
      if (bundledSource != null) {
        return Image.asset(
          bundledSource,
          width: width,
          height: height,
          fit: fit,
          alignment: alignment,
          color: color,
          colorBlendMode: colorBlendMode,
          errorBuilder: errorBuilder,
        );
      }
      return errorBuilder?.call(context, error, stack) ??
          SizedBox(
            width: width,
            height: height,
            child: const Icon(Icons.broken_image_outlined),
          );
    }

    final url = cloudinaryImages[source] ?? source;
    if (url.startsWith('https://') || url.startsWith('http://')) {
      return Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        color: color,
        colorBlendMode: colorBlendMode,
        errorBuilder: fallback,
      );
    }
    return Image.asset(
      source,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      color: color,
      colorBlendMode: colorBlendMode,
      errorBuilder: errorBuilder,
    );
  }
}
