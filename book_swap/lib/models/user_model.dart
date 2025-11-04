class UserModel {
  final String userId;
  final String email;
  final String displayName;
  final String? profilePicture;
  final DateTime createdAt;

  UserModel({
    required this.userId,
    required this.email,
    required this.displayName,
    this.profilePicture,
    required this.createdAt,
  });

  // Convert UserModel to Map (for Firestore)
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'displayName': displayName,
      'profilePicture': profilePicture,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create UserModel from Firestore Map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      profilePicture: json['profilePicture'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // Create a copy with modified fields
  UserModel copyWith({
    String? userId,
    String? email,
    String? displayName,
    String? profilePicture,
    DateTime? createdAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      profilePicture: profilePicture ?? this.profilePicture,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}