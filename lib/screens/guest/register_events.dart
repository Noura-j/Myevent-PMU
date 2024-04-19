import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';

class RegisterEvents extends StatefulWidget {
  const RegisterEvents({super.key});

  @override
  State<RegisterEvents> createState() => _RegisterEventsState();
}

class _RegisterEventsState extends State<RegisterEvents> {
  CollectionReference events = FirebaseFirestore.instance.collection('events');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: StreamBuilder<QuerySnapshot>(
            stream: events.snapshots(),
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
                  return data['status'] == 'approved'
                      ? SizedBox(
                          child: Container(
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
                                  subtitle:
                                      '${data['dateRange'].toString().split(',')[0]}\n${data['eventStartTime']}'
                                          .text
                                          .white
                                          .make(),
                                  trailing: IconButton(
                                    icon: Icon(Icons.add),
                                    color: Colors.white,
                                    onPressed: () {
                                      Get.toNamed('/add_students', arguments: {
                                        'document': document.id,
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).p8()
                      : SizedBox();
                }).toList(),
              );
            },
          ),
        ),
      ),
    );
  }
}
