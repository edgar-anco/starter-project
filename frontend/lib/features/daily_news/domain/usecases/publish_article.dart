import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/params/publish_article_params.dart';

class PublishArticleUseCase implements UseCase<DataState<ArticleEntity>, PublishArticleParams> {
  final ArticleRepository _articleRepository;

  PublishArticleUseCase(this._articleRepository);

  @override
  Future<DataState<ArticleEntity>> call({PublishArticleParams? params}) {
    if (params == null) {
      throw ArgumentError('PublishArticleParams cannot be null');
    }

    return _articleRepository.publishArticle(
      author: params.author,
      title: params.title,
      description: params.description,
      content: params.content,
      thumbnailFile: params.thumbnailFile,
    );
  }
}