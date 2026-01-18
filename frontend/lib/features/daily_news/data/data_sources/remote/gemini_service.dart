import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_suggestion.dart';

class GeminiService {
  final http.Client _httpClient;
  final String _apiKey;

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  GeminiService({
    http.Client? httpClient,
    String? apiKey,
  })  : _httpClient = httpClient ?? http.Client(),
        _apiKey = apiKey ?? dotenv.env['GEMINI_API_KEY'] ?? '';

  Future<ArticleSuggestionEntity> generateArticleSuggestions({
    required String draft,
  }) async {
    final prompt = '''
You are a professional news article writer. Based on the following draft or idea, generate a compelling news article.

Draft/Idea: $draft

Please respond in the following JSON format only:
{
  "title": "A compelling title (maximum 100 characters)",
  "content": "The full article content (maximum 5000 characters)"
}

Requirements:
- Write in the same language as the draft/idea provided
- Maintain a professional journalistic tone
''';

    final url = Uri.parse('$_baseUrl?key=$_apiKey');

    final response = await _httpClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 8192,
        }
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to generate suggestions: ${response.body}');
    }

    final responseData = jsonDecode(response.body) as Map<String, dynamic>;

    final candidates = responseData['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('No response generated from Gemini');
    }

    final content = candidates[0]['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    if (parts == null || parts.isEmpty) {
      throw Exception('Invalid response format from Gemini');
    }

    final textResponse = parts[0]['text'] as String;

    // Extract JSON from the response (it might be wrapped in markdown code blocks)
    String jsonString = textResponse;
    final jsonMatch = RegExp(r'```json\s*([\s\S]*?)\s*```').firstMatch(textResponse);
    if (jsonMatch != null) {
      jsonString = jsonMatch.group(1)!;
    } else {
      // Try to find raw JSON
      final rawJsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(textResponse);
      if (rawJsonMatch != null) {
        jsonString = rawJsonMatch.group(0)!;
      }
    }

    final suggestionData = jsonDecode(jsonString) as Map<String, dynamic>;

    String title = suggestionData['title'] as String? ?? '';
    String articleContent = suggestionData['content'] as String? ?? '';

    // Enforce character limits
    if (title.length > 100) {
      title = title.substring(0, 100);
    }
    if (articleContent.length > 5000) {
      articleContent = articleContent.substring(0, 5000);
    }

    return ArticleSuggestionEntity(
      title: title,
      content: articleContent,
    );
  }
}
