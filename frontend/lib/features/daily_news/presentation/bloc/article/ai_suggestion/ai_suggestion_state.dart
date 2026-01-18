import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_suggestion.dart';

abstract class AiSuggestionState extends Equatable {
  const AiSuggestionState();

  @override
  List<Object?> get props => [];
}

class AiSuggestionInitial extends AiSuggestionState {
  const AiSuggestionInitial();
}

class AiSuggestionLoading extends AiSuggestionState {
  const AiSuggestionLoading();
}

class AiSuggestionSuccess extends AiSuggestionState {
  final ArticleSuggestionEntity suggestion;

  const AiSuggestionSuccess(this.suggestion);

  @override
  List<Object?> get props => [suggestion];
}

class AiSuggestionError extends AiSuggestionState {
  final String message;

  const AiSuggestionError(this.message);

  @override
  List<Object?> get props => [message];
}
