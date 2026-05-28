import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/api_question.dart';

class QuizApiService {
  static const String _baseUrl = 'https://opentdb.com/api.php';

  Future<List<ApiQuestion>> fetchQuestions({
    required int categoryId,
    required String difficulty,
    int amount = 5,
  }) async {
    final url = Uri.parse('$_baseUrl?amount=$amount&category=$categoryId&difficulty=$difficulty&type=multiple');
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['response_code'] == 0) {
          final List results = data['results'];
          return results.map((json) => ApiQuestion.fromJson(json)).toList();
        } else {
          throw Exception('Failed to load questions. Try again later!');
        }
      } else {
        throw Exception('Failed to load questions. Please check your connection.');
      }
    } catch (e) {
      throw Exception('Oops! Could not connect to the quiz magic.');
    }
  }
}
