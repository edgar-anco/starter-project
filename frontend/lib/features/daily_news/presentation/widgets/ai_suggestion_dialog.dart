import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_suggestion.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/ai_suggestion/ai_suggestion_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/ai_suggestion/ai_suggestion_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/ai_suggestion/ai_suggestion_state.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

class AiSuggestionDialog extends StatefulWidget {
  final void Function(ArticleSuggestionEntity suggestion) onSuggestionReceived;

  const AiSuggestionDialog({
    Key? key,
    required this.onSuggestionReceived,
  }) : super(key: key);

  @override
  State<AiSuggestionDialog> createState() => _AiSuggestionDialogState();
}

class _AiSuggestionDialogState extends State<AiSuggestionDialog> {
  final _draftController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  static const int minDraftLength = 20;
  static const int maxDraftLength = 500;

  @override
  void dispose() {
    _draftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AiSuggestionBloc>(),
      child: BlocConsumer<AiSuggestionBloc, AiSuggestionState>(
        listener: (context, state) {
          if (state is AiSuggestionSuccess) {
            widget.onSuggestionReceived(state.suggestion);
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Write with AI',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: state is AiSuggestionLoading
                      ? null
                      : () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter your draft or idea for the article:',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _draftController,
                      maxLength: maxDraftLength,
                      maxLines: 5,
                      enabled: state is! AiSuggestionLoading,
                      decoration: InputDecoration(
                        hintText: 'Write your idea here...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFDDB8E4),
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your draft';
                        }
                        if (value.trim().length < minDraftLength) {
                          return 'The draft must have at least $minDraftLength characters';
                        }
                        return null;
                      },
                    ),
                    if (state is AiSuggestionError) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline,
                                color: Colors.red.shade700, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Error: ${state.message}',
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (state is AiSuggestionLoading) ...[
                      const SizedBox(height: 16),
                      const Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(color: Color(0xFFDDB8E4)),
                            SizedBox(height: 8),
                            Text(
                              'Generating suggestions...',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: state is AiSuggestionLoading
                    ? null
                    : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                onPressed: state is AiSuggestionLoading
                    ? null
                    : () => _generateSuggestions(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDDB8E4),
                  foregroundColor: Colors.black,
                ),
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('Suggest title and content'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _generateSuggestions(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<AiSuggestionBloc>().add(
            GenerateSuggestions(draft: _draftController.text.trim()),
          );
    }
  }
}
