import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:velocity_x/velocity_x.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  ProgressDialog? _progressDialog;

  void checkUser(){
    _progressDialog = ProgressDialog(context: context);
    _progressDialog!.show(max: 100, msg: 'Loading...');
    final user = auth.currentUser;
    if (user != null) {
      users.doc(user.uid).get().then((value) {
        if (value.exists) {
          Map<String, dynamic>? userData =
          value.data() as Map<String, dynamic>?;
          if (userData != null) {
            if (userData['role'].toString().trim() == 'Admin') {
              _progressDialog!.close();
              Get.offAllNamed('/admin_home');
            } else if (userData['role'].toString().trim() ==
                'club') {
              _progressDialog!.close();
              Get.offAllNamed('/club_home');
            } else {
              _progressDialog!.close();
              Get.offAllNamed('/guest_home');
            }
          } else {
            _progressDialog!.close();
            Get.offAllNamed('/login');
          }
        } else {
          _progressDialog!.close();
          Get.offAllNamed('/login');
        }
      }).catchError((error) {
        _progressDialog!.close();
        Get.offAllNamed('/login');
      });
    } else {
      _progressDialog!.close();
      Get.offAllNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //#042745
      backgroundColor: Vx.hexToColor('#042745'),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage('images/logo.png'),
                    ),
                  ),
                ),
              ),
            ),
            20.heightBox,
            //button att bottom of screen
            Container(
              width: context.screenWidth * 0.8,
              child: ElevatedButton(
                onPressed: () {
                  checkUser();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Vx.hexToColor('#FFA451'),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: 'Start Now'.text.white.make(),
              ),
            ),
            10.heightBox,
          ],
        ),
      ),
    );
  }
}
