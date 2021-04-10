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
      docs: <DocumentSnapshot>[],
      isLoadingMore: false,
    );
  }
}
