import 'dart:math';

import 'package:bike_lock_app/lock.dart';
import 'package:bike_lock_app/user.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';

class UnlockPage extends StatefulWidget {
  final User currentUser;
  const UnlockPage({super.key, required this.currentUser});

  @override
  State<UnlockPage> createState() => _UnlockPageState();
}

class _UnlockPageState extends State<UnlockPage> {
  Location location = new Location();

  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;
  bool showOutsideProximityMessage = false;

  Widget availableLockList() {
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

  Widget unlockButton(int lockID, double lockLong, double lockLat) {
    return Expanded(
      child: Column(
        children: [
          StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('Locks').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                } else {
                  Map<String, dynamic> lockData =
                      snapshot.data.docs[lockID].data();

                  return ElevatedButton(
                    onPressed: () async {
                      _serviceEnabled = await location.serviceEnabled();
                      if (!_serviceEnabled) {
                        _serviceEnabled = await location.requestService();
                        if (!_serviceEnabled) {
                          return;
                        }
                      }

                      _permissionGranted = await location.hasPermission();
                      if (_permissionGranted == PermissionStatus.denied) {
                        _permissionGranted = await location.requestPermission();
                        if (_permissionGranted != PermissionStatus.granted) {
                          return;
                        }
                      }
                      _locationData = await location.getLocation();
                      if (withinProximity(
                          lockLong.toDouble(),
                          lockLat.toDouble(),
                          _locationData.longitude ?? 0,
                          _locationData.latitude ?? 0)) {
                        changeLockState(lockID);
                        setState(() {
                          showOutsideProximityMessage = false;
                        });
                      } else {
                        setState(() {
                          showOutsideProximityMessage = true;
                        });
                      }
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(const CircleBorder()),
                      padding:
                          MaterialStateProperty.all(const EdgeInsets.all(20)),
                      backgroundColor: MaterialStateProperty.all(
                          lockData['Locked'] == true
                              ? Colors.blue
                              : Colors.red),
                    ),
                    child: lockData['Locked'] == true
                        ? const Icon(Icons.lock_outline)
                        : const Icon(Icons.lock_open_outlined),
                  );
                }
              }),
          Text(
            showOutsideProximityMessage
                ? "Unable to lock as you are outside proxomity"
                : "",
            style: const TextStyle(color: Colors.red),
          )
        ],
      ),
    );
  }

  Widget myLock() {
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
                    unlockButton(
                        int.parse(myLock['ID']),
                        myLock['Coords']['Long'].toDouble(),
                        myLock['Coords']['Lat'].toDouble())
                  ],
                );
              }
            }
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [availableLockList(), myLock()],
        ),
      ),
    );
  }
}

bool withinProximity(
    double lockLong, double lockLat, double userLong, double userLat) {
  return sqrt(pow((userLong - lockLong), 2) + pow((userLat - lockLat), 2)) < 10;
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

  await docLock.update({"Locked": newState});
}
