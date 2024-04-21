import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  String? username;
  String? profilePic;

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  void getUserDetails() {
    users.doc(auth.currentUser!.uid).get().then((value) {
      if (value.exists) {
        Map<String, dynamic>? userData = value.data() as Map<String, dynamic>?;

        if (userData != null) {
          setState(() {
            username = userData['club_name'];
            if (userData['profile'] == '' || userData['profile'] == null) {
              profilePic =
              'https://www.pngkey.com/png/full/114-1149878_setting-user-avatar-in-specific-size-without-breaking.png';
            } else {
              profilePic = userData['profile'];
            }
          });
        } else {
          print('User data is null');
        }
      } else {
        print('User document does not exist');
      }
    }).catchError((error) {
      print('Error fetching user details: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (username != null)
                  Expanded(child: 'Hi! ${username!}'.text.xl3.make().p8())
                else
                  CircularProgressIndicator().centered(),
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: profilePic != null
                          ? NetworkImage(profilePic!)
                          : NetworkImage(
                        'https://www.pngkey.com/png/full/114-1149878_setting-user-avatar-in-specific-size-without-breaking.png',
                      ),
                    ),
                  ),
                ),
              ],
            ).p8(),
            'Create new Event Track your Requests and more with MyEvent'
                .text
                .xl
                .wrapWords(true)
                .make()
                .p8(),
            'Events Creation'.text.xl2.bold.make().p8(),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage('images/event.png'),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Create your whole event through few steps ONLY!',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Get.toNamed('/create_event');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Vx.hexToColor('#FFA451'),
                          ),
                          child: Text(
                            'New Event',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).p12(),
          ],
        ),
      ),
    );
  }
}