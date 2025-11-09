import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/chat_service.dart';
import '../models/chat_model.dart';

// Chat Service Provider
final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService();
});

// User Chats Stream Provider
final userChatsProvider = StreamProvider<List<ChatModel>>((ref) {
  final chatService = ref.watch(chatServiceProvider);
  return chatService.getUserChats();
});

// Chat Messages Stream Provider
final chatMessagesProvider = StreamProvider.family<List<MessageModel>, String>((ref, chatId) {
  final chatService = ref.watch(chatServiceProvider);
  return chatService.getChatMessages(chatId);
});