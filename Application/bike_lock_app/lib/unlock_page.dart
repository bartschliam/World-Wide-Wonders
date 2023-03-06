import 'package:bike_lock_app/lock.dart';
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

                    bool currentUserOwnsLockAlready = false;
                    for (var lock in lockList) {
                      if (lock['Owner'] == widget.currentUser.username) {
                        currentUserOwnsLockAlready = true;
                      }
                    }

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
                                      if (!currentUserOwnsLockAlready)
                                        {
                                          reserveLock(
                                              widget.currentUser.username ?? "",
                                              index),
                                        }
                                    },
                                  )
                                : IconButton(
                                    icon: const Icon(
                                      Icons.cancel_presentation_sharp,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => {
                                      unReserveLock(
                                          widget.currentUser.username ?? "",
                                          index)
                                    },
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
        FirebaseFirestore.instance.collection("Locks").doc("Lock_$lock");
    await docLock.update({"Owner": username});
  }

  void unReserveLock(String username, int lockID) async {
    final docLock =
        FirebaseFirestore.instance.collection("Locks").doc("Lock_$lockID");

    final ref = FirebaseFirestore.instance
        .collection("Locks")
        .doc("Lock_$lockID")
        .withConverter(
          fromFirestore: Lock.fromFirestore,
          toFirestore: (Lock lock, _) => lock.toFirestore(),
        );

    final docSnap = await ref.get();
    final lock = docSnap.data();

    if (lock?.owner == username) {
      await docLock.update({"Owner": "-"});
    }
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
              Map<String, dynamic> lockData =
                  snapshot.data.docs[widget.lockID].data();

              return ElevatedButton(
                onPressed: () {
                  changeLockState(widget.lockID);
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(const CircleBorder()),
                  padding: MaterialStateProperty.all(const EdgeInsets.all(20)),
                  backgroundColor: MaterialStateProperty.all(
                      lockData['Locked'] == true ? Colors.blue : Colors.red),
                ),
                child: lockData['Locked'] == true
                    ? const Icon(Icons.lock_outline)
                    : const Icon(Icons.lock_open_outlined),
              );
            }
          }),
    );
  }

  void changeLockState(int lockID) async {
    final docLock =
        FirebaseFirestore.instance.collection("Locks").doc("Lock_$lockID");

    final ref = FirebaseFirestore.instance
        .collection("Locks")
        .doc("Lock_$lockID")
        .withConverter(
          fromFirestore: Lock.fromFirestore,
          toFirestore: (Lock lock, _) => lock.toFirestore(),
        );

    final docSnap = await ref.get();
    final lock = docSnap.data();

    bool newState;

    if (lock?.locked == true) {
      newState = false;
    } else {
      newState = true;
    }

    debugPrint(newState.toString());

    await docLock.update({"Locked": newState});
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
              bool isSecondOwner = false;
              var myLock;
              locks.forEach((lock) {
                if (lock['Owner'] == widget.currentUser.username) {
                  myLock = lock;
                }
                if (lock['SecondOwner'] == widget.currentUser.username) {
                  isSecondOwner = true;
                  myLock = lock;
                }
              });
              if (myLock == null) {
                return const Text("You do not own any lock, reserve one above");
              } else {
                String displayText = isSecondOwner
                    ? "You are the second owner of Lock ${myLock['ID']}"
                    : "You own Lock ${myLock['ID']}";

                return Column(
                  children: [
                    Text(displayText),
                    UnlockButton(lockID: int.parse(myLock['ID']))
                  ],
                );
              }
            }
          }),
    );
  }
}
