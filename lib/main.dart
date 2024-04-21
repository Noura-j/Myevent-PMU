import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_event/auth/splash_screen.dart';
import 'package:my_event/firebase_options.dart';
import 'package:my_event/screens/admin/admin_home.dart';
import 'package:my_event/screens/admin/reject_reason.dart';
import 'package:my_event/screens/club/add_students.dart';
import 'package:my_event/screens/club/attendance.dart';
import 'package:my_event/screens/club/club_home.dart';
import 'package:my_event/screens/club/create_event.dart';
import 'package:my_event/screens/club/posters.dart';
import 'package:my_event/screens/admin/event_details.dart';
import 'package:my_event/screens/club/profile.dart';
import 'package:my_event/screens/guest/club_data.dart';
import 'package:my_event/screens/guest/guest_home.dart';
import 'package:my_event/screens/guest/register_events.dart';

import 'auth/forgot_password.dart';
import 'auth/login.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Material App',
      debugShowCheckedModeBanner: false,
      getPages: [
        GetPage(
          name: '/splash_screen',
          page: () => const SplashScreen(),
        ),
        GetPage(
          name: '/login',
          page: () => const Login(),
        ),
        GetPage(
          name: '/forgot_password',
          page: () => const ForgotPassword(),
        ),
        GetPage(
          name: '/admin_home',
          page: () => const AdminHome(),
        ),
        GetPage(
          name: '/club_home',
          page: () => const ClubHome(),
        ),
        GetPage(
          name: '/guest_home',
          page: () => const GuestHome(),
        ),
        GetPage(
          name: '/posters',
          page: () => const Posters(),
        ),
        GetPage(
          name: '/create_event',
          page: () => const CreateEvent(),
        ),
        GetPage(
          name: '/event_details',
          page: () => const EventDetails(),
        ),
        GetPage(
          name: '/reject_reason',
          page: () => const RejectReason(),
        ),
        //GetPage(
          //name: '/add_students',
          //page: () => const AddStudents(),
        //),
        GetPage(
          name: '/attendance',
          page: () => const Attendance(),),
        GetPage(
          name: '/profile',
          page: () => const Profile(),),
        GetPage(
          name: '/club_data',
          page: () => const ClubData(),),
        GetPage(
          name: '/register_events',
          page: () => const RegisterEvents(),
        ),
      ],
      home: SplashScreen(),
    );
  }
}
