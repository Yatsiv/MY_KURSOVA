import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_app/helper/local_storage_data.dart';
import 'package:my_app/model/user_model.dart';
import '../../constance.dart';
import '../../pages/control_view.dart';
import '../pages/home.dart';
import '../services/firestore_user.dart';

class AuthViewModel extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //FacebookLogin _facebookLogin = FacebookLogin();

  late String email, password, name;
  final Rxn<User> _user = Rxn<User>();
  User? get user => _user.value;
  final LocalStorageData localStorageData = Get.find();

  @override
  void onInit() {
    super.onInit();
    _user.bindStream(_auth.authStateChanges());
    if (_auth.currentUser != null) {
      getCurrentUserData(_auth.currentUser!.uid);
    }
  }

  void signInWithGoogle(context) async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth =
    await googleUser?.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth!.accessToken, idToken: googleAuth.idToken);

    await _auth.signInWithCredential(credential).then((user) {
      saveUser(user);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
    });
  }


  void signInWithEmailAndPassword(context) async {
    try {
      await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) async {
        getCurrentUserData(value.user!.uid);
      });
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
    } catch (e) {
      Get.snackbar('Error', 'wrong email or password',
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(top: 7, left: 15, right: 15));
    }
  }

  void createAccountWithEmailAndPassword(context) async {
    try {
      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((user) async {
        saveUser(user);
      });

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
    } catch (e) {
      Get.snackbar('Error', 'account not created',
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(top: 7, left: 15, right: 15));
    }
  }

  void saveUser(UserCredential user) async {
    UserModel userModel = UserModel(
        userId: user.user!.uid,
        email: user.user!.email,
        name: user.user!.displayName ?? name,
        pic: user.user!.photoURL ?? profileImage);
    await FireStoreUser().addUserToFireStore(userModel);
    setUser(userModel);
  }

  void getCurrentUserData(String uid) async {
    await FireStoreUser().getCurrentUser(uid).then((value) {
      setUser(UserModel.fromJson(value.data() as Map<String, dynamic>));
    });
  }

  void setUser(UserModel userModel) async {
    await localStorageData.setUser(userModel);
  }
}