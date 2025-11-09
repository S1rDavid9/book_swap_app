import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book_model.dart';
import '../models/swap_model.dart';
import '../core/constants/app_constants.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // ==================== BOOK OPERATIONS ====================

  // Create a new book listing
  Future<String> createBook(BookModel book) async {
    try {
      final docRef = await _firestore
          .collection(AppConstants.booksCollection)
          .add(book.toJson());
      
      // Update the document with its own ID
      await docRef.update({'bookId': docRef.id});
      
      return docRef.id;
    } catch (e) {
      throw Exception('Error creating book: $e');
    }
  }

  // Get all available books (excluding current user's books)
  Stream<List<BookModel>> getAllAvailableBooks() {
    try {
      return _firestore
          .collection(AppConstants.booksCollection)
          .where('status', isEqualTo: BookStatus.available.name)
          .where('userId', isNotEqualTo: currentUserId)
          .orderBy('userId')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => BookModel.fromJson(doc.data()))
            .toList();
      });
    } catch (e) {
      throw Exception('Error fetching available books: $e');
    }
  }

  // Get current user's books
  Stream<List<BookModel>> getUserBooks() {
    try {
      if (currentUserId == null) {
        throw Exception('No user logged in');
      }

      return _firestore
          .collection(AppConstants.booksCollection)
          .where('userId', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => BookModel.fromJson(doc.data()))
            .toList();
      });
    } catch (e) {
      throw Exception('Error fetching user books: $e');
    }
  }

  // Get a single book by ID
  Future<BookModel?> getBookById(String bookId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.booksCollection)
          .doc(bookId)
          .get();

      if (doc.exists) {
        return BookModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching book: $e');
    }
  }

  // Update a book listing
  Future<void> updateBook(String bookId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = DateTime.now().toIso8601String();
      
      await _firestore
          .collection(AppConstants.booksCollection)
          .doc(bookId)
          .update(updates);
    } catch (e) {
      throw Exception('Error updating book: $e');
    }
  }

  // Update book status
  Future<void> updateBookStatus(String bookId, BookStatus status) async {
    try {
      await updateBook(bookId, {
        'status': status.name,
      });
    } catch (e) {
      throw Exception('Error updating book status: $e');
    }
  }

  // Delete a book listing
  Future<void> deleteBook(String bookId) async {
    try {
      await _firestore
          .collection(AppConstants.booksCollection)
          .doc(bookId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting book: $e');
    }
  }

  // ==================== SWAP OPERATIONS ====================

  // Create a swap offer
  Future<String> createSwap(SwapModel swap) async {
    try {
      // Create swap document
      final docRef = await _firestore
          .collection(AppConstants.swapsCollection)
          .add(swap.toJson());
      
      // Update the document with its own ID
      await docRef.update({'swapId': docRef.id});

      // Update book status to pending
      await updateBookStatus(swap.bookId, BookStatus.pending);
      
      return docRef.id;
    } catch (e) {
      throw Exception('Error creating swap: $e');
    }
  }

  // Get swaps where current user is the sender
  Stream<List<SwapModel>> getSentSwaps() {
    try {
      if (currentUserId == null) {
        throw Exception('No user logged in');
      }

      return _firestore
          .collection(AppConstants.swapsCollection)
          .where('senderId', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => SwapModel.fromJson(doc.data()))
            .toList();
      });
    } catch (e) {
      throw Exception('Error fetching sent swaps: $e');
    }
  }

  // Get swaps where current user is the receiver
  Stream<List<SwapModel>> getReceivedSwaps() {
    try {
      if (currentUserId == null) {
        throw Exception('No user logged in');
      }

      return _firestore
          .collection(AppConstants.swapsCollection)
          .where('receiverId', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => SwapModel.fromJson(doc.data()))
            .toList();
      });
    } catch (e) {
      throw Exception('Error fetching received swaps: $e');
    }
  }

  // Get all swaps for current user (both sent and received)
  Stream<List<SwapModel>> getAllUserSwaps() {
    try {
      if (currentUserId == null) {
        throw Exception('No user logged in');
      }

      return _firestore
          .collection(AppConstants.swapsCollection)
          .where('senderId', isEqualTo: currentUserId)
          .snapshots()
          .asyncMap((sentSnapshot) async {
        // Get received swaps
        final receivedSnapshot = await _firestore
            .collection(AppConstants.swapsCollection)
            .where('receiverId', isEqualTo: currentUserId)
            .get();

        // Combine both lists
        final allSwaps = <SwapModel>[];
        
        for (var doc in sentSnapshot.docs) {
          allSwaps.add(SwapModel.fromJson(doc.data()));
        }
        
        for (var doc in receivedSnapshot.docs) {
          allSwaps.add(SwapModel.fromJson(doc.data()));
        }

        // Sort by creation date
        allSwaps.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        
        return allSwaps;
      });
    } catch (e) {
      throw Exception('Error fetching user swaps: $e');
    }
  }

  // Update swap status
  Future<void> updateSwapStatus(String swapId, SwapStatus status) async {
    try {
      await _firestore
          .collection(AppConstants.swapsCollection)
          .doc(swapId)
          .update({
        'status': status.name,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // If swap is rejected, update book status back to available
      if (status == SwapStatus.rejected) {
        final swap = await getSwapById(swapId);
        if (swap != null) {
          await updateBookStatus(swap.bookId, BookStatus.available);
        }
      }

      // If swap is accepted, update book status to swapped
      if (status == SwapStatus.accepted || status == SwapStatus.completed) {
        final swap = await getSwapById(swapId);
        if (swap != null) {
          await updateBookStatus(swap.bookId, BookStatus.swapped);
        }
      }
    } catch (e) {
      throw Exception('Error updating swap status: $e');
    }
  }

  // Get a single swap by ID
  Future<SwapModel?> getSwapById(String swapId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.swapsCollection)
          .doc(swapId)
          .get();

      if (doc.exists) {
        return SwapModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching swap: $e');
    }
  }

  // Complete swap - transfer book ownership
Future<void> completeSwap(String swapId) async {
  try {
    // Get swap details
    final swap = await getSwapById(swapId);
    if (swap == null) throw Exception('Swap not found');
    
    // Get book details
    final book = await getBookById(swap.bookId);
    if (book == null) throw Exception('Book not found');
    
    // Transfer book ownership to the requester (sender)
    await updateBook(swap.bookId, {
      'userId': swap.senderId, // New owner is the person who requested
      'status': BookStatus.available.name, // Make it available again
    });
    
    // Update swap status to completed
    await updateSwapStatus(swapId, SwapStatus.completed);
  } catch (e) {
    throw Exception('Error completing swap: $e');
  }
}

  // Delete a swap
  Future<void> deleteSwap(String swapId) async {
    try {
      // Get swap details first
      final swap = await getSwapById(swapId);
      
      // Delete the swap
      await _firestore
          .collection(AppConstants.swapsCollection)
          .doc(swapId)
          .delete();

      // Update book status back to available if swap was pending
      if (swap != null && swap.status == SwapStatus.pending) {
        await updateBookStatus(swap.bookId, BookStatus.available);
      }
    } catch (e) {
      throw Exception('Error deleting swap: $e');
    }
  }

  // Get swaps for a specific book
  Stream<List<SwapModel>> getSwapsForBook(String bookId) {
    try {
      return _firestore
          .collection(AppConstants.swapsCollection)
          .where('bookId', isEqualTo: bookId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => SwapModel.fromJson(doc.data()))
            .toList();
      });
    } catch (e) {
      throw Exception('Error fetching swaps for book: $e');
    }
  }
}