import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';

class Tracking extends StatefulWidget {
  const Tracking({super.key});

  @override
  State<Tracking> createState() => _TrackingState();
}

class _TrackingState extends State<Tracking> {
  CollectionReference eventRequests =
      FirebaseFirestore.instance.collection('events');
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  FirebaseAuth auth = FirebaseAuth.instance;
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
    return SafeArea(
      child: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: eventRequests.snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return 'Something went wrong'.text.make();
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator().centered();
            }

            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                return data['event_id'] == auth.currentUser!.uid && data['status'] == 'approved'
                    ? Container(
                        height: 100,
                        child: Column(
                          children: [
                            ListTile(
                              tileColor: Vx.hexToColor('#042745'),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              leading: Icon(Icons.event, color: Colors.white),
                              title: data['eventTitle']
                                  .toString()
                                  .text
                                  .white
                                  .make(),
                              subtitle: TextButton(
                                onPressed: () {
                                  Get.toNamed('/attendance', arguments: {
                                    'document': document.id,
                                  });
                                },
                                child: 'Track Students'.text.white.make(),
                              ).p4(),
                            ),
                          ],
                        ),
                      )
                    : Container();
              }).toList(),
            ).p8();
          },
        ),
      ),
    );
  }
}
