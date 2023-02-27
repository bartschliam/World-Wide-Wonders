import 'package:cloud_firestore/cloud_firestore.dart';

class Lock {
  final String? owner;
  final String? status;
  Map<String, dynamic>? coords;

  Lock({
    this.owner,
    this.status,
    this.coords,
  });

  factory Lock.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Lock(
      owner: data?['Credentials']['username'],
      status: data?['Credentials']['password'],
      coords: data?['Friends'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (owner != null) "Owner": owner,
      if (status != null) "Password": status,
    };
  }
}
