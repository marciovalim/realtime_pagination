import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'cubits/realtime_pagination_cubit.dart';
import 'widgets/default_initial_loading.dart';
import 'widgets/paginated_list.dart';
import 'widgets/default_empty_display.dart';
import 'widgets/default_bottom_loader.dart';

typedef ItemBuilderDelegate = Widget Function(
  int index,
  BuildContext context,
  DocumentSnapshot docSnapshot,
);

typedef PaginatedBuilderDelegate = Widget Function(
  int itemCount,
  ScrollController controller,
  Widget Function(BuildContext context, int index) itemBuilder,
);

class RealtimePagination extends StatefulWidget {
  /// Quantity of items per page
  final int itemsPerPage;

  /// The Firestore query to make
  final Query query;

  /// If should use RefreshIndicator
  final bool useRefreshIndicator;

  /// Function to call when refreshed, if useRefreshIndicator is true.
  final Function onRefresh;

  /// Widget to show when first fetching the query.
  final Widget initialLoading;

  /// Widget to show when the query return no documents
  final Widget emptyDisplay;

  /// Widget to show at the under the last document, when the package is loading more documents.
  final Widget bottomLoader;

  /// The scroll threshold before start to load new documents. (0...1)
  final double scrollThreshold;

  /// The Function called to build a document loaded.
  final ItemBuilderDelegate itemBuilder;

  /// Return a ListView.builder or ListView.separated, assigning the passed properties.
  /// The rest is fully customizable.
  final PaginatedBuilderDelegate customPaginatedBuilder;

  /// You can pass your own instance of scrollController.
  /// No need to dispose, already dispose internally.
  final ScrollController scrollController;

  const RealtimePagination({
    Key key,
    @required this.query,
    @required this.itemsPerPage,
    @required this.itemBuilder,
    this.customPaginatedBuilder,
    this.scrollThreshold = 0.85,
    this.initialLoading,
    this.emptyDisplay,
    this.bottomLoader,
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
          paginatedBuilderDelegate: widget.customPaginatedBuilder,
          realtimePaginationCubit: _realtimePaginationCubit,
          scrollController: _scrollController,
          initialLoading: widget.initialLoading,
          bottomLoader: widget.bottomLoader,
          emptyDisplay: widget.emptyDisplay,
          itemBuilder: widget.itemBuilder,
        ),
      );
    }
    return _DocsStream(
      paginatedBuilderDelegate: widget.customPaginatedBuilder,
      realtimePaginationCubit: _realtimePaginationCubit,
      scrollController: _scrollController,
      initialLoading: widget.initialLoading,
      bottomLoader: widget.bottomLoader,
      emptyDisplay: widget.emptyDisplay,
      itemBuilder: widget.itemBuilder,
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
  final Widget initialLoading;
  final Widget emptyDisplay;
  final Widget bottomLoader;
  final ItemBuilderDelegate itemBuilder;
  final RealtimePaginationCubit _realtimePaginationCubit;
  final ScrollController _scrollController;
  final PaginatedBuilderDelegate paginatedBuilderDelegate;

  const _DocsStream({
    Key key,
    @required RealtimePaginationCubit realtimePaginationCubit,
    @required ScrollController scrollController,
    @required this.initialLoading,
    @required this.emptyDisplay,
    @required this.bottomLoader,
    @required this.itemBuilder,
    @required this.paginatedBuilderDelegate,
  })  : _realtimePaginationCubit = realtimePaginationCubit,
        _scrollController = scrollController,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<RealtimePaginationState>(
      stream: _realtimePaginationCubit.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.waiting) {
          final state = snapshot.data;
          if (state.docs.isEmpty) {
            return emptyDisplay ?? DefaultEmptyDisplay();
          }

          return PaginatedList(
            itemBuilder: itemBuilder,
            paginatedBuilder: paginatedBuilderDelegate,
            scrollController: _scrollController,
            docs: state.docs,
            isLoadingMore: state.isLoadingMore,
            bottomLoader: bottomLoader ?? DefaultBottomLoader(),
          );
        }
        return initialLoading ?? DefaultInitialLoading();
      },
    );
  }
}
