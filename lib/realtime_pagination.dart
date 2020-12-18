import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'cubits/realtime_pagination_cubit.dart';
import 'widgets/default_initial_loading.dart';
import 'widgets/paginated_list.dart';
import 'widgets/default_empty_display.dart';
import 'widgets/default_bottom_loader.dart';

typedef Widget ItemBuilderDelegate(
  int index,
  BuildContext context,
  DocumentSnapshot docSnapshot,
);

class RealtimePagination extends StatefulWidget {
  final int itemsPerPage;
  final Query query;
  final double listViewCacheExtent;
  final Widget initialLoading;
  final Widget emptyDisplay;
  final Widget bottomLoader;
  final ItemBuilderDelegate itemBuilder;
  final Axis scrollDirection;
  final ItemBuilderDelegate separatedBuilder;
  final double scrollThreshold;
  final bool reverse;

  const RealtimePagination({
    Key key,
    @required this.query,
    @required this.itemsPerPage,
    @required this.itemBuilder,
    this.scrollThreshold = 0.85,
    this.initialLoading,
    this.emptyDisplay,
    this.listViewCacheExtent,
    this.bottomLoader,
    this.separatedBuilder,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
  }) : super(key: key);

  @override
  _RealtimePaginationState createState() => _RealtimePaginationState();
}

class _RealtimePaginationState extends State<RealtimePagination> {
  final _scrollController = ScrollController();

  RealtimePaginationCubit _realtimePaginationCubit;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _realtimePaginationCubit = RealtimePaginationCubit(
      limit: widget.itemsPerPage,
      query: widget.query,
    );
  }

  void _scrollListener() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final calculatedThreshold = widget.scrollThreshold * maxScroll;
    if (_scrollController.position.pixels >= calculatedThreshold) {
      _triggerMoreData();
    }
  }

  void _triggerMoreData() {
    _realtimePaginationCubit.loadMoreData();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<RealtimePaginationState>(
      stream: _realtimePaginationCubit,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.waiting) {
          final state = snapshot.data;
          if (state.docs.length == 0) {
            return widget.emptyDisplay ?? DefaultEmptyDisplay();
          }

          return PaginatedList(
            reverse: widget.reverse,
            scrollDirection: widget.scrollDirection,
            itemBuilder: widget.itemBuilder,
            scrollController: _scrollController,
            separatedItemBuilder: widget.separatedBuilder,
            docs: state.docs,
            cacheExtent: widget.listViewCacheExtent,
            isLoadingMore: state.isLoadingMore,
            bottomLoader: widget.bottomLoader ?? DefaultBottomLoader(),
          );
        }
        return widget.initialLoading ?? DefaultInitialLoading();
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _realtimePaginationCubit.close();
    super.dispose();
  }
}
