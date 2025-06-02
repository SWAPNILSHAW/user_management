import 'package:flutter/material.dart';
import '../models/post.dart';

class LocalPostDetailScreen extends StatelessWidget {
  final Post post;

  const LocalPostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Screen background
      appBar: AppBar(
        title: Text(
          'Post Details',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 2,
        iconTheme: IconThemeData(color: colorScheme.primary),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title Section
            Text(
              "Title",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant, // ✅ Updated container color
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                post.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: colorScheme.onSurface,
                  height: 1.3,
                ),
              ),
            ),

            const SizedBox(height: 32),

            /// Body Section
            Text(
              "Body",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant, // ✅ Updated container color
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                post.body,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  color: colorScheme.onSurface,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 40),

            /// Post ID Footer
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                'Local Post ID: ${post.id}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
