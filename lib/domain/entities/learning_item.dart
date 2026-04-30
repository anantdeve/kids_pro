class LearningItem {
  final String id;
  final String title;
  final String imageUrl;
  final String audioUrl;
  final String? subtitle;

  const LearningItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.audioUrl,
    this.subtitle,
  });
}
