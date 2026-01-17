import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:uuid/uuid.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final Uuid _uuid = const Uuid();

  FirestoreService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> get _articlesCollection =>
      _firestore.collection('articles');

  /// Fetches all articles from Firestore ordered by publishedAt descending
  Future<List<ArticleModel>> getArticles() async {
    final snapshot = await _articlesCollection
        .orderBy('publishedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ArticleModel.fromFirestore(doc.data()))
        .toList();
  }

  /// Publishes a new article to Firestore
  /// Returns the created ArticleModel
  Future<ArticleModel> publishArticle({
    required String author,
    required String title,
    String? description,
    required String content,
    File? thumbnailFile,
  }) async {
    final articleId = _uuid.v4();
    String? thumbnailUrl;

    // Upload thumbnail if provided
    if (thumbnailFile != null) {
      thumbnailUrl = await _uploadThumbnail(articleId, thumbnailFile);
    }

    final now = Timestamp.now();
    final articleData = {
      'id': articleId,
      'author': author,
      'title': title,
      'description': description ?? '',
      'content': content,
      'thumbnailUrl': thumbnailUrl ?? '',
      'publishedAt': now,
      'createdAt': now,
      'updatedAt': now,
    };

    await _articlesCollection.doc(articleId).set(articleData);

    return ArticleModel.fromFirestore(articleData);
  }

  /// Uploads thumbnail to Cloud Storage
  /// Returns the download URL
  Future<String> _uploadThumbnail(String articleId, File file) async {
    final extension = file.path.split('.').last;
    final ref = _storage.ref('media/articles/$articleId/thumbnail.$extension');

    final uploadTask = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/$extension'),
    );

    return await uploadTask.ref.getDownloadURL();
  }

  /// Deletes an article and its thumbnail
  Future<void> deleteArticle(String articleId) async {
    // Delete thumbnail from Storage
    try {
      final ref = _storage.ref('media/articles/$articleId');
      final items = await ref.listAll();
      for (final item in items.items) {
        await item.delete();
      }
    } catch (_) {
      // Thumbnail might not exist, continue
    }

    // Delete document from Firestore
    await _articlesCollection.doc(articleId).delete();
  }
}