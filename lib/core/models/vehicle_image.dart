/// Where the bytes of a [VehicleImage] live.
enum VehicleImageSource {
  /// Bundled with the app (used by the seeded mock catalogue).
  asset,

  /// Remote URL returned by the storage layer (Supabase Storage, etc.).
  network,

  /// Absolute path of a file picked from the device gallery or camera.
  localFile,
}

/// Upload lifecycle of a single photograph.
enum VehicleImageStatus { pending, uploading, uploaded, failed }

/// A single photograph belonging to a vehicle.
///
/// Every car owns a list of these instead of a single delimited string so the
/// model can later be mapped straight onto a storage bucket: each entry keeps
/// its own id, its own remote path and its own upload state.
class VehicleImage {
  const VehicleImage({
    required this.id,
    required this.source,
    required this.path,
    this.label = '',
    this.status = VehicleImageStatus.uploaded,
    this.isCover = false,
  });

  /// Stable identifier, also used as the storage object name once uploaded.
  final String id;

  final VehicleImageSource source;

  /// Asset key (`assets/...`), absolute URL or absolute local file path,
  /// depending on [source].
  final String path;

  /// Optional hint shown in the owner UI ("Frente", "Painel", ...).
  final String label;

  final VehicleImageStatus status;

  /// The photograph used as the listing card and detail hero image.
  final bool isCover;

  VehicleImage copyWith({
    VehicleImageSource? source,
    String? path,
    String? label,
    VehicleImageStatus? status,
    bool? isCover,
  }) {
    return VehicleImage(
      id: id,
      source: source ?? this.source,
      path: path ?? this.path,
      label: label ?? this.label,
      status: status ?? this.status,
      isCover: isCover ?? this.isCover,
    );
  }

  /// Places this photograph in the uploading state, ready for a real
  /// storage call.
  VehicleImage asUploading() =>
      copyWith(status: VehicleImageStatus.uploading, isCover: false);

  VehicleImage asUploaded() => copyWith(status: VehicleImageStatus.uploaded);

  VehicleImage asFailed() => copyWith(status: VehicleImageStatus.failed);

  VehicleImage asCover() => copyWith(isCover: true);
}