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

    var friends = displayUser.friends!['friends'];
    var requests = displayUser.friends!['request_in'];

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
                              requestUser(
                                  friendController.text,
                                  displayUser.username ?? "",
                                  requests.length + 1);
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
          : Column(
              children: [
                Text(
                  displayUser.username ?? "",
                  style: const TextStyle(fontSize: 48),
                ),
                Text(
                  "Friends: ${friends.toString()}",
                  style: const TextStyle(fontSize: 24),
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: friends.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                            leading: const Icon(Icons.list),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Color.fromARGB(255, 235, 94, 84),
                              ),
                              onPressed: () => _removeItem(friends, index),
                            ),
                            title: Text(friends?['${index + 1}'] ?? ""));
                      }),
                ),
                const Text(
                  "Requests",
                  style: TextStyle(fontSize: 24),
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: requests.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                            leading: const Icon(Icons.list),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Color.fromARGB(255, 235, 94, 84),
                              ),
                              onPressed: () => _removeItem(friends, index),
                            ),
                            title: Text(requests?['${index + 1}'] ?? ""));
                      }),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        setState(() {
          showDialog = true;
        });
      }),
    );
  }

  void _removeItem(List items, int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  Future<void> requestUser(String username, String currentUser, int ID) async {
    if (await checkUserExists(username)) {
      final docUser =
          FirebaseFirestore.instance.collection("Users").doc(username);

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
}
