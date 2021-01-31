import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../realtime_pagination.dart';

class PaginatedList extends StatelessWidget {
  final List<DocumentSnapshot> docs;
  final ItemBuilderDelegate itemBuilder;
  final ScrollController scrollController;
  final bool isLoadingMore;
  final Widget bottomLoader;
  final PaginatedBuilderDelegate paginatedBuilder;

  const PaginatedList({
    Key key,
    @required this.itemBuilder,
    @required this.docs,
    @required this.isLoadingMore,
    @required this.bottomLoader,
    @required this.scrollController,
    @required this.paginatedBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bias = isLoadingMore ? 1 : 0;
    final itemCount = docs.length + bias;

    if (paginatedBuilder != null) {
      return paginatedBuilder(itemCount, scrollController, _buildItem);
    }

    return ListView.builder(
      itemCount: itemCount,
      controller: scrollController,
      itemBuilder: _buildItem,
    );
  }

  Widget _buildItem(context, index) {
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
