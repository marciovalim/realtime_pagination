import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class RealtimePaginationState {
  final List<DocumentSnapshot> docs;
  final bool isLoadingMore;

  const RealtimePaginationState({
    @required this.docs,
    @required this.isLoadingMore,
  });

  factory RealtimePaginationState.initial() {
    return RealtimePaginationState(
      docs: List<DocumentSnapshot>(),
      isLoadingMore: false,
    );
  }
}

class RealtimePaginationCubit extends Cubit<RealtimePaginationState> {
  final int limit;
  final Query query;
  final bool listenToCreations;

  RealtimePaginationCubit({
    @required this.limit,
    @required this.query,
    this.listenToCreations = true,
  }) : super(RealtimePaginationState.initial()) {
    loadMoreData();
  }

  bool get isLoadingMoreData => _isLoadingMoreData;
  bool _isLoadingMoreData = false;

  final _pages = List<Page>();
  final _streamSubs = List<StreamSubscription<QuerySnapshot>>();
  DocumentSnapshot _lastDocument;
  bool _hasReachedEnd = false;

  void loadMoreData() {
    if (_hasReachedEnd || _isLoadingMoreData) return;
    _setIsLoading(true);
    final currentIndex = _pages.length;
    final sub = _getQuery().snapshots().listen((snapshot) {
      if (snapshot.size == 0) {
        _onEndReached();
        return;
      }
      final pageAlreadyExists = currentIndex < _pages.length;
      final loadedPage = Page(snapshot.docs);
      if (pageAlreadyExists) {
        _pages[currentIndex] = loadedPage;
      } else {
        _pages.add(loadedPage);
        _setIsLoading(false);
        _lastDocument = loadedPage.docs.last;
      }
      emit(RealtimePaginationState(
        docs: _allPagesFolded,
        isLoadingMore: _isLoadingMoreData,
      ));
    });
    _streamSubs.add(sub);
  }

  void _setIsLoading(bool value) {
    _isLoadingMoreData = value;
    emit(RealtimePaginationState(docs: state.docs, isLoadingMore: value));
  }

  Query _getQuery() {
    if (_lastDocument != null) {
      return query.startAfterDocument(_lastDocument).limit(limit);
    }
    return query.limit(limit);
  }

  void _onEndReached() {
    _hasReachedEnd = true;
    _setIsLoading(false);
    if (!listenToCreations) {
      final lastSub = _streamSubs.removeLast();
      lastSub.cancel();
    }
  }

  List<DocumentSnapshot> get _allPagesFolded {
    return _pages.fold(
      List<DocumentSnapshot>(),
      (allDocs, page) => allDocs..addAll(page.docs),
    );
  }

  @override
  Future<void> close() {
    _streamSubs.forEach((sub) => sub.cancel());
    return super.close();
  }
}

class Page {
  final List<DocumentSnapshot> docs;

  const Page(this.docs);
}
