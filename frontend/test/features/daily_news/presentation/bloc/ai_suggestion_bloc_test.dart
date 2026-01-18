import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_suggestion.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/ai_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/generate_article_suggestions.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/ai_suggestion/ai_suggestion_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/ai_suggestion/ai_suggestion_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/ai_suggestion/ai_suggestion_state.dart';

// Manual mock for AiRepository
class MockAiRepository implements AiRepository {
  DataState<ArticleSuggestionEntity>? generateSuggestionsResult;

  @override
  Future<DataState<ArticleSuggestionEntity>> generateArticleSuggestions({
    required String draft,
  }) async {
    if (generateSuggestionsResult == null) {
      throw StateError('generateSuggestionsResult not configured');
    }
    return generateSuggestionsResult!;
  }
}

void main() {
  late AiSuggestionBloc bloc;
  late MockAiRepository mockRepository;
  late GenerateArticleSuggestionsUseCase useCase;

  const testSuggestion = ArticleSuggestionEntity(
    title: 'Generated Title',
    content: 'Generated Content',
  );

  setUp(() {
    mockRepository = MockAiRepository();
    useCase = GenerateArticleSuggestionsUseCase(mockRepository);
    bloc = AiSuggestionBloc(useCase);
  });

  tearDown(() {
    bloc.close();
  });

  group('AiSuggestionBloc', () {
    test('initial state is AiSuggestionInitial', () {
      expect(bloc.state, const AiSuggestionInitial());
    });

    test('emits [Loading, Success] when generation succeeds', () async {
      // Arrange
      mockRepository.generateSuggestionsResult = const DataSuccess(testSuggestion);

      // Collect emitted states
      final states = <AiSuggestionState>[];
      final subscription = bloc.stream.listen(states.add);

      // Act
      bloc.add(const GenerateSuggestions(
        draft: 'This is a test draft for generating suggestions',
      ));

      // Wait for states to be emitted
      await Future.delayed(const Duration(milliseconds: 100));
      await subscription.cancel();

      // Assert
      expect(states.length, 2);
      expect(states[0], const AiSuggestionLoading());
      expect(states[1], isA<AiSuggestionSuccess>());
      expect((states[1] as AiSuggestionSuccess).suggestion, testSuggestion);
    });

    test('emits [Initial] when ResetAiSuggestionState is added', () async {
      // Arrange - first generate to get to success state
      mockRepository.generateSuggestionsResult = const DataSuccess(testSuggestion);
      bloc.add(const GenerateSuggestions(
        draft: 'Test draft',
      ));
      await Future.delayed(const Duration(milliseconds: 100));

      // Collect states after reset
      final states = <AiSuggestionState>[];
      final subscription = bloc.stream.listen(states.add);

      // Act
      bloc.add(const ResetAiSuggestionState());

      // Wait for state to be emitted
      await Future.delayed(const Duration(milliseconds: 100));
      await subscription.cancel();

      // Assert
      expect(states.length, 1);
      expect(states[0], const AiSuggestionInitial());
    });
  });
}
