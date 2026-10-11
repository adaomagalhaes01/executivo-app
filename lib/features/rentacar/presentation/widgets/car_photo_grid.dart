import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/models/vehicle_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/rentcar_theme.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'vehicle_image_view.dart';

/// Captures photos of a vehicle and turns them into [VehicleImage] entries.
///
/// Images are resized and re-encoded by the picker itself
/// (`maxWidth`/`imageQuality`), which keeps large camera files out of memory
/// without pulling in an image-processing dependency. The first photo added
/// automatically becomes the cover.
class VehiclePhotoManager {
  VehiclePhotoManager({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  /// Downscale applied on device before the bytes ever reach the widget tree.
  static const double maxEdge = 1600;
  static const int jpegQuality = 82;

  final ImagePicker _picker;

  /// Photo roles suggested to the owner, in listing order.
  static const List<String> suggestions = [
    'Frente',
    'Traseira',
    'Lateral',
    'Interior',
    'Painel',
    'Bagageira',
  ];

  static const int maxPhotos = 10;

  Future<List<VehicleImage>> pickFromGallery() =>
      _pick(ImageSource.gallery);

  Future<List<VehicleImage>> takePhoto() => _pick(ImageSource.camera);

  Future<List<VehicleImage>> _pick(ImageSource source) async {
    final files = await _picker.pickMultiImage(
      imageQuality: jpegQuality,
      maxWidth: maxEdge,
      maxHeight: maxEdge,
    );
    if (files.isEmpty) return const [];

    final remaining = maxPhotos;
    return files.take(remaining).map(_toVehicleImage).toList();
  }

  Future<VehicleImage?> pickCoverReplacement() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: jpegQuality,
      maxWidth: maxEdge,
      maxHeight: maxEdge,
    );
    if (file == null) return null;
    return _toVehicleImage(file);
  }

  VehicleImage _toVehicleImage(XFile file) => VehicleImage(
        id: 'local_${DateTime.now().microsecondsSinceEpoch}_${file.name}',
        source: VehicleImageSource.localFile,
        path: file.path,
        label: '',
        status: VehicleImageStatus.uploaded,
      );
}

/// Grid of vehicle photographs with add, remove, reorder and cover selection.
///
/// Stateful on purpose: drag-to-reorder needs a stable per-frame snapshot while
/// the gesture is in flight, and the mutations are pushed upwards through
/// [onChanged] so the draft stays the single source of truth.
class CarPhotoGrid extends StatefulWidget {
  const CarPhotoGrid({
    super.key,
    required this.images,
    required this.onChanged,
    this.onAdd,
    this.onError,
  });

  final List<VehicleImage> images;
  final ValueChanged<List<VehicleImage>> onChanged;
  final Future<void> Function()? onAdd;
  final ValueChanged<String>? onError;

  @override
  State<CarPhotoGrid> createState() => _CarPhotoGridState();
}

class _CarPhotoGridState extends State<CarPhotoGrid> {
  static const double _tileSize = 104;
  int? _draggingIndex;
  int? _hoverIndex;

  @override
  Widget build(BuildContext context) {
    final canAdd = widget.images.length < VehiclePhotoManager.maxPhotos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.images.isEmpty)
          _EmptyDropzone(onTap: widget.onAdd)
        else
          SizedBox(
            height: _tileSize,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: widget.images.length + (canAdd ? 1 : 0),
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
itemBuilder: (context, index) {
                  if (index == widget.images.length) {
                    return _AddTile(onTap: widget.onAdd);
                  }
                  final image = widget.images[index];
                  return DragTarget<int>(
                    onWillAcceptWithDetails: (details) {
                      if (details.data == index) return false;
                      setState(() => _hoverIndex = index);
                      return true;
                    },
                    onLeave: (_) => setState(() => _hoverIndex = null),
                    onAcceptWithDetails: (details) {
                      _reorder(details.data, index);
                      setState(() => _hoverIndex = null);
                    },
                    builder: (context, candidate, rejected) => _PhotoTile(
                      image: image,
                      index: index,
                      size: _tileSize,
                      isHovered: candidate.isNotEmpty,
                      isDragging: _draggingIndex == index,
                      onRemove: () => _removeAt(index),
                      onMakeCover: () => _makeCover(index),
                      onDragStarted: () => _startDrag(index),
                      onDragEnded: _endDrag,
                    ),
                  );
                },
              ),
            ),
        const SizedBox(height: AppSpacing.md),
        _PhotoHint(count: widget.images.length),
      ],
    );
  }

  void _removeAt(int index) {
    final next = [...widget.images]..removeAt(index);
    // Keep exactly one cover: fall back to the first photo if we removed it.
    if (!next.any((image) => image.isCover) && next.isNotEmpty) {
      next[0] = next[0].asCover();
    }
    widget.onChanged(next);
  }

  void _makeCover(int index) {
    widget.onChanged([
      for (var i = 0; i < widget.images.length; i++)
        widget.images[i].copyWith(isCover: i == index),
    ]);
  }

  /// Moves the photo at [from] to position [to], keeping the cover flag with
  /// its photo so reordering never changes which frame is the hero image.
  void _reorder(int from, int to) {
    if (from == to) return;
    final next = [...widget.images];
    final moved = next.removeAt(from);
    next.insert(to, moved);
    widget.onChanged(next);
  }

  void _startDrag(int index) {
    setState(() => _draggingIndex = index);
    HapticFeedback.selectionClick();
  }

  void _endDrag() {
    if (_draggingIndex == null && _hoverIndex == null) return;
    setState(() {
      _draggingIndex = null;
      _hoverIndex = null;
    });
  }
}

class _EmptyDropzone extends StatelessWidget {
  const _EmptyDropzone({required this.onTap});

  final Future<void> Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkElevated : AppColors.border;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.circularLg,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
          decoration: BoxDecoration(
            borderRadius: AppRadius.circularLg,
            border: Border.all(color: borderColor, width: 1.5),
            color: (isDark ? AppColors.darkSurface : AppColors.surface)
                .withAlpha(isDark ? 140 : 200),
          ),
          child: Column(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: RentCarColors.primary.withAlpha(22),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_a_photo_outlined,
                  color: RentCarColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Adicionar fotos do carro',
                style: AppTextStyles.titleSm.copyWith(
                  color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'A primeira foto será a capa do anúncio',
                style: AppTextStyles.caption.copyWith(
                  color: isDark
                      ? AppColors.textOnDarkSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap});

  final Future<void> Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: 104,
      child: Material(
        color: RentCarColors.primary.withAlpha(isDark ? 24 : 14),
        borderRadius: AppRadius.circularLg,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.circularLg,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: AppRadius.circularLg,
              border: Border.all(
                color: RentCarColors.primary.withAlpha(90),
                width: 1.2,
              ),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_rounded, color: RentCarColors.primary, size: 24),
                SizedBox(height: 4),
                Text(
                  'Adicionar',
                  style: TextStyle(
                    color: RentCarColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
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

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.image,
    required this.index,
    required this.size,
    required this.onRemove,
    required this.onMakeCover,
    required this.isDragging,
    required this.isHovered,
    required this.onDragStarted,
    required this.onDragEnded,
  });

  final VehicleImage image;
  final int index;
  final double size;
  final VoidCallback onRemove;
  final VoidCallback onMakeCover;
  final bool isDragging;
  final bool isHovered;
  final VoidCallback onDragStarted;
  final VoidCallback onDragEnded;

  @override
  Widget build(BuildContext context) {
    final tile = Stack(
      children: [
        VehicleImageView(
          image: image,
          width: size,
          height: size,
          borderRadius: AppRadius.circularLg,
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            borderRadius: AppRadius.circularLg,
            child: InkWell(
              borderRadius: AppRadius.circularLg,
              onTap: image.isCover ? null : onMakeCover,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: AppRadius.circularLg,
                  border: Border.all(
                    color: isHovered
                        ? RentCarColors.primary
                        : (image.isCover
                            ? RentCarColors.primary
                            : Colors.white.withAlpha(40)),
                    width: image.isCover || isHovered ? 2.5 : 1,
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: Material(
            color: Colors.black.withAlpha(150),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onRemove,
              child: const Padding(
                padding: EdgeInsets.all(3),
                child: Icon(
                  Icons.close_rounded,
                  size: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        if (image.isCover)
          Positioned(
            left: 0,
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 3),
              decoration: const BoxDecoration(
                color: RentCarColors.primary,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(15),
                ),
              ),
              child: const Text(
                'CAPA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        if (!image.isCover)
          const Positioned(
            left: 4,
            top: 4,
            child: Icon(
              Icons.drag_indicator_rounded,
              size: 15,
              color: Colors.white70,
            ),
          ),
      ],
    );

    return LongPressDraggable<int>(
      data: index,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      onDragStarted: onDragStarted,
      onDragEnd: (_) => onDragEnded(),
      onDraggableCanceled: (_, _) => onDragEnded(),
      feedback: Material(
        color: Colors.transparent,
        elevation: 8,
        borderRadius: AppRadius.circularLg,
        child: SizedBox(
          width: size,
          height: size,
          child: VehicleImageView(
            image: image,
            width: size,
            height: size,
            borderRadius: AppRadius.circularLg,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: tile,
      ),
      child: tile,
    );
  }
}

class _PhotoHint extends StatelessWidget {
  const _PhotoHint({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color =
        isDark ? AppColors.textOnDarkSecondary : AppColors.textTertiary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline_rounded, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            count == 0
                ? 'Adicione pelo menos uma fotografia para publicar.'
                : 'Toque para escolher a capa. Sugestões: ${VehiclePhotoManager.suggestions.take(5).join(', ')}.',
            style: AppTextStyles.captionSm.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}