import 'package:bike_lock_app/user.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UnlockPage extends StatefulWidget {
  final User currentUser;
  const UnlockPage({super.key, required this.currentUser});

  @override
  State<UnlockPage> createState() => _UnlockPageState();
}

class _UnlockPageState extends State<UnlockPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            AvailableLockList(
              currentUser: widget.currentUser,
            ),
            MyLock(
              currentUser: widget.currentUser,
            ),
          ],
        ),
      ),
    );
  }
}

class AvailableLockList extends StatefulWidget {
  final User currentUser;
  const AvailableLockList({super.key, required this.currentUser});

  @override
  State<AvailableLockList> createState() => _AvailableLockListState();
}

class _AvailableLockListState extends State<AvailableLockList> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          const Text(
            "Locks",
            style: TextStyle(fontSize: 32),
          ),
          Expanded(
            child: StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection('Locks').snapshots(),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  } else {
                    final locks = snapshot.data.docs;

                    var lockList = [];
                    locks.forEach((lock) {
                      lockList.add(lock.data());
                    });
                    return ListView.builder(
                        itemCount: lockList.length,
                        itemBuilder: ((context, index) {
                          return ListTile(
                            leading: const Icon(Icons.list),
                            title: Text("Lock ${lockList[index]['ID']}"),
                            trailing: lockList[index]['Owner'] == "-"
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.book,
                                      color: Colors.greenAccent,
                                    ),
                                    onPressed: () => {
                                      reserveLock(
                                          widget.currentUser.username ?? "",
                                          index),
                                    },
                                  )
                                : IconButton(
                                    icon: const Icon(
                                      Icons.cancel_presentation_sharp,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => {},
                                  ),
                          );
                        }));
                  }
                }),
          ),
        ],
      ),
    );
  }

  void reserveLock(String username, int lock) async {
    final docLock =
        FirebaseFirestore.instance.collection("Locks").doc("Lock ${lock + 1}");
    await docLock.update({"Owner": username});
  }
}

class UnlockButton extends StatefulWidget {
  final int lockID;
  const UnlockButton({super.key, required this.lockID});

  @override
  State<UnlockButton> createState() => _UnlockButtonState();
}

class _UnlockButtonState extends State<UnlockButton> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('Locks').snapshots(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            } else {
              return ElevatedButton(
                onPressed: () {},
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(const CircleBorder()),
                  padding: MaterialStateProperty.all(const EdgeInsets.all(20)),
                  backgroundColor: MaterialStateProperty.all(Colors.blue),
                  overlayColor:
                      MaterialStateProperty.resolveWith<Color?>((states) {
                    if (states.contains(MaterialState.pressed)) {
                      return Colors.blueGrey;
                    }
                    return null;
                  }),
                ),
                child: const Icon(Icons.lock_open_outlined),
              );
            }
          }),
    );
  }
}

class MyLock extends StatefulWidget {
  final User currentUser;
  const MyLock({super.key, required this.currentUser});

  @override
  State<MyLock> createState() => _MyLockState();
}

class _MyLockState extends State<MyLock> {
  bool userHasLock = true;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('Locks').snapshots(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            } else {
              final locks = snapshot.data.docs;

              var myLock;
              locks.forEach((lock) {
                if (lock['Owner'] == widget.currentUser.username) {
                  myLock = lock;
                }
              });
              if (myLock == null) {
                return const Text("You do not own any lock, reserve one above");
              } else {
                return Column(
                  children: [
                    Text("You own Lock ${myLock['ID']}"),
                    UnlockButton(lockID: int.parse(myLock['ID']))
                  ],
                );
              }
            }
          }),
    );
  }

  Future<void> hasLock(String username) async {
    final helper = FirebaseFirestore.instance.collection("Locks");
    QuerySnapshot querySnapshot = await helper.get();

    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();

    for (var lock in allData) {
      if (getLockOwner(lock.toString()) == username) {
        setState(() {});
      }
    }
  }

  String getLockOwner(String jsonString) {
    String rawData = jsonString.substring(
        jsonString.indexOf('{'), jsonString.lastIndexOf('}'));
    rawData = rawData.substring(rawData.indexOf("Owner"),
        rawData.indexOf(',', rawData.indexOf("Owner")));

    var data = rawData.split(':');
    return (data[1].replaceAll(" ", ""));
  }
}
