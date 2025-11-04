enum SwapStatus {
  pending('Pending'),
  accepted('Accepted'),
  rejected('Rejected'),
  completed('Completed');

  final String label;
  const SwapStatus(this.label);
}

class SwapModel {
  final String swapId;
  final String bookId;
  final String senderId; // User who initiated the swap
  final String receiverId; // User who owns the book
  final SwapStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  SwapModel({
    required this.swapId,
    required this.bookId,
    required this.senderId,
    required this.receiverId,
    this.status = SwapStatus.pending,
    required this.createdAt,
    this.updatedAt,
  });

  // Convert SwapModel to Map (for Firestore)
  Map<String, dynamic> toJson() {
    return {
      'swapId': swapId,
      'bookId': bookId,
      'senderId': senderId,
      'receiverId': receiverId,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create SwapModel from Firestore Map
  factory SwapModel.fromJson(Map<String, dynamic> json) {
    return SwapModel(
      swapId: json['swapId'] as String,
      bookId: json['bookId'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      status: SwapStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SwapStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  // Create a copy with modified fields
  SwapModel copyWith({
    String? swapId,
    String? bookId,
    String? senderId,
    String? receiverId,
    SwapStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SwapModel(
      swapId: swapId ?? this.swapId,
      bookId: bookId ?? this.bookId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}