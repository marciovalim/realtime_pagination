import 'package:flutter/material.dart';

class DefaultBottomLoader extends StatelessWidget {
  const DefaultBottomLoader({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child: CircularProgressIndicator());
  }
}
