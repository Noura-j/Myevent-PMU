import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';
class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();


  void resetPassword(){
    if (_formKey.currentState!.validate()) {
      auth.sendPasswordResetEmail(email: emailController.text).then((value) {
        Get.snackbar('Success', 'Password reset link sent to your email',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Vx.hexToColor('#FFA451'));
      }).catchError((error) {
        Get.snackbar('Error', error.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Vx.hexToColor('#042745'),
      body: SafeArea(
        child: Form(
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
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
                    'Forgot Password'.text.color(Vx.hexToColor('#FFA451')).xl4.make().p8(),
                    20.heightBox,
                    'Enter your email address to reset your password'
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
                          if (value!.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                    ).p8(),
                    10.heightBox,
                    Container(
                      width: context.screenWidth * 0.8,
                      child: ElevatedButton(
                        onPressed: () {
                          resetPassword();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Vx.hexToColor('#FFA451'),
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: 'Reset Password'.text.white.make(),
                      ),
                    ),
                    10.heightBox,
                    Container(
                      width: context.screenWidth * 0.8,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.offAllNamed('/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Vx.hexToColor('#FFA451'),
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: 'Back to Login'.text.white.make(),
                      ),
                    ),
                    10.heightBox,
                  ],
                ),
              ),
            ),
          ),
        )
      ),
    );
  }
}
