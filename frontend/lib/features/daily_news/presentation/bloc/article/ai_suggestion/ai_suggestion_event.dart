abstract class AiSuggestionEvent {
  const AiSuggestionEvent();
}

class GenerateSuggestions extends AiSuggestionEvent {
  final String draft;

  const GenerateSuggestions({required this.draft});
}

class ResetAiSuggestionState extends AiSuggestionEvent {
  const ResetAiSuggestionState();
}
