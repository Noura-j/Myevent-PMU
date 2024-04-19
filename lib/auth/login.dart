import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:velocity_x/velocity_x.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  final _formKey = GlobalKey<FormState>();
  ProgressDialog? _progressDialog;

  void login() {
    if (_formKey.currentState!.validate()) {
      _progressDialog = ProgressDialog(context: context);
      _progressDialog!.show(max: 100, msg: 'Loading...');
      auth
          .signInWithEmailAndPassword(
              email: emailController.text, password: passwordController.text)
          .then((value) {
        users.doc(value.user!.uid).get().then((value) {
          _progressDialog!.close();
          if (value['role'].toString().trim() == 'Admin') {
            Get.offAllNamed('/admin_home');
          } else if (value['role'].toString().trim() == 'club') {
            Get.offAllNamed('/club_home');
          } else {
            Get.offAllNamed('/guest_home');
          }
        });
      }).catchError((error) {
        _progressDialog!.close();
        Get.snackbar('Error', error.toString(),
            snackPosition: SnackPosition.TOP,
            backgroundColor: Vx.hexToColor('#FFA451'));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Vx.hexToColor('#042745'),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
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
                  'Welcome to MyEvent'
                      .text
                      .color(Vx.hexToColor('#FFA451'))
                      .xl4
                      .make()
                      .p8(),
                  20.heightBox,
                  'Login into your account Explore and Plan all your PMU Events!'
                      .text
                      .white
                      .xl
                      .center
                      .make()
                      .p8(),
                  10.heightBox,
                  Container(
                    child: TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                  ).p8(),
                  10.heightBox,
                  Container(
                    child: TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                  ).p8(),
                  10.heightBox,
                  //forgot password?
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Get.offAllNamed('/forgot_password');
                      },
                      child: 'Forgot Password?'.text.white.make().p8(),
                    ),
                  ),
                  10.heightBox,
                  Container(
                    width: context.screenWidth * 0.8,
                    child: ElevatedButton(
                      onPressed: () {
                        login();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Vx.hexToColor('#FFA451'),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: 'Login'.text.white.make(),
                    ),
                  ),
                  10.heightBox,

                  //continue as guest
                  Container(
                    width: context.screenWidth * 0.8,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.offAllNamed('/guest_home');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Vx.hexToColor('#FFA451'),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: 'Continue as Guest'.text.white.make(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
