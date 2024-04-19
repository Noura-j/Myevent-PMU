import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';

class RejectReason extends StatefulWidget {
  const RejectReason({super.key});

  @override
  State<RejectReason> createState() => _RejectReasonState();
}

class _RejectReasonState extends State<RejectReason> {
  String? reason = '';
  TextEditingController reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? documentId;
  CollectionReference eventRequests =
      FirebaseFirestore.instance.collection('events');

  @override
  void initState() {
    super.initState();
    documentId = Get.arguments['document'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 'Reject Reason'.text.white.make(),
        centerTitle: true,
        backgroundColor: Vx.hexToColor('#042745'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              'Reason for rejection'.text.xl.bold.make(),
              //radio buttons
              ListTile(
                title: 'Overlapping Content'.text.make(),
                leading: Radio(
                  value: 'Overlapping Content',
                  groupValue: reason,
                  onChanged: (String? value) {
                    setState(() {
                      reason = value;
                    });
                  },
                ),
              ),
              ListTile(
                title: 'Incomplete Proposal'.text.make(),
                leading: Radio(
                  value: 'Incomplete Proposal',
                  groupValue: reason,
                  onChanged: (String? value) {
                    setState(() {
                      reason = value;
                    });
                  },
                ),
              ),
              ListTile(
                title: 'Budgetary Constraints'.text.make(),
                leading: Radio(
                  value: 'Budgetary Constraints',
                  groupValue: reason,
                  onChanged: (String? value) {
                    setState(() {
                      reason = value;
                    });
                  },
                ),
              ),
              ListTile(
                title: 'Venue location is too busy'.text.make(),
                leading: Radio(
                  value: 'Venue location is too busy',
                  groupValue: reason,
                  onChanged: (String? value) {
                    setState(() {
                      reason = value;
                    });
                  },
                ),
              ),
              ListTile(
                title: 'Other'.text.make(),
                leading: Radio(
                  value: 'Other',
                  groupValue: reason,
                  onChanged: (String? value) {
                    setState(() {
                      reason = value;
                    });
                  },
                ),
              ),
              //text field
              reason == 'Other'
                  ? TextFormField(
                      maxLines: 3,
                      controller: reasonController,
                      decoration: InputDecoration(
                        hintText: 'Enter reason',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a reason';
                        }
                        return null;
                      },
                    ).p8()
                  : SizedBox(),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    eventRequests
                        .doc(documentId)
                        .update({'status': 'rejected', 'reason': reason}).then(
                      (value) {
                        Get.snackbar('Success', 'Event rejected successfully',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Vx.hexToColor('#FFA451'));
                        Get.offAllNamed('/admin_home');
                      },
                    ).catchError((error) {
                      Get.snackbar('Error', error.toString(),
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Vx.hexToColor('#FFA451'));
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Vx.hexToColor('#FFA451'),
                  ),
                  child: 'Submit'.text.white.make(),
                ),
              ).p8(),
            ],
          ).p8(),
        ),
      ),
    );
  }
}
