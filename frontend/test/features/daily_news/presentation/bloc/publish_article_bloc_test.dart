import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/publish_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/publish/publish_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/publish/publish_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/publish/publish_article_state.dart';

// Manual mock for ArticleRepository
class MockArticleRepository implements ArticleRepository {
  DataState<ArticleEntity>? publishArticleResult;

  @override
  Future<DataState<ArticleEntity>> publishArticle({
    required String author,
    required String title,
    String? description,
    required String content,
    File? thumbnailFile,
  }) async {
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
  late PublishArticleBloc bloc;
  late MockArticleRepository mockRepository;
  late PublishArticleUseCase useCase;

  const testArticle = ArticleEntity(
    id: 1,
    author: 'Test Author',
    title: 'Test Title',
    content: 'Test Content',
    publishedAt: '2026-01-16T12:00:00Z',
  );

  setUp(() {
    mockRepository = MockArticleRepository();
    useCase = PublishArticleUseCase(mockRepository);
    bloc = PublishArticleBloc(useCase);
  });

  tearDown(() {
    bloc.close();
  });

  group('PublishArticleBloc', () {
    test('initial state is PublishArticleInitial', () {
      expect(bloc.state, const PublishArticleInitial());
    });

    test('emits [Loading, Success] when publish succeeds', () async {
      // Arrange
      mockRepository.publishArticleResult = const DataSuccess(testArticle);

      // Collect emitted states
      final states = <PublishArticleState>[];
      final subscription = bloc.stream.listen(states.add);

      // Act
      bloc.add(const PublishArticle(
        author: 'Test Author',
        title: 'Test Title',
        content: 'Test Content',
      ));

      // Wait for states to be emitted
      await Future.delayed(const Duration(milliseconds: 100));
      await subscription.cancel();

      // Assert
      expect(states.length, 2);
      expect(states[0], const PublishArticleLoading());
      expect(states[1], isA<PublishArticleSuccess>());
      expect((states[1] as PublishArticleSuccess).article, testArticle);
    });

    test('emits [Initial] when ResetPublishState is added', () async {
      // Arrange - first publish to get to success state
      mockRepository.publishArticleResult = const DataSuccess(testArticle);
      bloc.add(const PublishArticle(
        author: 'Test Author',
        title: 'Test Title',
        content: 'Test Content',
      ));
      await Future.delayed(const Duration(milliseconds: 100));

      // Collect states after reset
      final states = <PublishArticleState>[];
      final subscription = bloc.stream.listen(states.add);

      // Act
      bloc.add(const ResetPublishState());

      // Wait for state to be emitted
      await Future.delayed(const Duration(milliseconds: 100));
      await subscription.cancel();

      // Assert
      expect(states.length, 1);
      expect(states[0], const PublishArticleInitial());
    });
  });
}
