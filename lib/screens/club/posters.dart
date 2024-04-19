import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:velocity_x/velocity_x.dart';

class Posters extends StatefulWidget {
  const Posters({super.key});

  @override
  State<Posters> createState() => _PostersState();
}

class _PostersState extends State<Posters> {
  TextEditingController _locationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _posterImage;
  ProgressDialog? _progressDialog;
  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference posters =
      FirebaseFirestore.instance.collection('posters');

  Future<void> _getImage() async {
    final XFile? image =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _posterImage = image != null ? File(image.path) : null;
    });
  }

  Future<String> uploadImage() async {
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('posters/${DateTime.now().millisecondsSinceEpoch}');
    UploadTask uploadTask = ref.putFile(_posterImage!);
    await uploadTask.whenComplete(() => null);
    return await ref.getDownloadURL();
  }

  void requestPostPosters() async {
    _progressDialog = ProgressDialog(context: context);
    _progressDialog!.show(max: 100, msg: 'Loading...');
    String imageUrl = await uploadImage();
    //check if the posters collection exists in the database then update otherwise add new
    posters.doc(auth.currentUser!.uid).get().then((value) {
      if (value.exists) {
        posters.doc(auth.currentUser!.uid).update({
          'location': _locationController.text,
          'poster': imageUrl,
          'timestamp': DateTime.now(),
        }).then((value) {
          _progressDialog!.close();
          Get.snackbar('Success'.tr, 'Poster uploaded successfully'.tr,
              snackPosition: SnackPosition.TOP,
              backgroundColor: Vx.hexToColor('#FFA451'));
        }).catchError((error) {
          _progressDialog!.close();
          Get.snackbar('Error'.tr, error.toString(),
              snackPosition: SnackPosition.TOP,
              backgroundColor: Vx.hexToColor('#FFA451'));
        });
      } else {
        posters.doc(auth.currentUser!.uid).set({
          'location': _locationController.text,
          'poster': imageUrl,
          'timestamp': DateTime.now(),
        }).then((value) {
          _progressDialog!.close();
          Get.snackbar('Success'.tr, 'Poster uploaded successfully'.tr,
              snackPosition: SnackPosition.TOP,
              backgroundColor: Vx.hexToColor('#FFA451'));
        }).catchError((error) {
          _progressDialog!.close();
          Get.snackbar('Error'.tr, error.toString(),
              snackPosition: SnackPosition.TOP,
              backgroundColor: Vx.hexToColor('#FFA451'));
        });
      }
    }).catchError((error) {
      _progressDialog!.close();
      Get.snackbar('Error'.tr, error.toString(),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Vx.hexToColor('#FFA451'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 'Posters'.text.white.make(),
        centerTitle: true,
        backgroundColor: Vx.hexToColor('#042745'),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Image.asset('images/rocket.png'),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        'For Promoting your event'.text.bold.xl.make(),
                        'Please Include the poster Image & Location'
                            .text
                            .center
                            .make(),
                      ],
                    ),
                  )
                ],
              ).p12(),
              Divider(
                color: Vx.hexToColor('#FFA451'),
              ),
              'Poster File'.text.xl.make(),
              SizedBox(
                width: double.infinity,
                height: 200,
                child: _posterImage == null
                    ? ElevatedButton(
                        onPressed: () {
                          //pick image of the poster
                          _getImage();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Vx.hexToColor('#F37022'),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.upload_circle,
                                color: Color(0xFF042745),
                                size: 80,
                              ).centered().p8(),
                              'Upload Poster'.text.white.make(),
                            ],
                          ),
                        ),
                      )
                    : Image.file(_posterImage!),
              ).p8(),
              'Location'.text.xl.make(),
              Container(
                width: double.infinity,
                height: 200,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Vx.hexToColor('#F37022'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        CupertinoIcons.location_solid,
                        color: Color(0xFF042745),
                        size: 60,
                      ).p4().marginOnly(top: 20),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          labelText: 'Write down your location',
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your location';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ).p8(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_posterImage == null) {
                        Get.snackbar(
                            'Error'.tr, 'Please select a poster image'.tr,
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Vx.hexToColor('#FFA451'));
                      } else {
                        requestPostPosters();
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Vx.hexToColor('#F37022'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
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
