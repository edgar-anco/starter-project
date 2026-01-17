import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import '../../../../core/constants/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@Entity(tableName: 'article',primaryKeys: ['id'])
class ArticleModel extends ArticleEntity {
  const ArticleModel({
    int ? id,
    String ? author,
    String ? title,
    String ? description,
    String ? url,
    String ? urlToImage,
    String ? publishedAt,
    String ? content,
  }): super(
          id: id,
          author: author,
          title: title,
          description: description,
          url: url,
          urlToImage: urlToImage,
          publishedAt: publishedAt,
          content: content,
        );

  /// Factory constructor for News API JSON
  factory ArticleModel.fromJson(Map < String, dynamic > map) {
    return ArticleModel(
      author: map['author'] ?? "",
      title: map['title'] ?? "",
      description: map['description'] ?? "",
      url: map['url'] ?? "",
      urlToImage: map['urlToImage'] != null && map['urlToImage'] != "" ? map['urlToImage'] : kDefaultImage,
      publishedAt: map['publishedAt'] ?? "",
      content: map['content'] ?? "",
    );
  }

  /// Factory constructor for Firestore documents
  factory ArticleModel.fromFirestore(Map<String, dynamic> map) {
    String publishedAt = '';
    if (map['publishedAt'] != null) {
      if (map['publishedAt'] is Timestamp) {
        publishedAt = (map['publishedAt'] as Timestamp).toDate().toIso8601String();
      } else {
        publishedAt = map['publishedAt'].toString();
      }
    }

    return ArticleModel(
      author: map['author'] ?? "",
      title: map['title'] ?? "",
      description: map['description'] ?? "",
      url: map['url'] ?? "",
      urlToImage: map['thumbnailUrl'] != null && map['thumbnailUrl'] != ""
          ? map['thumbnailUrl']
          : kDefaultImage,
      publishedAt: publishedAt,
      content: map['content'] ?? "",
    );
  }

  /// Factory constructor from Entity
  factory ArticleModel.fromEntity(ArticleEntity entity) {
    return ArticleModel(
      id: entity.id,
      author: entity.author,
      title: entity.title,
      description: entity.description,
      url: entity.url,
      urlToImage: entity.urlToImage,
      publishedAt: entity.publishedAt,
      content: entity.content
    );
  }

  /// Converts to Firestore document map
  Map<String, dynamic> toFirestore() {
    return {
      'author': author,
      'title': title,
      'description': description,
      'url': url,
      'thumbnailUrl': urlToImage,
      'publishedAt': publishedAt,
      'content': content,
    };
  }
}