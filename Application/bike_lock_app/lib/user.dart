import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String? username;
  final String? password;

  User({
    this.username,
    this.password,
  });

  factory User.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return User(
      username: data?['username'],
      password: data?['password'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (username != null) "Username": username,
      if (password != null) "Password": password,
    };
  }
}
