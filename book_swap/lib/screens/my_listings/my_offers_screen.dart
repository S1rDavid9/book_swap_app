import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/swap_model.dart';
import '../../models/book_model.dart';
import '../../providers/providers.dart';

class MyOffersScreen extends ConsumerWidget {
  const MyOffersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Offers'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Sent'),
              Tab(text: 'Received'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            SentOffersTab(),
            ReceivedOffersTab(),
          ],
        ),
      ),
    );
  }
}

// Sent Offers Tab
class SentOffersTab extends ConsumerWidget {
  const SentOffersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sentSwapsAsync = ref.watch(sentSwapsProvider);

    return sentSwapsAsync.when(
      data: (swaps) {
        if (swaps.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.swap_horiz, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No sent swap requests',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: swaps.length,
          itemBuilder: (context, index) {
            final swap = swaps[index];
            return SwapCard(
              swap: swap,
              isSender: true,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }
}

// Received Offers Tab
class ReceivedOffersTab extends ConsumerWidget {
  const ReceivedOffersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receivedSwapsAsync = ref.watch(receivedSwapsProvider);

    return receivedSwapsAsync.when(
      data: (swaps) {
        if (swaps.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.swap_horiz, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No received swap requests',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: swaps.length,
          itemBuilder: (context, index) {
            final swap = swaps[index];
            return SwapCard(
              swap: swap,
              isSender: false,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }
}

// Swap Card Widget
class SwapCard extends ConsumerWidget {
  final SwapModel swap;
  final bool isSender;

  const SwapCard({
    super.key,
    required this.swap,
    required this.isSender,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookAsync = ref.watch(bookProvider(swap.bookId));
    final otherUserId = isSender ? swap.receiverId : swap.senderId;
    final otherUserAsync = ref.watch(userProfileProvider(otherUserId));

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Swap Status Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(swap.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    swap.status.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('MMM d, y').format(swap.createdAt),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Book Info
            bookAsync.when(
              data: (book) {
                if (book == null) return const Text('Book not found');
                return Row(
                  children: [
                    Container(
                      width: 60,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: book.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                book.imageUrl!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.book, size: 30),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            book.author,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error loading book: $error'),
            ),
            const SizedBox(height: 16),

            // Other User Info
            otherUserAsync.when(
              data: (user) {
                if (user == null) return const Text('User not found');
                return Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      child: Text(user.displayName[0].toUpperCase()),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isSender ? 'Owner' : 'Requester',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            user.displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox(),
              error: (error, stack) => const Text('Error loading user'),
            ),

            // Action Buttons (only for receiver and pending status)
            if (!isSender && swap.status == SwapStatus.pending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _rejectSwap(context, ref, swap.swapId),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _acceptSwap(context, ref, swap.swapId),
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ],

            // Cancel button for sender
            if (isSender && swap.status == SwapStatus.pending) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _cancelSwap(context, ref, swap.swapId),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Cancel Request'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(SwapStatus status) {
    switch (status) {
      case SwapStatus.pending:
        return Colors.orange;
      case SwapStatus.accepted:
        return Colors.green;
      case SwapStatus.rejected:
        return Colors.red;
      case SwapStatus.completed:
        return Colors.blue;
    }
  }

  Future<void> _acceptSwap(
    BuildContext context,
    WidgetRef ref,
    String swapId,
  ) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      await firestoreService.updateSwapStatus(swapId, SwapStatus.accepted);

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('✅ Swap request accepted!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectSwap(
    BuildContext context,
    WidgetRef ref,
    String swapId,
  ) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      await firestoreService.updateSwapStatus(swapId, SwapStatus.rejected);

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Swap request rejected'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cancelSwap(
    BuildContext context,
    WidgetRef ref,
    String swapId,
  ) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      await firestoreService.deleteSwap(swapId);

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Swap request cancelled'),
          backgroundColor: Colors.orange,
        ),
      );
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