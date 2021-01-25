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
  final bool useRefreshIndicator;
  final Function onRefresh;
  final double listViewCacheExtent;
  final Widget initialLoading;
  final Widget emptyDisplay;
  final Widget bottomLoader;
  final ItemBuilderDelegate itemBuilder;
  final Axis scrollDirection;
  final ItemBuilderDelegate separatedBuilder;
  final double scrollThreshold;
  final bool reverse;

  /// You can pass your own instance of scrollController.
  /// No need to dispose, already dispose internally.
  final ScrollController scrollController;

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
    this.useRefreshIndicator = false,
    this.onRefresh,
    this.scrollController,
  }) : super(key: key);

  @override
  _RealtimePaginationState createState() => _RealtimePaginationState();
}

class _RealtimePaginationState extends State<RealtimePagination> {
  ScrollController _scrollController;

  RealtimePaginationCubit _realtimePaginationCubit;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_scrollListener);
    _start();
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
    if (widget.useRefreshIndicator) {
      return RefreshIndicator(
        onRefresh: () async {
          widget.onRefresh?.call();
          await _start();
        },
        child: _DocsStream(
          realtimePaginationCubit: _realtimePaginationCubit,
          scrollController: _scrollController,
          initialLoading: widget.initialLoading,
          bottomLoader: widget.bottomLoader,
          emptyDisplay: widget.emptyDisplay,
          itemBuilder: widget.itemBuilder,
          listViewCacheExtent: widget.listViewCacheExtent,
          reverse: widget.reverse,
          scrollDirection: widget.scrollDirection,
          separatedBuilder: widget.separatedBuilder,
        ),
      );
    }
    return _DocsStream(
      realtimePaginationCubit: _realtimePaginationCubit,
      scrollController: _scrollController,
      initialLoading: widget.initialLoading,
      bottomLoader: widget.bottomLoader,
      emptyDisplay: widget.emptyDisplay,
      itemBuilder: widget.itemBuilder,
      listViewCacheExtent: widget.listViewCacheExtent,
      reverse: widget.reverse,
      scrollDirection: widget.scrollDirection,
      separatedBuilder: widget.separatedBuilder,
    );
  }

  Future<void> _start() async {
    if (_realtimePaginationCubit != null) {
      await _realtimePaginationCubit.close();
    }
    _realtimePaginationCubit = RealtimePaginationCubit(
      limit: widget.itemsPerPage,
      query: widget.query,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _realtimePaginationCubit.close();
    super.dispose();
  }
}

class _DocsStream extends StatelessWidget {
  final double listViewCacheExtent;
  final Widget initialLoading;
  final Widget emptyDisplay;
  final Widget bottomLoader;
  final ItemBuilderDelegate itemBuilder;
  final Axis scrollDirection;
  final ItemBuilderDelegate separatedBuilder;
  final bool reverse;
  final RealtimePaginationCubit _realtimePaginationCubit;
  final ScrollController _scrollController;

  const _DocsStream({
    Key key,
    @required RealtimePaginationCubit realtimePaginationCubit,
    @required ScrollController scrollController,
    @required this.listViewCacheExtent,
    @required this.initialLoading,
    @required this.emptyDisplay,
    @required this.bottomLoader,
    @required this.itemBuilder,
    @required this.scrollDirection,
    @required this.separatedBuilder,
    @required this.reverse,
  })  : _realtimePaginationCubit = realtimePaginationCubit,
        _scrollController = scrollController,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<RealtimePaginationState>(
      stream: _realtimePaginationCubit,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.waiting) {
          final state = snapshot.data;
          if (state.docs.length == 0) {
            return emptyDisplay ?? DefaultEmptyDisplay();
          }

          return PaginatedList(
            reverse: reverse,
            scrollDirection: scrollDirection,
            itemBuilder: itemBuilder,
            scrollController: _scrollController,
            separatedItemBuilder: separatedBuilder,
            docs: state.docs,
            cacheExtent: listViewCacheExtent,
            isLoadingMore: state.isLoadingMore,
            bottomLoader: bottomLoader ?? DefaultBottomLoader(),
          );
        }
        return initialLoading ?? DefaultInitialLoading();
      },
    );
  }
}
