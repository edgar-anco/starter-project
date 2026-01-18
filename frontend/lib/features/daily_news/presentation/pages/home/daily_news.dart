import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/theme/theme_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/theme/theme_state.dart';

import '../../../domain/entities/article.dart';
import '../../widgets/article_tile.dart';

class DailyNews extends StatelessWidget {
  const DailyNews({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildPage();
  }

  _buildAppbar(BuildContext context) {
    final isDarkMode = context.watch<ThemeCubit>().state.isDarkMode;

    return AppBar(
      leading: IconButton(
        onPressed: () => context.read<ThemeCubit>().toggleTheme(),
        icon: Icon(
          isDarkMode ? Icons.light_mode : Icons.dark_mode,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      title: Text(
        'Daily News',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
      actions: [
        GestureDetector(
          onTap: () => _onShowSavedArticlesViewTapped(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Icon(
              Icons.bookmark,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  _buildPage() {
    return BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
      builder: (context, state) {
        if (state is RemoteArticlesLoading) {
          return Scaffold(
              appBar: _buildAppbar(context),
              body: const Center(child: CupertinoActivityIndicator()));
        }
        if (state is RemoteArticlesError) {
          return Scaffold(
              appBar: _buildAppbar(context),
              body: const Center(child: Icon(Icons.refresh)));
        }
        if (state is RemoteArticlesDone) {
          return _buildArticlesPage(context, state.articles!);
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildArticlesPage(
      BuildContext context, List<ArticleEntity> articles) {
    List<Widget> articleWidgets = [];
    for (var article in articles) {
      articleWidgets.add(ArticleWidget(
        article: article,
        onArticlePressed: (article) => _onArticlePressed(context, article),
      ));
    }

    return Scaffold(
      appBar: _buildAppbar(context),
      body: RefreshIndicator(
        color: const Color(0xFFDDB8E4),
        onRefresh: () async {
          context.read<RemoteArticlesBloc>().add(const GetArticles());
          await Future.delayed(const Duration(seconds: 1));
        },
        child: ListView(
          children: articleWidgets,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onPublishArticleTapped(context),
        backgroundColor: const Color(0xFFDDB8E4),
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }

  void _onArticlePressed(BuildContext context, ArticleEntity article) {
    Navigator.pushNamed(context, '/ArticleDetails', arguments: article);
  }

  void _onShowSavedArticlesViewTapped(BuildContext context) {
    Navigator.pushNamed(context, '/SavedArticles');
  }

  void _onPublishArticleTapped(BuildContext context) {
    Navigator.pushNamed(context, '/PublishArticle').then((result) {
      if (result == true) {
        // Refresh articles after publishing
        context.read<RemoteArticlesBloc>().add(const GetArticles());
      }
    });
  }
}
