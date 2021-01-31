# Realtime Pagination

A Flutter plugin to help use realtime pagination with Firebase Firestore.

## Basic Usage

```dart
@override
Widget build(BuildContext context) {
 return RealtimePagination(
     query: _firestore.where('coins', greaterThan: 10)
                      .orderBy("date"), // orderBy is required to pagination work properly
     itemsPerPage: 12,
     itemBuilder: (index, context, docSnapshot) {
       return null; // Build your item here
     }
  );
}
```

## Custom Builder

```dart
@override
Widget build(BuildContext context) {
 return RealtimePagination(
     query: _firestore.where('coins', greaterThan: 10)
                      .orderBy("date"), // orderBy is required to pagination work properly
     itemsPerPage: 12,
     itemBuilder: (index, context, docSnapshot) {
       return null; // Build your item here
     }

     // CUSTOM BUILDER HERE
     customPaginatedBuilder: (itemCount, controller, itemBuilder) {
       // ASSIGN THESE THREE PROPERTIES, CUSTOMIZE THE REST AS YOU WANT!
       return ListView.builder(
         controller: controller, // 1
         itemCount: itemCount, // 2
         itemBuilder: itemBuilder, // 3
       );
     },
  );
}
```
