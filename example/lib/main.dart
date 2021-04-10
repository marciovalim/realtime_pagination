import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:realtime_pagination/realtime_pagination.dart';

import 'models/post.dart';
import 'widgets/post_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.green,
      ),
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Realtime Pagination'),
      ),
      body: RealtimePagination(
        query: _postsQuery(),
        itemsPerPage: 15,
        itemBuilder: (index, context, docSnapshot) {
          final post = Post.fromMap(docSnapshot.data());
          return PostWidget(post);
        },

        // CUSTOM BUILDER HERE
        customPaginatedBuilder: (itemCount, controller, itemBuilder) {
          // ASSIGN THESE THREE PROPERTIES, CUSTOMIZE THE REST AS YOU WANT!
          return ListView.builder(
            controller: controller, // 1
            itemCount: itemCount, // 2
            itemBuilder: itemBuilder, // 3
          );
        },
      ),
    );
  }

  Query _postsQuery() {
    return FirebaseFirestore.instance
        .collection('posts')
        .orderBy('createdAt', descending: true);
  }
}
