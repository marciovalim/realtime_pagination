import 'package:flutter/material.dart';
import 'package:realtime_pagination_example/models/post.dart';

class PostWidget extends StatelessWidget {
  final Post post;

  const PostWidget(this.post, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        tileColor: Colors.grey[200],
        title: Text(post.title!),
      ),
    );
  }
}
