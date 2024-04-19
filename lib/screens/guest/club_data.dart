import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';

class ClubData extends StatefulWidget {
  const ClubData({super.key});

  @override
  State<ClubData> createState() => _ClubDataState();
}

class _ClubDataState extends State<ClubData> {
  Map<String, dynamic>? passedData;
  String? documentId;
  CollectionReference events = FirebaseFirestore.instance.collection('events');

  @override
  void initState() {
    super.initState();
    passedData = Get.arguments['data'];
    documentId = Get.arguments['document'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: '${passedData!['club_name']}'.text.white.make(),
        centerTitle: true,
        backgroundColor: Vx.hexToColor('#042745'),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //cover image check if the profile image is null or not
            passedData!['profile'] != null && passedData!['profile'] != ''
                ? Image.network(
                    passedData!['profile'],
                    fit: BoxFit.cover,
                    height: 200,
                    width: double.infinity,
                  )
                : Image.network(
                    'https://www.woolha.com/media/2020/03/eevee.png',
                    fit: BoxFit.cover,
                    height: 200,
                  ).centered(),
            'About this club'.text.xl2.bold.make().p8(),
            'College: ${passedData!['college']}'.text.make().p8(),
            'Founded In: ${passedData!['founding_date']}'.text.make().p8(),
            'Description'.text.xl2.bold.make().p8(),
            '${passedData!['description']}'.text.make().p8(),
            'Upcoming events'.text.xl2.bold.make().p8(),
            StreamBuilder<QuerySnapshot>(
              stream: events.snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return 'Something went wrong'.text.make();
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator().centered();
                }
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;

                      return data['event_id'] == documentId &&
                              data['status'] == 'approved'
                          ? SizedBox(
                              child: Stack(
                                // Position elements accordingly
                                children: [
                                  // Image
                                  ClipRRect(
                                    // Rounded image corners
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.network(
                                      data['poster'],
                                      height: 300,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  // Text content (positioned over image)
                                  Positioned(
                                    top: 180,
                                    child: Container(
                                      width: 223,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.black.withOpacity(0.5),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          data['eventTitle']
                                              .toString()
                                              .text
                                              .wrapWords(true)
                                              .white
                                              .make(),
                                          const SizedBox(height: 5), // Spacing
                                          Text(
                                            'Location: ${data['selectedVenue']}\n'
                                            'Date: ${data['dateRange'].toString().split(',')[0]}\n'
                                            'Start Time: ${data['eventStartTime']}',
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ],
                                      ).p8(),
                                    ),
                                  ),
                                ],
                              ).p4(),
                            )
                          : SizedBox();
                    }).toList(),
                  ).p8(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
