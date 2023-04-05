import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String? username;
  final String? password;
  Map<String, dynamic>? friends;

  User({
    this.username,
    this.password,
    this.friends,
  });

  factory User.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return User(
      username: data?['Credentials']['username'],
      password: data?['Credentials']['password'],
      friends: data?['Friends'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (username != null) "Username": username,
      if (password != null) "Password": password,
    };
  }
}
