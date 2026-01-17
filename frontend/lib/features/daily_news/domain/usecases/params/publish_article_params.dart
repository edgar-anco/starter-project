import 'dart:io';

class PublishArticleParams {
  final String author;
  final String title;
  final String? description;
  final String content;
  final File? thumbnailFile;

  const PublishArticleParams({
    required this.author,
    required this.title,
    this.description,
    required this.content,
    this.thumbnailFile,
  });
}
