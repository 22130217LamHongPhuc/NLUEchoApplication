enum MediaType { image, audio, thumbnail }

class EchoMedia {
  final int id;
  final MediaType mediaType;
  final String mediaUrl;

  final int? durationSeconds;
  final int? width;
  final int? height;

  const EchoMedia({
    required this.id,
    required this.mediaType,
    required this.mediaUrl,
    this.durationSeconds,
    this.width,
    this.height,
  });

  factory EchoMedia.fromJson(Map<String, dynamic> json) {
    return EchoMedia(
      id: json['id'],
      mediaType: MediaType.values.firstWhere(
            (e) => e.name.toUpperCase() == json['mediaType'],
      ),
      mediaUrl: json['mediaUrl'],
      durationSeconds: json['durationSeconds'],
      width: json['width'],
      height: json['height'],
    );
  }
}