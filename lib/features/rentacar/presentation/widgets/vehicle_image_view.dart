import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/models/vehicle_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/rentcar_theme.dart';

/// Renders a [VehicleImage] regardless of where its bytes live.
///
/// Bundled asset, remote URL and freshly picked local file all go through the
/// same widget, with a fade-in, a shimmer-free loading placeholder and a
/// graceful error state — so a listing never shows a broken or empty frame.
class VehicleImageView extends StatelessWidget {
  const VehicleImageView({
    super.key,
    required this.image,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.showLabel = false,
  });

  final VehicleImage image;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  /// Shows the photo role ("Capa", "Interior") as an overlay chip.
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.zero;
    final content = _buildContent();

    final clipped = ClipRRect(
      borderRadius: radius,
      child: SizedBox(width: width, height: height, child: content),
    );

    if (!showLabel || image.label.isEmpty) return clipped;

    return Stack(
      children: [
        clipped,
        Positioned(
          left: 8,
          bottom: 8,
          child: _ImageLabel(text: image.label),
        ),
      ],
    );
  }

  Widget _buildContent() {
    switch (image.status) {
      case VehicleImageStatus.failed:
        return const _ImageFallback(message: 'Foto indisponível');
      case VehicleImageStatus.uploading:
      case VehicleImageStatus.pending:
        return const _ImageFallback(showSpinner: true);
      case VehicleImageStatus.uploaded:
        return switch (image.source) {
          VehicleImageSource.asset => Image.asset(
              image.path,
              fit: fit,
              width: width,
              height: height,
              errorBuilder: (_, _, _) =>
                  const _ImageFallback(message: 'Foto indisponível'),
            ),
          VehicleImageSource.network => Image.network(
              image.path,
              fit: fit,
              width: width,
              height: height,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const _ImageFallback(showSpinner: true);
              },
              errorBuilder: (_, _, _) =>
                  const _ImageFallback(message: 'Foto indisponível'),
            ),
          VehicleImageSource.localFile => Image.file(
              File(image.path),
              fit: fit,
              width: width,
              height: height,
              errorBuilder: (_, _, _) =>
                  const _ImageFallback(message: 'Foto indisponível'),
            ),
        };
    }
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({this.message, this.showSpinner = false});

  final String? message;
  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background =
        isDark ? AppColors.darkSurface : AppColors.surfaceVariant;
    final foreground =
        isDark ? AppColors.textOnDarkSecondary : AppColors.textTertiary;

    return ColoredBox(
      color: background,
      child: Center(
        child: showSpinner
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: RentCarColors.primary,
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.directions_car_outlined, size: 26, color: foreground),
                  if ((message ?? '').isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        message!,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.3,
                          color: foreground,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class _ImageLabel extends StatelessWidget {
  const _ImageLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(140),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}