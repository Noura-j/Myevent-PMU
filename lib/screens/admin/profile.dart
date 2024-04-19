import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:velocity_x/velocity_x.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File? _image;
  ProgressDialog? _progressDialog;
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
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

  void updateDetails() async {
    _progressDialog = ProgressDialog(context: context);
    _progressDialog!.show(max: 100, msg: 'Loading...');
    String imageUrl = await uploadImage();
    users.doc(auth.currentUser!.uid).update({
      'email': _emailController.text,
      'username': _usernameController.text,
      'phone': _phoneController.text,
      'profile': imageUrl,
      'role': 'Admin',
    }).then((value) {
      _progressDialog!.close();
      Get.snackbar('Success'.tr, 'Profile updated successfully'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Vx.hexToColor('#FFA451'));
    }).catchError((error) {
      _progressDialog!.close();
      Get.snackbar('Error'.tr, error.toString(),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Vx.hexToColor('#FFA451'));
    });
  }

  void getDetails() {
    users.doc(auth.currentUser!.uid).get().then((value) {
      if (value.exists) {
        Map<String, dynamic>? userData = value.data() as Map<String, dynamic>?;
        if (userData != null) {
          setState(() {
            _usernameController.text = userData['username'];
            _emailController.text = userData['email'];
            _phoneController.text = userData['phone'];
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
    return Center(
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
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child:
                      _image == null ? Icon(Icons.camera_alt, size: 40) : null,
                ),
              ),
            ),
            'Change profile picture'.tr.text.make(),
            20.widthBox,
            //username
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username'.tr,
                hintText: 'Enter your username'.tr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ).p8(),
            //email
            TextFormField(
              controller: _emailController,
              readOnly: true,
              onTap: () {
                Get.snackbar('Error'.tr, 'Email cannot be changed'.tr,
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Vx.hexToColor('#FFA451'));
              },
              decoration: InputDecoration(
                labelText: 'Email'.tr,
                hintText: 'Enter your email'.tr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ).p8(),
            //phone
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone'.tr,
                hintText: 'Enter your phone number'.tr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ).p8(),
            //update
            Container(
              width: context.screenWidth * 0.8,
              child: ElevatedButton(
                onPressed: () {
                  updateDetails();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Vx.hexToColor('#FFA451'),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: 'Update'.text.white.make(),
              ).p8(),
            ),
          ],
        ).p8(),
      )),
    );
  }
}
