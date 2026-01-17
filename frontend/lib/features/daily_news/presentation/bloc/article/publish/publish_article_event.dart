import 'dart:io';

abstract class PublishArticleEvent {
  const PublishArticleEvent();
}

class PublishArticle extends PublishArticleEvent {
  final String author;
  final String title;
  final String? description;
  final String content;
  final File? thumbnailFile;

  const PublishArticle({
    required this.author,
    required this.title,
    this.description,
    required this.content,
    this.thumbnailFile,
  });
}

class ResetPublishState extends PublishArticleEvent {
  const ResetPublishState();
}