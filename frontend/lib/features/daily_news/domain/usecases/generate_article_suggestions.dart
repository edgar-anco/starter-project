import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_suggestion.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/ai_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/params/generate_suggestions_params.dart';

class GenerateArticleSuggestionsUseCase
    implements UseCase<DataState<ArticleSuggestionEntity>, GenerateSuggestionsParams> {
  final AiRepository _aiRepository;

  GenerateArticleSuggestionsUseCase(this._aiRepository);

  @override
  Future<DataState<ArticleSuggestionEntity>> call({GenerateSuggestionsParams? params}) {
    if (params == null) {
      throw ArgumentError('GenerateSuggestionsParams cannot be null');
    }

    return _aiRepository.generateArticleSuggestions(
      draft: params.draft,
    );
  }
}
