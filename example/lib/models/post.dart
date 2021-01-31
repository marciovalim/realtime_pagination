import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String title;
  final String content;
  final Timestamp createdAt;

  Post(this.content, this.createdAt, this.title);

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'createdAt': createdAt,
      'title': title,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Post(
      map['content'],
      map['createdAt'],
      map['title'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Post.fromJson(String source) => Post.fromMap(json.decode(source));
}
