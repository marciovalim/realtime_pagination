import 'package:flutter/material.dart';

class DefaultInitialLoading extends StatelessWidget {
  const DefaultInitialLoading({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child: CircularProgressIndicator());
  }
}
