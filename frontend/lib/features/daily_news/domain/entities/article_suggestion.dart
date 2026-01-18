import 'package:equatable/equatable.dart';

class ArticleSuggestionEntity extends Equatable {
  final String title;
  final String content;

  const ArticleSuggestionEntity({
    required this.title,
    required this.content,
  });

  @override
  List<Object?> get props => [title, content];
}
