import 'dart:io';

import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/firestore_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final NewsApiService _newsApiService;
  final AppDatabase _appDatabase;
  final FirestoreService _firestoreService;
  ArticleRepositoryImpl(this._newsApiService,this._appDatabase,this._firestoreService);

  @override
  Future<DataState<List<ArticleEntity>>> getNewsArticles() async {
    try {
      final httpResponse = await _newsApiService.getNewsArticles(
        apiKey:newsAPIKey,
        country:countryQuery,
        category:categoryQuery,
      );

      if (httpResponse.response.statusCode == 200) {
        return DataSuccess(httpResponse.data);
      } else {
        return DataFailed(
          DioError(
            error: httpResponse.response.statusMessage,
            response: httpResponse.response,
            type: DioErrorType.response,
            requestOptions: httpResponse.response.requestOptions
          )
        );
      }
    } on DioError catch(e){
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<List<ArticleEntity>>> getFirestoreArticles() async {
    try {
      final articles = await _firestoreService.getArticles();
      return DataSuccess(articles);
    } catch (e) {
      return DataFailed(DioError(
        error: e.toString(),
        type: DioErrorType.other,
        requestOptions: RequestOptions(path: 'firestore/articles'),
      ));
    }
  }

  @override
  Future<DataState<ArticleEntity>> publishArticle({
    required String author,
    required String title,
    String? description,
    required String content,
    File? thumbnailFile,
  }) async {
    try {
      final article = await _firestoreService.publishArticle(
        author: author,
        title: title,
        description: description,
        content: content,
        thumbnailFile: thumbnailFile,
      );
      return DataSuccess(article);
    } catch (e) {
      return DataFailed(DioError(
        error: e.toString(),
        type: DioErrorType.other,
        requestOptions: RequestOptions(path: 'firestore/publish'),
      ));
    }
  }

  @override
  Future<List<ArticleEntity>> getSavedArticles() async {
    return _appDatabase.articleDAO.getArticles();
  }

  @override
  Future<void> saveArticle(ArticleEntity article) {
    return _appDatabase.articleDAO.insertArticle(ArticleModel.fromEntity(article));
  }

  @override
  Future<void> removeArticle(ArticleEntity article) {
    return _appDatabase.articleDAO
        .deleteArticle(ArticleModel.fromEntity(article));
  }
}