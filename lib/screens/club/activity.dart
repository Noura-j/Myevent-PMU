import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';

class Activity extends StatefulWidget {
  const Activity({super.key});

  @override
  State<Activity> createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  CollectionReference eventRequests =
      FirebaseFirestore.instance.collection('events');
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: StreamBuilder<QuerySnapshot>(
      stream: eventRequests.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return 'Something went wrong'.text.make();
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator().centered();
        }

        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            return data['event_id'] == auth.currentUser!.uid
                ? ListTile(
                    tileColor: Vx.hexToColor('#042745'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    leading: Icon(Icons.event, color: Colors.white),
                    title: data['eventTitle'].toString().text.white.make(),
                    subtitle: data['status'] == 'rejected'
                        ? Text(
                            'Status: ${data['status']}\n'
                            'Reason: ${data['reason']}',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Status: ${data['status']}',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                    trailing: data['status'] == 'approved'
                        ? TextButton(
                            onPressed: () {
                              Get.toNamed('/add_students', arguments: {
                                'document': document.id,
                              });
                            },
                            child: 'Add Students'.text.white.make(),
                          )
                        : null,
                  ).p8()
                : Container();
          }).toList(),
        );
      },
    ));
  }
}
