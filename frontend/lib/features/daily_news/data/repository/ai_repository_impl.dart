import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/gemini_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_suggestion.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/ai_repository.dart';

class AiRepositoryImpl implements AiRepository {
  final GeminiService _geminiService;

  AiRepositoryImpl(this._geminiService);

  @override
  Future<DataState<ArticleSuggestionEntity>> generateArticleSuggestions({
    required String draft,
  }) async {
    try {
      final suggestion = await _geminiService.generateArticleSuggestions(
        draft: draft,
      );
      return DataSuccess(suggestion);
    } catch (e) {
      return DataFailed(
        DioError(
          error: e.toString(),
          requestOptions: RequestOptions(path: ''),
        ),
      );
    }
  }
}
