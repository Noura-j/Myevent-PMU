import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_event/screens/club/activity.dart';
import 'package:my_event/screens/club/tracking.dart';
import 'package:my_event/screens/club/welcome.dart';
import 'package:velocity_x/velocity_x.dart';

class ClubHome extends StatefulWidget {
  const ClubHome({super.key});

  @override
  State<ClubHome> createState() => _ClubHomeState();
}

class _ClubHomeState extends State<ClubHome> {
  int _selectedIndex = 0;
  FirebaseAuth auth = FirebaseAuth.instance;

  static const List<Widget> _widgetOptions = <Widget>[
    Welcome(),
    Activity(),
    Tracking(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 'Club Home'.text.white.make(),
        centerTitle: true,
        backgroundColor: Vx.hexToColor('#042745'),
        automaticallyImplyLeading: true,
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.menu, color: Colors.white),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: TextButton(
                  onPressed: () {
                      Get.toNamed('/profile');
                  },
                  child: Text('Profile'),
                ),
              ),
              PopupMenuItem(
                child: TextButton(
                  onPressed: () {
                    auth.signOut().then((value) {
                      Get.offAllNamed('/login');
                    });
                  },
                  child: Text('Logout'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.watch_later_outlined),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.spatial_tracking_rounded),
            label: 'Tracking',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF042745),
        onTap: _onItemTapped,
      ),
    );
  }
}
