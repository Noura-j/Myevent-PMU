import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:velocity_x/velocity_x.dart';

class AddStudents extends StatefulWidget {
  const AddStudents({super.key});

  @override
  State<AddStudents> createState() => _AddStudentsState();
}

class _AddStudentsState extends State<AddStudents> {
  TextEditingController nameController = TextEditingController();
  TextEditingController pmuController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  String? selectedVenue;
  final _majors = [
    'Software Engineering',
    'Computer Science',
    'Electrical Engineering',
    'Business Administration',
    'Graphic Design',
    'Architecture',
    'Finance',
    'Law',
    'Cyber Security',
    'Information System Technology',
    'Others'
  ];
  final _formKey = GlobalKey<FormState>();
  String? documentId;
  CollectionReference eventRequests =
      FirebaseFirestore.instance.collection('event_students');
  ProgressDialog? _progressDialog;

  @override
  void initState() {
    super.initState();
    documentId = Get.arguments['document'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 'Add Students'.text.white.make(),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Vx.hexToColor('#042745'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              'Add Students'.text.xl2.bold.make(),
              'Add students to the event'.text.make(),
              //name
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter name';
                  }
                  return null;
                },
              ).p8(),
              //pmu
              TextFormField(
                controller: pmuController,
                decoration: InputDecoration(
                  labelText: 'PMU',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter PMU';
                  }
                  return null;
                },
              ).p8(),
              //email
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter email';
                  }
                  return null;
                },
              ).p8(),

              DropdownButtonFormField(
                value: selectedVenue,
                items: _majors
                    .map(
                      (venue) => DropdownMenuItem(
                        value: venue,
                        child: venue.text.make(),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedVenue = value.toString();
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Select major',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Please select the Major';
                  }
                  return null;
                },
              ).p8(),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      Vx.hexToColor('#042745'),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _progressDialog = ProgressDialog(context: context);
                      _progressDialog!.show(max: 100, msg: 'Adding student');
                      //add students against document id
                      eventRequests.add({
                        'name': nameController.text,
                        'pmu': pmuController.text,
                        'email': emailController.text,
                        'major': selectedVenue,
                        'eventId': documentId,
                      }).then((value) {
                        _progressDialog!.close();
                        Get.snackbar('Success', 'Student added successfully',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.green);
                      }).catchError((error) {
                        _progressDialog!.close();
                        Get.snackbar('Error', error.toString(),
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Vx.hexToColor('#FFA451'));
                      });
                    }
                  },
                  child: 'Submit'.text.white.make(),
                ).p8(),
              ),
            ],
          ).p8(),
        ),
      ),
    );
  }
}
