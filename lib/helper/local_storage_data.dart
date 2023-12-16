import 'dart:convert';
import 'package:get/get.dart';
import 'package:my_app/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constance.dart';

class LocalStorageData extends GetxController {
  Future<UserModel?> get getUser async {
    try {
      UserModel userModel = await _getUserData();

      return userModel;
    } catch (e) {
      return null;
    }
  }

  _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var value = prefs.getString(cachedUserData);
    return UserModel.fromJson(json.decode(value.toString()));
  }

  setUser(UserModel userModel) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString(cachedUserData, json.encode(userModel.toJson()));
  }

  void deleteUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
