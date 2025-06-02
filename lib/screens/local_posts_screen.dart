import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';


import '../blocs/post_bloc/post_bloc.dart';
import '../blocs/post_bloc/post_event.dart';
import '../blocs/post_bloc/post_state.dart';
import '../models/post.dart';
import 'create_post_screen.dart';
import 'local_posts_detail_screen.dart';

class LocalPostsScreen extends StatefulWidget {
  const LocalPostsScreen({super.key});

  @override
  State<LocalPostsScreen> createState() => _LocalPostsScreenState();
}

class _LocalPostsScreenState extends State<LocalPostsScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    context.read<PostBloc>().add(const LoadPosts());
  }

  void _onRefresh() async {
    context.read<PostBloc>().add(const LoadPosts());
    await Future.delayed(const Duration(milliseconds: 500)); // small wait
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'My Local Posts',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 1,
        scrolledUnderElevation: 2,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: BlocBuilder<PostBloc, PostState>(
        builder: (context, state) {
          List<Post> localPosts = [];

          if (state is PostLoaded) {
            localPosts = state.posts;
          }

          if (localPosts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.post_add, size: 72, color: colorScheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text(
                    'No local posts created yet.',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            onRefresh: _onRefresh,
            header: WaterDropHeader(
              waterDropColor: colorScheme.primary,
            ),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: localPosts.length,
              itemBuilder: (context, index) {
                final post = localPosts[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LocalPostDetailScreen(post: post),
                      ),
                    );
                  },
                  child: Card(
                    color: colorScheme.surfaceVariant,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: colorScheme.outline),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            post.body,
                            style: theme.textTheme.bodyMedium,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              'Local Post (ID: ${post.id})',
                              style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addPost',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
