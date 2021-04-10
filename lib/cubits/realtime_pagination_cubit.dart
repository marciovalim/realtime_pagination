import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import './realtime_pagination_state.dart';

export './realtime_pagination_state.dart';

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

  final _pages = <Page>[];
  final _streamSubs = <StreamSubscription<QuerySnapshot>>[];
  DocumentSnapshot _lastDocument;
  bool _hasReachedEnd = false;

  void loadMoreData() {
    if (_hasReachedEnd || _isLoadingMoreData) return;
    _setIsLoading(true);
    final currentIndex = _pages.length;
    final sub = _getQuery().snapshots().listen((snapshot) {
      if (snapshot.docs.isEmpty) {
        _onEndReached();
      } else {
        _hasReachedEnd = false;
      }
      final pageAlreadyExists = currentIndex < _pages.length;
      if (!pageAlreadyExists && _hasReachedEnd) return;
      final loadedPage = Page(snapshot.docs);
      if (pageAlreadyExists) {
        _pages[currentIndex] = loadedPage;
      } else {
        _pages.add(loadedPage);
        _setIsLoading(false);
        _lastDocument = loadedPage.docs.last;
      }
      _atualizeState();
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

  void _atualizeState() {
    emit(RealtimePaginationState(
      docs: foldAllPages(),
      isLoadingMore: _isLoadingMoreData,
    ));
  }

  List<DocumentSnapshot> foldAllPages() {
    final allDocs = _pages.fold<List<DocumentSnapshot>>(
      <DocumentSnapshot>[],
      (allDocs, page) => allDocs..addAll(page.docs),
    );
    return _removeDocumentsDuplications(allDocs);
  }

  List<DocumentSnapshot> _removeDocumentsDuplications(
    List<DocumentSnapshot> docs,
  ) {
    final allDocIds = <String>{};
    return docs.where((doc) => allDocIds.add(doc.id)).toList();
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

  // @override
  // String toString() {
  //   var string = "[\n";
  //   docs.forEach((doc) {
  //     final data = doc.data();
  //     string += data["image"];
  //     string += ", \n";
  //   });
  //   string += "]";
  //   return string;
  // }
}
