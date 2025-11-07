import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';
import '../models/book_model.dart';
import '../models/swap_model.dart';

// Firestore Service Provider
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// ==================== BOOK PROVIDERS ====================

// All Available Books Stream Provider
final availableBooksProvider = StreamProvider<List<BookModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getAllAvailableBooks();
});

// User's Books Stream Provider
final userBooksProvider = StreamProvider<List<BookModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getUserBooks();
});

// Single Book Provider
final bookProvider = FutureProvider.family<BookModel?, String>((ref, bookId) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return await firestoreService.getBookById(bookId);
});

// User's Available Books (filtered by status)
final userAvailableBooksProvider = Provider<List<BookModel>>((ref) {
  final userBooksAsync = ref.watch(userBooksProvider);
  return userBooksAsync.maybeWhen(
    data: (books) => books.where((book) => book.status == BookStatus.available).toList(),
    orElse: () => [],
  );
});

// User's Pending Books (books with pending swaps)
final userPendingBooksProvider = Provider<List<BookModel>>((ref) {
  final userBooksAsync = ref.watch(userBooksProvider);
  return userBooksAsync.maybeWhen(
    data: (books) => books.where((book) => book.status == BookStatus.pending).toList(),
    orElse: () => [],
  );
});

// User's Swapped Books
final userSwappedBooksProvider = Provider<List<BookModel>>((ref) {
  final userBooksAsync = ref.watch(userBooksProvider);
  return userBooksAsync.maybeWhen(
    data: (books) => books.where((book) => book.status == BookStatus.swapped).toList(),
    orElse: () => [],
  );
});

// ==================== SWAP PROVIDERS ====================

// Sent Swaps Stream Provider
final sentSwapsProvider = StreamProvider<List<SwapModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getSentSwaps();
});

// Received Swaps Stream Provider
final receivedSwapsProvider = StreamProvider<List<SwapModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getReceivedSwaps();
});

// All User Swaps Stream Provider
final allUserSwapsProvider = StreamProvider<List<SwapModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getAllUserSwaps();
});

// Pending Swaps (sent or received)
final pendingSwapsProvider = Provider<List<SwapModel>>((ref) {
  final allSwapsAsync = ref.watch(allUserSwapsProvider);
  return allSwapsAsync.maybeWhen(
    data: (swaps) => swaps.where((swap) => swap.status == SwapStatus.pending).toList(),
    orElse: () => [],
  );
});

// Accepted Swaps
final acceptedSwapsProvider = Provider<List<SwapModel>>((ref) {
  final allSwapsAsync = ref.watch(allUserSwapsProvider);
  return allSwapsAsync.maybeWhen(
    data: (swaps) => swaps.where((swap) => swap.status == SwapStatus.accepted).toList(),
    orElse: () => [],
  );
});

// Single Swap Provider
final swapProvider = FutureProvider.family<SwapModel?, String>((ref, swapId) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return await firestoreService.getSwapById(swapId);
});

// Swaps for a specific book
final bookSwapsProvider = StreamProvider.family<List<SwapModel>, String>((ref, bookId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getSwapsForBook(bookId);
});