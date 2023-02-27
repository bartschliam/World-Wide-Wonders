import 'package:bike_lock_app/friend_page.dart';
import 'package:bike_lock_app/lock_map.dart';
import 'package:bike_lock_app/unlock_page.dart';
import 'package:bike_lock_app/user.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final User currentUser;
  const HomePage({super.key, required this.currentUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      FriendPage(currentUser: widget.currentUser),
      UnlockPage(currentUser: widget.currentUser),
      const LockMap(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT Bike Lock Application'),
      ),
      body: widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box_rounded),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lock_open_rounded),
            label: 'Unlock',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_pin),
            label: 'Map',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
      ),
    );
  }
}
