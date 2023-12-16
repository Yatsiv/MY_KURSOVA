import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_app/helper/local_storage_data.dart';
import 'package:my_app/model/user_model.dart';

class ProfileViewModel extends GetxController {
  ValueNotifier<bool> get loading => _loadaing;
  final ValueNotifier<bool> _loadaing = ValueNotifier(false);

  final LocalStorageData localStorageData = Get.find();

  UserModel? get userModel => _userModel;
  UserModel? _userModel;

  @override
  void onInit() {
    super.onInit();
    getCurrentUser();
  }

  void getCurrentUser() async {
    _loadaing.value = true;
    await localStorageData.getUser.then((value) {
      _userModel = value;
    });
    _loadaing.value = false;

    update();
  }

  Future<void> signOut() async {
    GoogleSignIn().signOut();
    FirebaseAuth.instance.signOut();
    localStorageData.deleteUser();
  }
}
