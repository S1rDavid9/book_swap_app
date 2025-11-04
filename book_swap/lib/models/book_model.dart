enum BookCondition {
  newCondition('New'),
  likeNew('Like New'),
  good('Good'),
  used('Used');

  final String label;
  const BookCondition(this.label);
}

enum BookStatus {
  available('Available'),
  pending('Pending'),
  swapped('Swapped');

  final String label;
  const BookStatus(this.label);
}

class BookModel {
  final String bookId;
  final String userId;
  final String title;
  final String author;
  final BookCondition condition;
  final String? imageUrl;
  final BookStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  BookModel({
    required this.bookId,
    required this.userId,
    required this.title,
    required this.author,
    required this.condition,
    this.imageUrl,
    this.status = BookStatus.available,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert BookModel to Map (for Firestore)
  Map<String, dynamic> toJson() {
    return {
      'bookId': bookId,
      'userId': userId,
      'title': title,
      'author': author,
      'condition': condition.name,
      'imageUrl': imageUrl,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create BookModel from Firestore Map
  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      bookId: json['bookId'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      condition: BookCondition.values.firstWhere(
        (e) => e.name == json['condition'],
        orElse: () => BookCondition.good,
      ),
      imageUrl: json['imageUrl'] as String?,
      status: BookStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BookStatus.available,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // Create a copy with modified fields
  BookModel copyWith({
    String? bookId,
    String? userId,
    String? title,
    String? author,
    BookCondition? condition,
    String? imageUrl,
    BookStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookModel(
      bookId: bookId ?? this.bookId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      author: author ?? this.author,
      condition: condition ?? this.condition,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}