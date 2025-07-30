class HeroImage {
  final int id;
  final String title;
  final String url;
  final String imageUrl;

  HeroImage({
    required this.id,
    required this.title,
    required this.url,
    required this.imageUrl,
  });

  factory HeroImage.fromJson(Map<String, dynamic> json) {
    return HeroImage(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      imageUrl: json['image_url'] ?? '',
    );
  }
}