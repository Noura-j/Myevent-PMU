import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';
class UpcomingEvents extends StatefulWidget {
  const UpcomingEvents({super.key});

  @override
  State<UpcomingEvents> createState() => _UpcomingEventsState();
}

class _UpcomingEventsState extends State<UpcomingEvents> {
  CollectionReference events = FirebaseFirestore.instance.collection('events');
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        width: double.infinity,
        height: 200,
        child: StreamBuilder<QuerySnapshot>(
          stream: events.snapshots(),
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return 'Something went wrong'.text.make();
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator().centered();
            }

            final events = snapshot.data!.docs
                .where((document) {
              Map<String, dynamic> data =
              document.data() as Map<String, dynamic>;
              return data['status'] == 'approved';
            })
                .take(2)
                .toList();

            return ListView(
              children: events.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                document.data() as Map<String, dynamic>;
                return SizedBox(
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
                ).p8();
              }).toList(),
            );
          },
        ),
      ),
      Container(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () {
            Get.toNamed('/register_events');
          },
          child: 'View All'.text.make(),
        ),
      ).p8(),
    ]);
  }
}
