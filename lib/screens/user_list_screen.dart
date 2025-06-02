import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../blocs/user_bloc/user_bloc.dart';
import '../blocs/user_bloc/user_event.dart';
import '../blocs/user_bloc/user_state.dart';
import '../models/user.dart';
import 'local_posts_screen.dart';
import 'user_detail_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(const FetchUsers());

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        context.read<UserBloc>().add(const LoadMoreUsers());
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onRefresh() {
    context.read<UserBloc>().add(const RefreshUsers());
  }

  void _onLoading() {
    context.read<UserBloc>().add(const LoadMoreUsers());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceVariant.withOpacity(0.08),
      appBar: AppBar(
        title: Text(
          'Explore Users',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 1,
        scrolledUnderElevation: 2,
        backgroundColor: colorScheme.surface,
        actions: [
          IconButton(
            icon:  Icon(Icons.post_add,color: colorScheme.onSurface),
            tooltip: 'My Local Posts',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LocalPostsScreen(),
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 8),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(24),
              child: TextField(
                controller: _searchController,
                onChanged: (query) {
                  context.read<UserBloc>().add(SearchUsers(query));
                },
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      context.read<UserBloc>().add(const FetchUsers());
                      FocusScope.of(context).unfocus();
                    },
                  )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),
        ),
      ),
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserLoaded) {
            _refreshController.refreshCompleted();
            if (state.hasReachedMax) {
              _refreshController.loadNoData();
            } else {
              _refreshController.loadComplete();
            }
          } else if (state is UserError) {
            _refreshController.refreshFailed();
            _refreshController.loadFailed();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          List<User> users = [];
          bool isLoading = false;
          bool hasReachedMax = false;

          if (state is UserInitial || (state is UserLoading && state.users.isEmpty)) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserLoading) {
            isLoading = true;
            users = state.users;
          } else if (state is UserLoaded) {
            users = state.users;
            hasReachedMax = state.hasReachedMax;
          } else if (state is UserError) {
            users = state.users;
          }

          if (users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 72, color: colorScheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text(
                    _searchController.text.isNotEmpty
                        ? 'No users found for "${_searchController.text}".'
                        : 'No users found.',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _onRefresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  )
                ],
              ),
            );
          }

          return SmartRefresher(
            controller: _refreshController,
            enablePullUp: !hasReachedMax,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            header: WaterDropHeader(
              waterDropColor: colorScheme.primary,
            ),
            footer: CustomFooter(
              builder: (context, mode) {
                if (mode == LoadStatus.loading) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Loading more users...',
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  );
                } else if (mode == LoadStatus.failed) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Load failed. Tap to retry.'),
                  );
                } else if (mode == LoadStatus.noMore) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No more users'),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: users.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == users.length && isLoading) {
                  return const SizedBox(); // handled by SmartRefresher footer
                }

                final user = users[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor: colorScheme.primaryContainer,
                      backgroundImage: user.image.isNotEmpty ? NetworkImage(user.image) : null,
                      child: user.image.isEmpty
                          ? Text(
                        '${user.firstName[0]}${user.lastName[0]}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      )
                          : null,
                    ),
                    title: Text(
                      '${user.firstName} ${user.lastName}',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(user.email),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserDetailScreen(user: user),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
