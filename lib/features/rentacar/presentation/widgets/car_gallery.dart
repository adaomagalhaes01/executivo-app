import 'package:flutter/material.dart';

import '../../../../core/models/vehicle_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/rentcar_theme.dart';
import '../../../../core/theme/app_spacing.dart';
import 'vehicle_image_view.dart';

/// Swipeable photo gallery used on the vehicle detail screen.
///
/// Horizontally paged photographs, a dot indicator and tap-to-open fullscreen
/// viewing. The current index is reported upwards so the detail screen can
/// keep its own state in sync.
class CarGallery extends StatefulWidget {
  const CarGallery({
    super.key,
    required this.images,
    this.height = 300,
    this.onIndexChanged,
    this.heroPrefix,
  });

  final List<VehicleImage> images;
  final double height;
  final ValueChanged<int>? onIndexChanged;

  /// Prefix for the hero tags, letting the first frame morph from the card.
  final String? heroPrefix;

  @override
  State<CarGallery> createState() => _CarGalleryState();
}

class _CarGalleryState extends State<CarGallery> {
  late final PageController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) return SizedBox(height: widget.height);

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: Stack(
            children: [
              PageView.builder(
                controller: _controller,
                itemCount: widget.images.length,
                onPageChanged: (index) {
                  setState(() => _index = index);
                  widget.onIndexChanged?.call(index);
                },
                itemBuilder: (context, index) {
                  final image = widget.images[index];
                  final frame = GestureDetector(
                    onTap: () => _openFullscreen(context, index),
                    child: VehicleImageView(
                      image: image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: widget.height,
                    ),
                  );
                  if (index != 0 || widget.heroPrefix == null) return frame;
                  return Hero(
                    tag: '${widget.heroPrefix}_${image.id}',
                    child: frame,
                  );
                },
              ),
              Positioned(
                top: AppSpacing.md,
                left: AppSpacing.md,
                child: _GalleryChip(
                  icon: Icons.photo_library_outlined,
                  label: '${widget.images.length} fotos',
                ),
              ),
              if (widget.images.length > 1)
                Positioned(
                  right: AppSpacing.md,
                  bottom: AppSpacing.lg,
                  child: _ExpandButton(
                    onTap: () => _openFullscreen(context, _index),
                  ),
                ),
            ],
          ),
        ),
        if (widget.images.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: _DotIndicator(
              count: widget.images.length,
              index: _index,
            ),
          ),
      ],
    );
  }

  void _openFullscreen(BuildContext context, int index) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        transitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (_, animation, _) => RentCarTheme.wrap(
          FadeTransition(
            opacity: animation,
            child: _FullscreenGallery(
              images: widget.images,
              initialIndex: index,
            ),
          ),
        ),
      ),
    );
  }
}

class _FullscreenGallery extends StatefulWidget {
  const _FullscreenGallery({required this.images, required this.initialIndex});

  final List<VehicleImage> images;
  final int initialIndex;

  @override
  State<_FullscreenGallery> createState() => _FullscreenGalleryState();
}

class _FullscreenGalleryState extends State<_FullscreenGallery> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (index) => setState(() => _index = index),
            itemBuilder: (context, index) => InteractiveViewer(
              maxScale: 4,
              child: Center(
                child: VehicleImageView(
                  image: widget.images[index],
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Positioned(
            top: AppSpacing.xl,
            left: AppSpacing.md,
            child: _RoundOverlayButton(
              icon: Icons.close_rounded,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            top: AppSpacing.xl,
            right: AppSpacing.md,
            child: _RoundOverlayButton(
              icon: Icons.photo_library_outlined,
              onTap: () {},
            ),
          ),
          if (widget.images.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: AppSpacing.xl,
              child: Column(
                children: [
                  if (widget.images[_index].label.isNotEmpty)
                    Text(
                      widget.images[_index].label.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  const SizedBox(height: AppSpacing.sm),
                  _DotIndicator(
                    count: widget.images.length,
                    index: _index,
                    activeColor: RentCarColors.primary,
                    inactiveColor: AppColors.border,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RoundOverlayButton extends StatelessWidget {
  const _RoundOverlayButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceVariant,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: AppColors.textPrimary, size: 20),
        ),
      ),
    );
  }
}

class _ExpandButton extends StatelessWidget {
  const _ExpandButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withAlpha(120),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(
            Icons.fullscreen_rounded,
            size: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _GalleryChip extends StatelessWidget {
  const _GalleryChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(130),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({
    required this.count,
    required this.index,
    this.activeColor = RentCarColors.primary,
    this.inactiveColor,
  });

  final int count;
  final int index;
  final Color activeColor;
  final Color? inactiveColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final idle = inactiveColor ??
        (isDark ? AppColors.darkElevated : AppColors.border);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 20 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: active ? activeColor : idle,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
