import 'package:html/parser.dart';

class ApiQuestion {
  final String category;
  final String type;
  final String difficulty;
  final String question;
  final String correctAnswer;
  final List<String> incorrectAnswers;
  final List<String> options;

  ApiQuestion({
    required this.category,
    required this.type,
    required this.difficulty,
    required this.question,
    required this.correctAnswer,
    required this.incorrectAnswers,
    required this.options,
  });

  factory ApiQuestion.fromJson(Map<String, dynamic> json) {
    // Unescape HTML entities from OpenTDB
    String unescapeHtml(String text) {
      final document = parse(text);
      return document.documentElement?.text ?? text;
    }

    String decodedQuestion = unescapeHtml(json['question'] as String);
    String decodedCorrect = unescapeHtml(json['correct_answer'] as String);
    List<String> decodedIncorrect = (json['incorrect_answers'] as List)
        .map((e) => unescapeHtml(e as String))
        .toList();

    List<String> allOptions = List.from(decodedIncorrect)..add(decodedCorrect);
    allOptions.shuffle();

    return ApiQuestion(
      category: unescapeHtml(json['category'] as String),
      type: json['type'] as String,
      difficulty: json['difficulty'] as String,
      question: decodedQuestion,
      correctAnswer: decodedCorrect,
      incorrectAnswers: decodedIncorrect,
      options: allOptions,
    );
  }
}
