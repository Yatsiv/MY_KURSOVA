import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/constance.dart';
import 'package:my_app/pages/login_view.dart';
import 'package:my_app/view_model/profile_view_model.dart';
import 'package:my_app/widgets/custom_text.dart';
import 'package:my_app/pages/listmode.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _isAdmin = false;
  @override
  void initState() {
    _checkAdminStatus();
    ProfileViewModel().getCurrentUser();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileViewModel>(
      init: ProfileViewModel(),
      builder: (controller) => controller.loading.value
          ? const Center(child: CircularProgressIndicator())
          : Scaffold(
        appBar: AppBar(),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(image: DecorationImage(image: AssetImage(
            'img/background.jpg',
          ),fit: BoxFit.fill)),
          padding: const EdgeInsets.only(
            top: 0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius:
                        const BorderRadius.all(Radius.circular(100)),
                        image: DecorationImage(
                            image: NetworkImage(
                                controller.userModel!.pic.toString()),
                            fit: BoxFit.fill),
                      )),SizedBox(height: 20,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _isAdmin ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomText(
                            alignment: Alignment.center,
                            text: 'admin',
                            color: Colors.redAccent,
                            fontSize: 18,
                          ),Icon(Icons.star, color: Colors.redAccent,)
                        ],
                      ):SizedBox(),
                      CustomText(
                        alignment: Alignment.center,
                        text: controller.userModel!.name.toString(),
                        color: Colors.black,
                        fontSize: 25,
                      ),
                      CustomText(
                        alignment: Alignment.center,
                        text: controller.userModel!.email.toString(),
                        color: Colors.black,
                        fontSize: 20,
                      )
                    ],
                  )
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              GestureDetector(
                  onTap: () {
                    controller.signOut();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginView()));
                  },
                  child:
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Image.asset(
                      'img/log_out.png',
                      height: 25,
                      width: 25,
                    ),
                      SizedBox(width: 20,),
                      CustomText(
                        alignment: Alignment.center,
                        text: 'Log Out',
                      ),
                    ],)
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _checkAdminStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot adminSnapshot =
      await FirebaseFirestore.instance.collection('admins').doc('admins').get();
      if (adminSnapshot.exists && adminSnapshot['email'] == user.email) {
        setState(() {
          _isAdmin = true;
        });
      }
    }
  }
}