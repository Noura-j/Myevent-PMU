import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';

class EventDetails extends StatefulWidget {
  const EventDetails({super.key});

  @override
  State<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  Map<String, dynamic>? data;
  String? documentId;
  CollectionReference eventRequests =
      FirebaseFirestore.instance.collection('events');
  late ConfettiController _controllerCenter;

  @override
  void initState() {
    super.initState();
    data = Get.arguments['data'];
    documentId = Get.arguments['document'];
    _controllerCenter =
        ConfettiController(duration: const Duration(seconds: 3));
  }

  Path drawStar(Size size) {
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 'Event Details'.text.white.make(),
        centerTitle: true,
        backgroundColor: Vx.hexToColor('#042745'),
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: data == null
            ? CircularProgressIndicator().centered()
            : Stack(children: [
                Align(
                  alignment: Alignment.center,
                  child: ConfettiWidget(
                    confettiController: _controllerCenter,
                    blastDirectionality: BlastDirectionality
                        .explosive, // don't specify a direction, blast randomly
                    colors: const [
                      Colors.green,
                      Colors.blue,
                      Colors.pink,
                      Colors.orange,
                      Colors.purple
                    ], // manually specify the colors to be used
                    createParticlePath: drawStar, // define a custom shape/path.
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      data!['poster'],
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    'Event Name: ${data!['eventTitle']}'.text.bold.make().p12(),
                    'Event Date: ${data!['dateRange']}'.text.make().p12(),
                    'Event Start Time: ${data!['eventStartTime']}'
                        .text
                        .make()
                        .p12(),
                    'Event End Time: ${data!['eventEndTime']}'
                        .text
                        .make()
                        .p12(),
                    'Event Location: ${data!['selectedVenue']}'
                        .text
                        .make()
                        .p12(),
                    'Event Description'.text.bold.make().p12(),
                    '${data!['activityDescription']}'.text.make().p12(),
                    Divider(
                      color: Vx.hexToColor('#FFA451'),
                    ),
                    'Number of Participants:'.text.bold.make().p12(),
                    '${data!['numberOfParticipants']}'.text.make().p12(),
                    'Gender of participants'.text.bold.make().p12(),
                    '${data!['eventParticipants']}'.text.make().p12(),
                    'Person in-charge of the event'.text.bold.make().p12(),
                    '${data!['personInCharge']}: ${data!['inChargeFullName']}'
                        .text
                        .make()
                        .p12(),
                    'Contact Number'.text.bold.make().p12(),
                    '${data!['inChargeContactNumber']}'.text.make().p12(),
                    'Pmu ID'.text.bold.make().p12(),
                    '${data!['inChargePmuId']}'.text.make().p12(),
                    Row(
                      children: [
                        //accept button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              eventRequests
                                  .doc(documentId)
                                  .update({'status': 'approved'}).then((value) {
                                Get.snackbar(
                                    'Success', 'Event approved successfully',
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor: Vx.hexToColor('#FFA451'));
                                _controllerCenter.play();
                              }).catchError((error) {
                                Get.snackbar('Error', error.toString(),
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor: Vx.hexToColor('#FFA451'));
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: 'Accept'.text.white.make(),
                          ).p12(),
                        ),
                        //reject button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              eventRequests
                                  .doc(documentId)
                                  .update({'status': 'rejected'}).then((value) {
                                Get.offAllNamed('/reject_reason', arguments: {
                                  'document': documentId,
                                });
                              }).catchError((error) {
                                Get.snackbar('Error', error.toString(),
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor: Vx.hexToColor('#FFA451'));
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: 'Reject'.text.white.make(),
                          ).p12(),
                        ),
                      ],
                    ),
                  ],
                ),
              ]),
      ),
    );
  }
}
