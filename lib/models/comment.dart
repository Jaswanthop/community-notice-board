class Comment {
  const Comment({
    required this.id,
    required this.author,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String author;
  final String text;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'author': author,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String? ?? '',
      author: json['author'] as String? ?? 'Anonymous',
      text: json['text'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Comment copyWith({String? text, DateTime? createdAt}) {
    return Comment(
      id: id,
      author: author,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Comment &&
            other.id == id &&
            other.author == author &&
            other.text == text &&
            other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(id, author, text, createdAt);
}
