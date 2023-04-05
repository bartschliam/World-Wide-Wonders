import 'package:cloud_firestore/cloud_firestore.dart';

class Lock {
  final String? owner;
  final bool? locked;
  final String? ID;
  Map<String, dynamic>? coords;

  Lock({
    this.owner,
    this.ID,
    this.coords,
    this.locked,
  });

  factory Lock.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Lock(
      owner: data?['Owner'],
      coords: data?['Coords'],
      ID: data?['ID'],
      locked: data?['Locked'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (owner != null) "Owner": owner,
      if (ID != null) "ID": ID,
      if (coords != null) "Coords": coords,
      if (locked != null) "Locked": locked,
    };
  }
}
