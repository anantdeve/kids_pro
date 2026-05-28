class VisualQuestion {
  final String text;
  final String emoji;
  final List<String> options;
  final String correctEmoji;

  VisualQuestion({
    required this.text,
    required this.emoji,
    required List<String> options,
    required this.correctEmoji,
  }) : options = List.from(options)..shuffle();
}
