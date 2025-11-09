import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../models/book_model.dart';
import '../../models/swap_model.dart';
import '../../providers/providers.dart';

class BookDetailsScreen extends ConsumerWidget {
  final BookModel book;
  const BookDetailsScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider(book.userId));
    final currentUserId = ref.watch(currentUserIdProvider);
    final isOwner = currentUserId == book.userId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Cover
            if (book.imageUrl != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: book.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: const Color.fromARGB(255, 238, 238, 238),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: const Color.fromARGB(255, 224, 224, 224),
                    child: const Icon(Icons.book, size: 80),
                  ),
                ),
              )
            else
              Container(
                height: 200,
                color: const Color.fromARGB(255, 224, 224, 224),
                child: const Center(
                  child: Icon(Icons.book, size: 80, color: Color.fromARGB(255, 128, 128, 128)),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    book.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),

                  // Author
                  Text(
                    'by ${book.author}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: const Color.fromARGB(255, 117, 117, 117),
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Condition & Status
                  Row(
                    children: [
                      _buildInfoChip(
                        context,
                        label: 'Condition',
                        value: book.condition.label,
                        color: _getConditionColor(book.condition),
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        context,
                        label: 'Status',
                        value: book.status.label,
                        color: _getStatusColor(book.status),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Owner Info
                  const Text(
                    'Owner',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  userProfileAsync.when(
                    data: (profile) {
                      if (profile == null) return const Text('Unknown user');
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(profile.displayName[0].toUpperCase()),
                          ),
                          title: Text(profile.displayName),
                          subtitle: Text(profile.email),
                        ),
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => Text('Error: $error'),
                  ),
                  const SizedBox(height: 24),

                  // Listed Date
                  Text(
                    'Listed on ${DateFormat('MMM d, y').format(book.createdAt)}',
                    style: const TextStyle(
                      color: Color.fromARGB(255, 117, 117, 117),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Button
                  if (!isOwner && book.status == BookStatus.available)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _showSwapDialog(context, ref, book),
                        icon: const Icon(Icons.swap_horiz),
                        label: const Text('Request Swap'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    final backgroundColor = color.withValues(alpha: 25); // 0.1 * 255 ≈ 25
    final borderColor = color.withValues(alpha: 76);     // 0.3 * 255 ≈ 76

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color.fromARGB(255, 117, 117, 117),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getConditionColor(BookCondition condition) {
    switch (condition) {
      case BookCondition.newCondition:
        return const Color.fromARGB(255, 0, 128, 0).withValues();
      case BookCondition.likeNew:
        return const Color.fromARGB(255, 0, 0, 255).withValues();
      case BookCondition.good:
        return const Color.fromARGB(255, 255, 165, 0).withValues();
      case BookCondition.used:
        return const Color.fromARGB(255, 128, 128, 128).withValues();
    }
  }

  Color _getStatusColor(BookStatus status) {
    switch (status) {
      case BookStatus.available:
        return const Color.fromARGB(255, 0, 128, 0).withValues();
      case BookStatus.pending:
        return const Color.fromARGB(255, 255, 165, 0).withValues();
      case BookStatus.swapped:
        return const Color.fromARGB(255, 128, 128, 128).withValues();
    }
  }

  void _showSwapDialog(BuildContext context, WidgetRef ref, BookModel book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Swap'),
        content: Text(
          'Would you like to request a swap for "${book.title}"?\n\n'
          'The book owner will be notified of your request.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await _initiateSwap(context, ref, book);
            },
            child: const Text('Request Swap'),
          ),
        ],
      ),
    );
  }

  Future<void> _initiateSwap(
    BuildContext context,
    WidgetRef ref,
    BookModel book,
  ) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      final currentUserId = ref.read(currentUserIdProvider);

      if (currentUserId == null) {
        throw Exception('You must be logged in to swap books');
      }

      final swap = SwapModel(
        swapId: '',
        bookId: book.bookId,
        senderId: currentUserId,
        receiverId: book.userId,
        createdAt: DateTime.now(),
      );

      await firestoreService.createSwap(swap);

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('✅ Swap request sent!'),
          backgroundColor: Color.fromARGB(255, 0, 128, 0),
        ),
      );

      navigator.pop(); // Go back to browse screen
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: const Color.fromARGB(255, 255, 0, 0),
        ),
      );
    }
  }
}
