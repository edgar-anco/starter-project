import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/publish_article.dart';

// Manual mock implementation
class MockArticleRepository implements ArticleRepository {
  DataState<ArticleEntity>? publishArticleResult;
  int publishArticleCallCount = 0;
  String? lastAuthor;
  String? lastTitle;
  String? lastDescription;
  String? lastContent;
  File? lastThumbnailFile;

  @override
  Future<DataState<ArticleEntity>> publishArticle({
    required String author,
    required String title,
    String? description,
    required String content,
    File? thumbnailFile,
  }) async {
    publishArticleCallCount++;
    lastAuthor = author;
    lastTitle = title;
    lastDescription = description;
    lastContent = content;
    lastThumbnailFile = thumbnailFile;
    if (publishArticleResult == null) {
      throw StateError('publishArticleResult not configured');
    }
    return publishArticleResult!;
  }

  @override
  Future<DataState<List<ArticleEntity>>> getNewsArticles() async {
    throw UnimplementedError();
  }

  @override
  Future<DataState<List<ArticleEntity>>> getFirestoreArticles() async {
    throw UnimplementedError();
  }

  @override
  Future<List<ArticleEntity>> getSavedArticles() async {
    return [];
  }

  @override
  Future<void> saveArticle(ArticleEntity article) async {}

  @override
  Future<void> removeArticle(ArticleEntity article) async {}
}

void main() {
  late PublishArticleUseCase useCase;
  late MockArticleRepository mockRepository;

  setUp(() {
    mockRepository = MockArticleRepository();
    useCase = PublishArticleUseCase(mockRepository);
  });

  const testArticle = ArticleEntity(
    id: 1,
    author: 'Test Author',
    title: 'Test Title',
    description: 'Test Description',
    content: 'Test Content',
    publishedAt: '2026-01-16T12:00:00Z',
  );

  group('PublishArticleUseCase', () {
    test('should publish article successfully', () async {
      // Arrange
      mockRepository.publishArticleResult = const DataSuccess(testArticle);

      // Act
      final result = await useCase(
        params: const PublishArticleParams(
          author: 'Test Author',
          title: 'Test Title',
          content: 'Test Content',
        ),
      );

      // Assert
      expect(result, isA<DataSuccess<ArticleEntity>>());
      expect((result as DataSuccess).data, testArticle);
      expect(mockRepository.publishArticleCallCount, 1);
      expect(mockRepository.lastAuthor, 'Test Author');
      expect(mockRepository.lastTitle, 'Test Title');
      expect(mockRepository.lastDescription, null);
      expect(mockRepository.lastContent, 'Test Content');
      expect(mockRepository.lastThumbnailFile, null);
    });

    test('should throw error when params is null', () async {
      // Act & Assert
      expect(
        () => useCase(params: null),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
