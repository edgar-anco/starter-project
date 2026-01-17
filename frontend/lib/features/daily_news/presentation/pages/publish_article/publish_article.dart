import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/publish/publish_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/publish/publish_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/publish/publish_article_state.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

class PublishArticlePage extends StatefulWidget {
  const PublishArticlePage({Key? key}) : super(key: key);

  @override
  State<PublishArticlePage> createState() => _PublishArticlePageState();
}

class _PublishArticlePageState extends State<PublishArticlePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _authorController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  File? _selectedImage;

  static const int maxTitleLength = 100;
  static const int maxContentLength = 5000;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  void _publishArticle(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<PublishArticleBloc>().add(
            PublishArticle(
              author: _authorController.text.trim(),
              title: _titleController.text.trim(),
              content: _contentController.text.trim(),
              thumbnailFile: _selectedImage,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PublishArticleBloc>(),
      child: BlocConsumer<PublishArticleBloc, PublishArticleState>(
        listener: (context, state) {
          if (state is PublishArticleSuccess) {
            _showSuccessDialog(context);
          } else if (state is PublishArticleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: _buildAppBar(context),
            body: _buildBody(context, state),
            bottomNavigationBar: _buildPublishButton(context, state),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Publish Article',
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  Widget _buildBody(BuildContext context, PublishArticleState state) {
    if (state is PublishArticleLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFDDB8E4)),
            SizedBox(height: 16),
            Text('Publishing your article...'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAuthorField(),
            const SizedBox(height: 16),
            _buildTitleField(),
            const SizedBox(height: 16),
            _buildImageSection(),
            const SizedBox(height: 16),
            _buildContentField(),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorField() {
    return TextFormField(
      controller: _authorController,
      decoration: InputDecoration(
        hintText: 'Your name...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFDDB8E4), width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your name';
        }
        return null;
      },
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      maxLength: maxTitleLength,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: 'Write your title here...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFDDB8E4), width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a title';
        }
        return null;
      },
    );
  }

  Widget _buildImageSection() {
    if (_selectedImage != null) {
      return GestureDetector(
        onTap: _pickImage,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                _selectedImage!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: _removeImage,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Tap to change image',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: ElevatedButton.icon(
        onPressed: _pickImage,
        icon: const Icon(Icons.camera_alt_outlined),
        label: const Text('Attach Image'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFDDB8E4),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }

  Widget _buildContentField() {
    return TextFormField(
      controller: _contentController,
      maxLength: maxContentLength,
      maxLines: 12,
      decoration: InputDecoration(
        hintText: 'Add article here, .....',
        alignLabelWithHint: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFDDB8E4), width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter article content';
        }
        return null;
      },
    );
  }

  Widget _buildPublishButton(BuildContext context, PublishArticleState state) {
    final isLoading = state is PublishArticleLoading;

    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: isLoading ? null : () => _publishArticle(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDDB8E4),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.arrow_forward),
              const Text(
                ')',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              Text(
                isLoading ? 'Publishing...' : 'Publish Article',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Article Published!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your article has been successfully published.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDDB8E4),
                  foregroundColor: Colors.black,
                ),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        );
      },
    );
  }
}