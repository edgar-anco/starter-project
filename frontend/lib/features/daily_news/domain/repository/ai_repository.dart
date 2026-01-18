import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_suggestion.dart';

abstract class AiRepository {
  Future<DataState<ArticleSuggestionEntity>> generateArticleSuggestions({
    required String draft,
  });
}
