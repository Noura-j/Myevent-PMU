import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:velocity_x/velocity_x.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File? _image;
  ProgressDialog? _progressDialog;
  TextEditingController _clubNameController = TextEditingController();
  TextEditingController _collegeController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _foundingDateController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  FirebaseStorage storage = FirebaseStorage.instance;


  Future<void> _getImage() async {
    final XFile? image =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image != null ? File(image.path) : null;
    });
  }

  Future<String> uploadImage() async {
    Reference ref = storage.ref().child('profile/${auth.currentUser!.uid}');
    UploadTask uploadTask = ref.putFile(_image!);
    await uploadTask.whenComplete(() => null);
    return await ref.getDownloadURL();
  }

  void getDetails(){
    users.doc(auth.currentUser!.uid).get().then((value) {
      if (value.exists) {
        Map<String, dynamic>? userData = value.data() as Map<String, dynamic>?;
        if (userData != null) {
          setState(() {
            _clubNameController.text = userData['club_name'];
            _collegeController.text = userData['college'];
            _descriptionController.text = userData['description'];
            _foundingDateController.text = userData['founding_date'];
          });
        } else {
          print('User data is null');
        }
      } else {
        print('User document does not exist');
      }
    }).catchError((error) {
      print('Error fetching user details: $error');
    });
  }

  @override
  void initState() {
    super.initState();
    getDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 'Profile'.text.white.make(),
        centerTitle: true,
        backgroundColor: Vx.hexToColor('#042745'),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _getImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      backgroundImage:
                          _image != null ? FileImage(_image!) : null,
                      child: _image == null
                          ? Icon(Icons.camera_alt, size: 40)
                          : null,
                    ),
                  ),
                ),
                'Change Profile Picture'.text.make().p8(),
                20.widthBox,
                TextFormField(
                  controller: _clubNameController,
                  decoration: InputDecoration(
                    labelText: 'Club Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Club name cannot be empty';
                    }
                    return null;
                  },
                ).p8(),
                TextFormField(
                  controller: _collegeController,
                  decoration: InputDecoration(
                    labelText: 'College',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'College name cannot be empty';
                    }
                    return null;
                  },
                ).p8(),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Description cannot be empty';
                    }
                    return null;
                  },
                ).p8(),
                TextFormField(
                  controller: _foundingDateController,
                  decoration: InputDecoration(
                    labelText: 'Founding Date',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Founding date cannot be empty';
                    }
                    return null;
                  },
                ).p8(),
                Container(
                  width: context.screenWidth * 0.8,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Vx.hexToColor('#FFA451'),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _progressDialog = ProgressDialog(context: context);
                        _progressDialog!.show(
                          max: 100,
                          msg: 'Updating profile...',
                        );
                        String url = '';
                        if (_image != null) {
                          url = await uploadImage();
                        }
                        users.doc(auth.currentUser!.uid).set({
                          'email': auth.currentUser!.email,
                          'club_name': _clubNameController.text,
                          'college': _collegeController.text,
                          'description': _descriptionController.text,
                          'founding_date': _foundingDateController.text,
                          'profile': url,
                          'role' : 'club',
                        }).then((value) {
                          _progressDialog!.close();
                          Get.snackbar('Success', 'Profile updated successfully',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Vx.hexToColor('#42BA96'));
                        }).catchError((error) {
                          _progressDialog!.close();
                          Get.snackbar('Error', 'Failed to update profile',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Vx.hexToColor('#FFA451'));
                        });
                      }
                    },
                    child: 'Update Profile'.text.white.make(),
                  ).p8(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
