import 'package:flutter_riverpod/flutter_riverpod.dart';

// Global loading state provider
final loadingProvider = StateProvider<bool>((ref) => false);

// Loading state for specific operations
final authLoadingProvider = StateProvider<bool>((ref) => false);
final bookLoadingProvider = StateProvider<bool>((ref) => false);
final swapLoadingProvider = StateProvider<bool>((ref) => false);
final imageUploadLoadingProvider = StateProvider<bool>((ref) => false);