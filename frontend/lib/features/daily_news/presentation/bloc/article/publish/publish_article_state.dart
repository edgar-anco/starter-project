import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class PublishArticleState extends Equatable {
  const PublishArticleState();

  @override
  List<Object?> get props => [];
}

class PublishArticleInitial extends PublishArticleState {
  const PublishArticleInitial();
}

class PublishArticleLoading extends PublishArticleState {
  const PublishArticleLoading();
}

class PublishArticleSuccess extends PublishArticleState {
  final ArticleEntity article;

  const PublishArticleSuccess(this.article);

  @override
  List<Object?> get props => [article];
}

class PublishArticleError extends PublishArticleState {
  final String message;

  const PublishArticleError(this.message);

  @override
  List<Object?> get props => [message];
}