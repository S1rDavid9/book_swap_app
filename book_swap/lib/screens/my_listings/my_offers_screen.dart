import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/swap_model.dart';
import '../../providers/providers.dart';
import '../chats/chat_detail_screen.dart';

class MyOffersScreen extends ConsumerWidget {
  const MyOffersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Offers'),
          bottom: TabBar(
            indicatorColor: const Color(0xFFFFB300), // Gold indicator
            indicatorWeight: 3,
            labelColor: const Color(0xFFFFB300), // Gold when selected
            unselectedLabelColor: Colors.white70,
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
            tabs: const [
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
                      backgroundColor: const Color(0xFF1A237E),
                      foregroundColor: Colors.white,
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

            // Start Chat Button & Complete Swap (for accepted swaps)
            if (swap.status == SwapStatus.accepted)
              otherUserAsync.when(
                data: (user) {
                  if (user == null) return const SizedBox();
                  return Column(
                    children: [
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => _startChat(context, ref, otherUserId, user),
                          icon: const Icon(Icons.chat),
                          label: const Text('Start Chat'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFFB300),
                            foregroundColor: const Color(0xFF1A237E),
                          ),
                        ),
                      ),
                      // Complete Swap Button (only for requester)
                      if (isSender)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _showCompleteSwapDialog(context, ref, swap.swapId),
                              icon: const Icon(Icons.check_circle),
                              label: const Text('I Received the Book'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.green,
                                side: const BorderSide(color: Colors.green),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
                loading: () => const SizedBox(),
                error: (error, stack) => const SizedBox(),
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

  void _showCompleteSwapDialog(BuildContext context, WidgetRef ref, String swapId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Swap'),
        content: const Text(
          'Have you received the book?\n\n'
          'This will transfer the book to your collection and mark the swap as completed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Not Yet'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await _completeSwap(context, ref, swapId);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Yes, Complete'),
          ),
        ],
      ),
    );
  }

  Future<void> _completeSwap(
    BuildContext context,
    WidgetRef ref,
    String swapId,
  ) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      await firestoreService.completeSwap(swapId);

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('✅ Swap completed! The book is now in your collection.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
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

  Future<void> _startChat(
    BuildContext context,
    WidgetRef ref,
    String otherUserId,
    dynamic user,
  ) async {
    try {
      final chatService = ref.read(chatServiceProvider);
      final chatId = await chatService.getOrCreateChat(otherUserId);
      
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(
              chatId: chatId,
              otherUser: user,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}