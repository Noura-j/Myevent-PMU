import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:my_event/widgets/upcoming_events.dart';
import 'package:velocity_x/velocity_x.dart';

class Welcome extends StatefulWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  late TextEditingController _searchController;

  CollectionReference events = FirebaseFirestore.instance.collection('events');

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          'Search'.text.xl2.make(),
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {}); // Trigger rebuild to reflect search changes
            },
            decoration: InputDecoration(
              labelText: 'Search',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ).p8(),
          'Upcoming Events'.text.xl2.make(),
          StreamBuilder<QuerySnapshot>(
            stream: events.snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return 'Something went wrong'.text.make();
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator().centered();
              }

              final filteredEvents = snapshot.data!.docs.where((document) {
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                final searchQuery = _searchController.text.toLowerCase();
                final eventTitle = data['eventTitle'].toString().toLowerCase();
                return data['status'] == 'approved' &&
                    eventTitle.contains(searchQuery);
              }).toList();

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: filteredEvents.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    print(data['poster']);
                    return InkWell(
                      onTap: () {
                        Get.toNamed('/add_students', arguments: {
                          'document': document.id,
                        });
                      },
                      child: SizedBox(
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                data['poster'],
                                key: ValueKey(data['poster']), // Use the poster URL or a unique identifier
                                height: 300,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 180,
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.black.withOpacity(0.5),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    data['eventTitle']
                                        .toString()
                                        .text
                                        .wrapWords(true)
                                        .white
                                        .make(),
                                    Text(
                                      'Location: ${data['selectedVenue']}\n'
                                      'Date: ${data['dateRange'].toString().split(',')[0]}\n'
                                      'Start Time: ${data['eventStartTime']}',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ).p8(),
                              ),
                            ),
                          ],
                        ).p4(),
                      ),
                    );
                  }).toList(),
                ).p8(),
              );
            },
          ),
          'Your Activities'.text.xl2.make(),
          UpcomingEvents(),
        ],
      ).p8(),
    );
  }
}
