import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/user_detail_bloc/user_detail_bloc.dart';
import '../blocs/user_detail_bloc/user_detail_event.dart';
import '../blocs/user_detail_bloc/user_detail_state.dart';
import '../models/user.dart';
import '../models/post.dart';
import '../models/todo.dart';
import '../repositories/user_repository.dart';

class UserDetailScreen extends StatelessWidget {
  final User user;

  const UserDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocProvider(
      create: (context) => UserDetailBloc(
        userRepository: RepositoryProvider.of<UserRepository>(context),
        user: user,
      )..add(const FetchUserDetail()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${user.firstName} ${user.lastName}',
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              fontSize: 26,
            ),
          ),
          backgroundColor: colorScheme.surface,
          elevation: 6,
          shadowColor: Colors.black26,
          iconTheme: IconThemeData(color: colorScheme.primary),
          centerTitle: true,
        ),
        body: BlocBuilder<UserDetailBloc, UserDetailState>(
          builder: (context, state) {
            if (state is UserDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is UserDetailError) {
              return _buildCenteredMessage(
                context,
                icon: Icons.error_outline,
                message: 'Oops! ${state.message}',
                color: colorScheme.error,
              );
            } else if (state is UserDetailLoaded) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: SingleChildScrollView(
                  key: ValueKey(state.user.id),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUserInfo(state.user, colorScheme, textTheme),
                      const SizedBox(height: 32),
                      _buildSectionTitle('Posts', colorScheme, textTheme),
                      _buildPostsList(state.posts, colorScheme),
                      const SizedBox(height: 32),
                      _buildSectionTitle('Todos', colorScheme, textTheme),
                      _buildTodosList(state.todos, colorScheme),
                    ],
                  ),
                ),
              );
            }
            return _buildCenteredMessage(
              context,
              icon: Icons.error,
              message: 'Unknown error occurred.',
              color: colorScheme.error,
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserInfo(User user, ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.15),
            colorScheme.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.15),
            offset: const Offset(0, 6),
            blurRadius: 12,
          ),
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.05),
            offset: const Offset(0, -3),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.primaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.5),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: CircleAvatar(
              radius: 66,
              backgroundColor: Colors.transparent,
              backgroundImage:
              user.image.isNotEmpty ? NetworkImage(user.image) : null,
              child: user.image.isEmpty
                  ? Icon(
                Icons.person,
                size: 66,
                color: colorScheme.onPrimaryContainer,
              )
                  : null,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '${user.firstName} ${user.lastName}',
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface,
              letterSpacing: 1,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user.email,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Username: ${user.username}',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w400,
              fontSize: 15,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ColorScheme colorScheme, TextTheme textTheme) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 28,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.primary,
            letterSpacing: 0.9,
            fontSize: 22,
          ),
        ),
      ],
    );
  }

  Widget _buildPostsList(List<Post> posts, ColorScheme colorScheme) {
    if (posts.isEmpty) {
      return _buildEmptyState(
        icon: Icons.article_outlined,
        message: 'No posts available.',
        color: colorScheme.outline,
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: posts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final post = posts[index];
        return Material(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          elevation: 3,
          shadowColor: colorScheme.primary.withOpacity(0.18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {}, // Add action if needed
            splashColor: colorScheme.primary.withOpacity(0.2),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: colorScheme.primary,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    post.body,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTodosList(List<Todo> todos, ColorScheme colorScheme) {
    if (todos.isEmpty) {
      return _buildEmptyState(
        icon: Icons.check_box_outline_blank,
        message: 'No todos available.',
        color: colorScheme.outline,
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: todos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final todo = todos[index];
        return Material(
          color: todo.completed
              ? colorScheme.primaryContainer.withOpacity(0.3)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          elevation: 1,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            splashColor: colorScheme.primary.withOpacity(0.15),
            onTap: () {}, // Add toggle logic or details here
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: todo.completed
                          ? colorScheme.primary
                          : colorScheme.surfaceVariant,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      todo.completed
                          ? Icons.check
                          : Icons.circle_outlined,
                      color: colorScheme.onPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      todo.todo,
                      style: TextStyle(
                        decoration: todo.completed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: todo.completed
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.onSurface,
                        height: 1.3,
                      ),
                    ),
                  ),
                  if (todo.completed)
                    Chip(
                      label: const Text('Done'),
                      backgroundColor: colorScheme.primary.withOpacity(0.15),
                      labelStyle: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      visualDensity: VisualDensity.compact,
                    )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: color),
          const SizedBox(width: 14),
          Text(
            message,
            style: TextStyle(
              fontSize: 17,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenteredMessage(BuildContext context,
      {required IconData icon, required String message, required Color color}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 60, color: color),
            const SizedBox(height: 18),
            Text(
              message,
              style: TextStyle(fontSize: 20, color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
