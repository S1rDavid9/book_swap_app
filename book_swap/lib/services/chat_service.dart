import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../core/constants/app_constants.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Get or create a chat between two users
  Future<String> getOrCreateChat(String otherUserId) async {
    if (currentUserId == null) throw Exception('Not logged in');

    // Create a consistent chat ID (smaller ID first)
    final List<String> userIds = [currentUserId!, otherUserId]..sort();
    final String chatId = '${userIds[0]}_${userIds[1]}';

    // Check if chat exists
    final chatDoc = await _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .get();

    if (!chatDoc.exists) {
      // Create new chat
      final chat = ChatModel(
        chatId: chatId,
        user1Id: userIds[0],
        user2Id: userIds[1],
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.chatsCollection)
          .doc(chatId)
          .set(chat.toJson());
    }

    return chatId;
  }

  // Get all chats for current user
  Stream<List<ChatModel>> getUserChats() {
    if (currentUserId == null) throw Exception('Not logged in');

    return _firestore
        .collection(AppConstants.chatsCollection)
        .where('user1Id', isEqualTo: currentUserId)
        .snapshots()
        .asyncMap((snapshot1) async {
      final chats1 = snapshot1.docs
          .map((doc) => ChatModel.fromJson(doc.data()))
          .toList();

      final snapshot2 = await _firestore
          .collection(AppConstants.chatsCollection)
          .where('user2Id', isEqualTo: currentUserId)
          .get();

      final chats2 = snapshot2.docs
          .map((doc) => ChatModel.fromJson(doc.data()))
          .toList();

      final allChats = [...chats1, ...chats2];
      
      // Sort by last message time
      allChats.sort((a, b) {
        if (a.lastMessageTime == null) return 1;
        if (b.lastMessageTime == null) return -1;
        return b.lastMessageTime!.compareTo(a.lastMessageTime!);
      });

      return allChats;
    });
  }

  // Send a message
  Future<void> sendMessage(String chatId, String text) async {
    if (currentUserId == null) throw Exception('Not logged in');
    if (text.trim().isEmpty) return;

    final messageId = _firestore.collection('messages').doc().id;
    final now = DateTime.now();

    final message = MessageModel(
      messageId: messageId,
      chatId: chatId,
      senderId: currentUserId!,
      text: text.trim(),
      timestamp: now,
    );

    // Add message
    await _firestore
        .collection('messages')
        .doc(messageId)
        .set(message.toJson());

    // Update chat's last message
    await _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .update({
      'lastMessage': text.trim(),
      'lastMessageTime': now.toIso8601String(),
      'lastMessageSenderId': currentUserId,
    });
  }

  // Get messages for a chat
Stream<List<MessageModel>> getChatMessages(String chatId) {
  return _firestore
      .collection('messages')
      .where('chatId', isEqualTo: chatId)
      .orderBy('timestamp', descending: true)
      .limit(100) // Limit to last 100 messages
      .snapshots()
      .map((snapshot) {
    debugPrint('📨 Received ${snapshot.docs.length} messages for chat $chatId');
    return snapshot.docs.map((doc) {
      final data = doc.data();
      debugPrint('Message data: $data');
      return MessageModel.fromJson(data);
    }).toList();
  });
}

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatId) async {
    if (currentUserId == null) return;

    final messages = await _firestore
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .where('senderId', isNotEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in messages.docs) {
      await doc.reference.update({'isRead': true});
    }
  }
}