import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:my_app/pages/control_view.dart';
import 'package:my_app/pages/home.dart';
import 'package:my_app/pages/liked.dart';
import 'package:my_app/pages/party.dart';
import 'package:my_app/pages/start.dart';
import 'package:my_app/pages/listmode.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/view_model/auth_view_model.dart';
import 'package:my_app/view_model/control_view_model.dart';

import 'helper/local_storage_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Get.put(LocalStorageData());
  Get.put(ControlViewModel());
  Get.put(AuthViewModel());
  runApp(const MyApp());
  // ignore: deprecated_member_use

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.white70,
          useMaterial3: true,
        ),
        home: ControlView(),
      )
        ;
  }
}


