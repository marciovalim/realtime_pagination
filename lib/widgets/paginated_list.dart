import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../realtime_pagination.dart';

class PaginatedList extends StatelessWidget {
  final List<DocumentSnapshot> docs;
  final ItemBuilderDelegate itemBuilder;
  final ItemBuilderDelegate separatedItemBuilder;
  final bool isLoadingMore;
  final Widget bottomLoader;
  final Axis scrollDirection;
  final bool reverse;
  final ScrollController scrollController;
  final double cacheExtent;

  const PaginatedList({
    Key key,
    @required this.itemBuilder,
    @required this.docs,
    @required this.isLoadingMore,
    @required this.bottomLoader,
    @required this.scrollController,
    @required this.cacheExtent,
    @required this.separatedItemBuilder,
    @required this.scrollDirection,
    @required this.reverse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bias = isLoadingMore ? 1 : 0;
    final itemCount = docs.length + bias;
    if (separatedItemBuilder != null) {
      return ListView.separated(
        scrollDirection: scrollDirection,
        cacheExtent: cacheExtent,
        controller: scrollController,
        reverse: reverse,
        itemCount: itemCount,
        itemBuilder: _itemBuilder,
        separatorBuilder: (context, index) {
          return separatedItemBuilder(
            index,
            context,
            docs[index],
          );
        },
      );
    }
    return ListView.builder(
      cacheExtent: cacheExtent,
      controller: scrollController,
      itemCount: itemCount,
      reverse: reverse,
      scrollDirection: scrollDirection,
      itemBuilder: _itemBuilder,
    );
  }

  Widget _itemBuilder(context, index) {
    if (isLoadingMore && index >= docs.length) {
      return bottomLoader;
    }
    return itemBuilder(
      index,
      context,
      docs[index],
    );
  }
}
