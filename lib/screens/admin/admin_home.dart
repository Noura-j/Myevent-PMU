import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_event/model/LoggedInUser.dart';
import 'package:my_event/screens/admin/profile.dart';
import 'package:my_event/screens/admin/welcome.dart';
import 'package:velocity_x/velocity_x.dart';
class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  String? username;

  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    Welcome(),
    Profile(),
    Text('Profile Page'),
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
        title: 'Home'.text.white.make(),
        centerTitle: true,
        backgroundColor: Vx.hexToColor('#042745'),
        actions: [
          IconButton(
            onPressed: () {
              auth.signOut().then((value) {
                Get.offAllNamed('/login');
              });
            },
            icon: Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body:
         _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF042745),
        onTap: _onItemTapped,
      ),
    );
  }
}
