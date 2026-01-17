import 'dart:io';

import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class ArticleRepository {
  // API methods - Remote articles from News API
  Future<DataState<List<ArticleEntity>>> getNewsArticles();

  // Firestore methods - User published articles
  Future<DataState<List<ArticleEntity>>> getFirestoreArticles();

  Future<DataState<ArticleEntity>> publishArticle({
    required String author,
    required String title,
    String? description,
    required String content,
    File? thumbnailFile,
  });

  // Database methods - Local saved articles
  Future<List<ArticleEntity>> getSavedArticles();
  Future<void> saveArticle(ArticleEntity article);
  Future<void> removeArticle(ArticleEntity article);
}