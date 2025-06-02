import 'package:equatable/equatable.dart';

class Post extends Equatable {
  final int id;
  final String title;
  final String body;
  final int userId;

  const Post({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
  });

  // Factory for JSON deserialization
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      userId: json['userId'] ?? 0,
    );
  }

  // Method for JSON serialization
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'userId': userId,
  };

  // Named constructor for local post creation
  Post.local({
    required String title,
    required String body,
    int? id,
    int? userId,
  })  : title = title,
        body = body,
        id = id ?? DateTime.now().millisecondsSinceEpoch, // generate unique local ID
        userId = userId ?? 0;

  @override
  List<Object?> get props => [id, title, body, userId];
}
