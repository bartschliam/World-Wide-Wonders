import 'dart:async';
import 'dart:convert';
import 'package:bike_lock_app/user.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendPage extends StatefulWidget {
  final User currentUser;
  const FriendPage({super.key, required this.currentUser});

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  final friendController = TextEditingController();
  bool showDialog = false;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    friendController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User displayUser = widget.currentUser;
    bool currentUserHasLock = false;

    return Scaffold(
      body: showDialog
          ? Dialog(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: TextField(
                      controller: friendController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Username',
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showDialog = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: const Text("Cancel"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showDialog = false;
                              requestUser(friendController.text,
                                  displayUser.username ?? "");
                              friendController.clear();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent),
                          child: const Text("Request"),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          : Center(
              child: Column(
                children: [
                  Text(
                    displayUser.username ?? "",
                    style: const TextStyle(fontSize: 48),
                  ),
                  const Text(
                    "Friends",
                    style: TextStyle(fontSize: 24),
                  ),
                  Expanded(
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('Users')
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<dynamic> snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        } else {
                          final data = snapshot.data.docs;
                          int userIndex = data.indexWhere((element) =>
                              displayUser.username ==
                              element.data()['Credentials']['username']);

                          Map<String, dynamic> userData =
                              snapshot.data.docs[userIndex].data();
                          var friendsList =
                              parse(userData['Friends']['friends'].toString());

                          if (friendsList.isNotEmpty) {
                            return ListView.builder(
                              itemCount: friendsList.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                    leading: const Icon(Icons.list),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.arrow_circle_up,
                                        color: Colors.greenAccent,
                                      ),
                                      onPressed: () => {
                                        addSecondUser(
                                            widget.currentUser.username ?? "",
                                            friendsList[index])
                                      },
                                    ),
                                    title: Text(friendsList[index] ?? ""));
                              },
                            );
                          } else {
                            return const Text("NO FRIENDS");
                          }
                        }
                      },
                    ),
                  ),
                  const Text(
                    "Requests",
                    style: TextStyle(fontSize: 24),
                  ),
                  Expanded(
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("Users")
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<dynamic> snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        } else {
                          final data = snapshot.data.docs;
                          int userIndex = data.indexWhere((element) =>
                              displayUser.username ==
                              element.data()['Credentials']['username']);

                          Map<String, dynamic> userData =
                              snapshot.data.docs[userIndex].data();

                          var requests = parse(
                              userData['Friends']['request_in'].toString());

                          if (requests.isNotEmpty) {
                            return ListView.builder(
                              itemCount: requests.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                    leading: const Icon(Icons.list),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.person_add,
                                        color: Colors.greenAccent,
                                      ),
                                      onPressed: () async => {
                                        await addUser(requests[index],
                                            displayUser.username ?? ""),
                                        await addUser(
                                            displayUser.username ?? "",
                                            requests[index]),
                                        removeRequest(requests[index],
                                            displayUser.username ?? "")
                                      },
                                    ),
                                    title: Text(requests[index]));
                              },
                            );
                          } else {
                            return const Text("No Requests!");
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            showDialog = true;
          });
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }

  void addSecondUser(String currentUser, String friendUsername) async {
    if (await hasLock(currentUser) && !await hasLock(friendUsername)) {
      final helper = FirebaseFirestore.instance.collection("Locks");
      QuerySnapshot querySnapshot = await helper.get();

      final allData = querySnapshot.docs.map((doc) => doc.data()).toList();

      var ownedLock;
      for (var lock in allData) {
        if (getLockOwner(lock.toString()) == currentUser) {
          ownedLock = lock;
        }
      }
      final docLock = FirebaseFirestore.instance
          .collection("Locks")
          .doc("Lock_${ownedLock!['ID'].toString()}");
      await docLock.update({"SecondOwner": friendUsername});
    }
  }

  Future<bool> hasLock(String username) async {
    final helper = FirebaseFirestore.instance.collection("Locks");
    QuerySnapshot querySnapshot = await helper.get();

    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();

    for (var lock in allData) {
      if (getLockOwner(lock.toString()) == username) {
        return true;
      }
    }
    return false;
  }

  String getLockOwner(String jsonString) {
    String rawData = jsonString.substring(
        jsonString.indexOf('{'), jsonString.lastIndexOf('}'));
    rawData = rawData.substring(rawData.indexOf("Owner"),
        rawData.indexOf(',', rawData.indexOf("Owner")));

    var data = rawData.split(':');
    return (data[1].replaceAll(" ", ""));
  }

  Future<void> requestUser(String username, String currentUser) async {
    if (await checkUserExists(username)) {
      final docUser =
          FirebaseFirestore.instance.collection("Users").doc(username);

      final ref = FirebaseFirestore.instance
          .collection("Users")
          .doc(username)
          .withConverter(
            fromFirestore: User.fromFirestore,
            toFirestore: (User user, _) => user.toFirestore(),
          );

      final docSnap = await ref.get();
      final user = docSnap.data();

      int ID = user?.friends!['friends'].length + 1;

      final userData = {
        "Friends": {
          "request_in": {'$ID': currentUser},
        }
      };

      await docUser.set(userData, SetOptions(merge: true));
    }
  }

  Future<bool> checkUserExists(String username) async {
    final ref = FirebaseFirestore.instance
        .collection("Users")
        .doc(username)
        .withConverter(
          fromFirestore: User.fromFirestore,
          toFirestore: (User user, _) => user.toFirestore(),
        );

    final docSnap = await ref.get();
    final user = docSnap.data();

    return user != null;
  }

  List parse(String jsonString) {
    String check = jsonString.substring(
        jsonString.indexOf('{') + 1, jsonString.indexOf('}'));
    if (!check.contains(':')) {
      return [];
    } else {
      var data = check.split(',');
      var dataToReturn = [];
      for (String entry in data) {
        dataToReturn.add(entry.split(':')[1].replaceAll(" ", ""));
      }
      return dataToReturn;
    }
  }

  Future<void> addUser(String userToAdd, String currentUser) async {
    final docUser =
        FirebaseFirestore.instance.collection("Users").doc(currentUser);
    debugPrint(currentUser);
    final ref = FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser)
        .withConverter(
          fromFirestore: User.fromFirestore,
          toFirestore: (User user, _) => user.toFirestore(),
        );

    final docSnap = await ref.get();
    final user = docSnap.data();

    int ID = user?.friends!['friends'].length + 1;

    final userData = {
      "Friends": {
        "friends": {'$ID': userToAdd},
      }
    };

    await docUser.set(userData, SetOptions(merge: true));
  }

  void removeRequest(String userToRemove, String currentUser) async {
    final docUser =
        FirebaseFirestore.instance.collection("Users").doc(currentUser);

    final ref = FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser)
        .withConverter(
          fromFirestore: User.fromFirestore,
          toFirestore: (User user, _) => user.toFirestore(),
        );

    final docSnap = await ref.get();
    final user = docSnap.data();

    var requests = user?.friends!['request_in'];

    String req = requests.toString();

    String check = req.substring(req.indexOf('{') + 1, req.indexOf('}'));

    var data = check.split(',');
    var dataToReturn = {};

    for (String entry in data) {
      String ID = entry.split(':')[0].replaceAll(' ', '');
      String user = entry.split(':')[1].replaceAll(' ', '');
      if (user != userToRemove) {
        dataToReturn[ID] = user;
      }
    }

    final friends = user?.friends!['friends'];
    final reqOut = user?.friends!['request_out'];

    final newInfo = {
      "Friends": {
        "friends": friends,
        "request_in": dataToReturn,
        "request_out": reqOut
      }
    };

    debugPrint("$currentUser info: ${newInfo.toString()}");

    await docUser.update(newInfo);
  }
}
