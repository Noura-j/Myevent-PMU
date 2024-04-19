import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';

class Attendance extends StatefulWidget {
  const Attendance({super.key});

  @override
  State<Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference attendees =
      FirebaseFirestore.instance.collection('event_students');
  String? eventID;

  @override
  void initState() {
    super.initState();
    eventID = Get.arguments['document'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: 'Attendance'.text.white.make(),
          centerTitle: true,
          backgroundColor: Vx.hexToColor('#042745'),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: attendees.snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return 'Something went wrong'.text.make();
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return 'Loading'.text.make();
            }

            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                return data['eventId'] == eventID
                    ? ListTile(
                        tileColor: Vx.hexToColor('#042745'),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        leading: Icon(Icons.person, color: Colors.white),
                        title: data['name'].toString().text.white.make(),
                        subtitle: Text(
                          'PMU: ${data['pmu']}',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        //add two icon button in trailing to mark present of abset
                        trailing: data['status'] == 'present'
                            ? Icon(Icons.check, color: Colors.green)
                            : data['status'] == 'absent'
                                ? Icon(Icons.close, color: Colors.red)
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          attendees.doc(document.id).update({
                                            'status': 'present',
                                          });
                                        },
                                        icon: Icon(Icons.check,
                                            color: Colors.green),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          attendees.doc(document.id).update({
                                            'status': 'absent',
                                          });
                                        },
                                        icon: Icon(Icons.close,
                                            color: Colors.red),
                                      ),
                                    ],
                                  ),
                      ).p4()
                    : SizedBox();
              }).toList(),
            ).p8();
          },
        ));
  }
}
