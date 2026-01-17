import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/publish_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/publish/publish_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/publish/publish_article_state.dart';

class PublishArticleBloc extends Bloc<PublishArticleEvent, PublishArticleState> {
  final PublishArticleUseCase _publishArticleUseCase;

  PublishArticleBloc(this._publishArticleUseCase)
      : super(const PublishArticleInitial()) {
    on<PublishArticle>(_onPublishArticle);
    on<ResetPublishState>(_onResetPublishState);
  }

  Future<void> _onPublishArticle(
    PublishArticle event,
    Emitter<PublishArticleState> emit,
  ) async {
    emit(const PublishArticleLoading());

    final params = PublishArticleParams(
      author: event.author,
      title: event.title,
      description: event.description,
      content: event.content,
      thumbnailFile: event.thumbnailFile,
    );

    final dataState = await _publishArticleUseCase(params: params);

    if (dataState is DataSuccess) {
      emit(PublishArticleSuccess(dataState.data!));
    } else if (dataState is DataFailed) {
      emit(PublishArticleError(dataState.error?.message ?? 'Unknown error'));
    }
  }

  void _onResetPublishState(
    ResetPublishState event,
    Emitter<PublishArticleState> emit,
  ) {
    emit(const PublishArticleInitial());
  }
}