import 'dart:convert';
class Todo {
  final String title;
  final String description;
  bool isCompleted;

  Todo({
    required this.title,
    required this.description,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
    };
  }

  factory Todo.fromJson(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    return Todo(
      title: map['title'],
      description: map['description'],
      isCompleted: map['isCompleted'],
    );
  }
}