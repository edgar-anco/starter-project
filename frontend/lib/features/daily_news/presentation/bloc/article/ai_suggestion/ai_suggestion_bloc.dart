import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/generate_article_suggestions.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/params/generate_suggestions_params.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/ai_suggestion/ai_suggestion_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/ai_suggestion/ai_suggestion_state.dart';

class AiSuggestionBloc extends Bloc<AiSuggestionEvent, AiSuggestionState> {
  final GenerateArticleSuggestionsUseCase _generateArticleSuggestionsUseCase;

  AiSuggestionBloc(this._generateArticleSuggestionsUseCase)
      : super(const AiSuggestionInitial()) {
    on<GenerateSuggestions>(_onGenerateSuggestions);
    on<ResetAiSuggestionState>(_onResetState);
  }

  Future<void> _onGenerateSuggestions(
    GenerateSuggestions event,
    Emitter<AiSuggestionState> emit,
  ) async {
    emit(const AiSuggestionLoading());

    final params = GenerateSuggestionsParams(draft: event.draft);

    final dataState = await _generateArticleSuggestionsUseCase(params: params);

    if (dataState is DataSuccess) {
      emit(AiSuggestionSuccess(dataState.data!));
    } else if (dataState is DataFailed) {
      emit(AiSuggestionError(dataState.error?.message ?? 'Unknown error'));
    }
  }

  void _onResetState(
    ResetAiSuggestionState event,
    Emitter<AiSuggestionState> emit,
  ) {
    emit(const AiSuggestionInitial());
  }
}
