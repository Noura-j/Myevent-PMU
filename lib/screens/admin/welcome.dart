import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';

class Welcome extends StatefulWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  CollectionReference eventRequests = FirebaseFirestore.instance.collection('events');
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
            username = userData['username'];
            profilePic = userData['profile'];
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 100,
                height: 100,
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
              const SizedBox(width: 20),
              const Text('Welcome, '),
              if (username != null)
                Expanded(child: Text(username!))
              else
                CircularProgressIndicator().centered(),
            ],
          ),
          const SizedBox(height: 20),
          'Requested Events'.text.xl2.start.make().p8(),
          StreamBuilder<QuerySnapshot>(
            stream: eventRequests.where('status', isEqualTo: 'pending').snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView(
                shrinkWrap: true,
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text(data['eventTitle']),
                    subtitle: Text(data['activityType']),
                    //image as circular leading
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(data['poster']),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Get.toNamed('/event_details', arguments: {
                          'data': data,
                          'document': document.id,
                        });
                      },
                      child: const Text('Check'),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ).p8(),
    );
  }
}
