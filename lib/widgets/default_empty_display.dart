import 'package:flutter/material.dart';

class DefaultEmptyDisplay extends StatelessWidget {
  const DefaultEmptyDisplay({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('No documents.'));
  }
}
