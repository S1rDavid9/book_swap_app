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
                    color: Colors.grey.shade200,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.book, size: 80),
                  ),
                ),
              )
            else
              Container(
                height: 200,
                color: Colors.grey.shade300,
                child: const Center(
                  child: Icon(Icons.book, size: 80, color: Colors.grey),
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
                          color: Colors.grey.shade600,
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
                    style: TextStyle(
                      color: Colors.grey.shade600,
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
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
        return Colors.green;
      case BookCondition.likeNew:
        return Colors.blue;
      case BookCondition.good:
        return Colors.orange;
      case BookCondition.used:
        return Colors.grey;
    }
  }

  Color _getStatusColor(BookStatus status) {
    switch (status) {
      case BookStatus.available:
        return Colors.green;
      case BookStatus.pending:
        return Colors.orange;
      case BookStatus.swapped:
        return Colors.grey;
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
          backgroundColor: Colors.green,
        ),
      );

      navigator.pop(); // Go back to browse screen
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}