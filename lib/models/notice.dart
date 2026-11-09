import 'package:flutter/foundation.dart';

import 'comment.dart';
import 'notice_category.dart';

class Notice {
  const Notice({
    required this.id,
    required this.title,
    required this.body,
    required this.author,
    required this.category,
    required this.createdAt,
    this.isPinned = false,
    this.isBookmarked = false,
    this.comments = const <Comment>[],
  });

  final String id;
  final String title;
  final String body;
  final String author;
  final NoticeCategory category;
  final DateTime createdAt;
  final bool isPinned;
  final bool isBookmarked;
  final List<Comment> comments;

  int get commentCount => comments.length;

  Notice copyWith({
    String? title,
    String? body,
    String? author,
    NoticeCategory? category,
    DateTime? createdAt,
    bool? isPinned,
    bool? isBookmarked,
    List<Comment>? comments,
  }) {
    return Notice(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      author: author ?? this.author,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      isPinned: isPinned ?? this.isPinned,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      comments: comments ?? this.comments,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'body': body,
      'author': author,
      'category': category.name,
      'createdAt': createdAt.toIso8601String(),
      'isPinned': isPinned,
      'isBookmarked': isBookmarked,
      'comments': comments.map((comment) => comment.toJson()).toList(),
    };
  }

  factory Notice.fromJson(Map<String, dynamic> json) {
    final rawComments = json['comments'];
    return Notice(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled notice',
      body: json['body'] as String? ?? '',
      author: json['author'] as String? ?? 'Anonymous',
      category: NoticeCategory.fromName(json['category'] as String?),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      isPinned: json['isPinned'] as bool? ?? false,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      comments: rawComments is List
          ? rawComments
                .whereType<Map<String, dynamic>>()
                .map(Comment.fromJson)
                .toList()
          : const <Comment>[],
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Notice &&
            other.id == id &&
            other.title == title &&
            other.body == body &&
            other.author == author &&
            other.category == category &&
            other.createdAt == createdAt &&
            other.isPinned == isPinned &&
            other.isBookmarked == isBookmarked &&
            listEquals(other.comments, comments);
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    body,
    author,
    category,
    createdAt,
    isPinned,
    isBookmarked,
    Object.hashAll(comments),
  );
}
