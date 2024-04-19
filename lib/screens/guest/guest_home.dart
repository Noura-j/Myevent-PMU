import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_event/screens/guest/clubs.dart';
import 'package:my_event/screens/guest/register_events.dart';
import 'package:my_event/screens/guest/welcome.dart';
import 'package:velocity_x/velocity_x.dart';

class GuestHome extends StatefulWidget {
  const GuestHome({super.key});

  @override
  State<GuestHome> createState() => _GuestHomeState();
}

class _GuestHomeState extends State<GuestHome> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    Welcome(),
    RegisterEvents(),
    Clubs(),
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
              Get.offAllNamed('/login');
            },
            icon: Icon(Icons.logout, color: Colors.white),
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
            icon: Icon(Icons.people),
            label: 'Clubs',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF042745),
        onTap: _onItemTapped,
      ),
    );
  }
}
