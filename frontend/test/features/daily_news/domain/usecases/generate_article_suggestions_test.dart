import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_suggestion.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/ai_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/generate_article_suggestions.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/params/generate_suggestions_params.dart';

// Manual mock implementation
class MockAiRepository implements AiRepository {
  DataState<ArticleSuggestionEntity>? generateSuggestionsResult;
  int generateSuggestionsCallCount = 0;
  String? lastDraft;

  @override
  Future<DataState<ArticleSuggestionEntity>> generateArticleSuggestions({
    required String draft,
  }) async {
    generateSuggestionsCallCount++;
    lastDraft = draft;
    if (generateSuggestionsResult == null) {
      throw StateError('generateSuggestionsResult not configured');
    }
    return generateSuggestionsResult!;
  }
}

void main() {
  late GenerateArticleSuggestionsUseCase useCase;
  late MockAiRepository mockRepository;

  setUp(() {
    mockRepository = MockAiRepository();
    useCase = GenerateArticleSuggestionsUseCase(mockRepository);
  });

  const testSuggestion = ArticleSuggestionEntity(
    title: 'Test Title',
    content: 'Test Content',
  );

  group('GenerateArticleSuggestionsUseCase', () {
    test('should generate suggestions successfully', () async {
      // Arrange
      mockRepository.generateSuggestionsResult = const DataSuccess(testSuggestion);

      // Act
      final result = await useCase(
        params: const GenerateSuggestionsParams(
          draft: 'This is a test draft for generating article suggestions',
        ),
      );

      // Assert
      expect(result, isA<DataSuccess<ArticleSuggestionEntity>>());
      expect((result as DataSuccess).data, testSuggestion);
      expect(mockRepository.generateSuggestionsCallCount, 1);
      expect(mockRepository.lastDraft, 'This is a test draft for generating article suggestions');
    });

    test('should throw error when params is null', () async {
      // Act & Assert
      expect(
        () => useCase(params: null),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should pass draft to repository', () async {
      // Arrange
      mockRepository.generateSuggestionsResult = const DataSuccess(testSuggestion);
      const testDraft = 'My draft idea for an article about technology trends';

      // Act
      await useCase(
        params: const GenerateSuggestionsParams(draft: testDraft),
      );

      // Assert
      expect(mockRepository.lastDraft, testDraft);
    });
  });
}
