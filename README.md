# Realtime Pagination

A Flutter plugin to help use realtime pagination with Firebase Firestore. 

## Usage

<pre>
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
</pre>
