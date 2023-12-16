import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../view_model/auth_view_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text.dart';
import '../widgets/custom_text_form_field.dart';
import 'login_view.dart';

class RegisterView extends GetWidget<AuthViewModel> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  RegisterView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
        appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back),onPressed: (){Navigator.pop(context);},),),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(top: 100),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 30, right: 20, left: 20, bottom: 60),
                  child: Column(
                    children: [
                      const CustomText(text: 'Sign Up,', fontSize: 30),
                      const SizedBox(
                        height: 40,
                      ),
                      CustomTextFormField(
                          text: 'Name',
                          hint: 'Pesa',
                          onSave: (value) {
                            controller.name = value!;
                          },
                          validator: (String? value) {
                            if (value!.isEmpty) {
                              return 'you must write your name';
                            }
                            return null;
                          }),
                      const SizedBox(
                        height: 40,
                      ),
                      CustomTextFormField(
                        text: 'Email',
                        hint: 'iamdavid@gmail.com',
                        onSave: (value) {
                          controller.email = value!;
                        },
                        validator: (String? value) {
                          if (value!.isEmpty) {
                            return 'you must write your email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      CustomTextFormField(
                        text: 'Password',
                        hint: '*********',
                        onSave: (value) {
                          controller.password = value!;
                        },
                        validator: (String? value) {
                          if (value!.isEmpty) {
                            return 'you must write password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const SizedBox(
                        height: 70,
                      ),
                      CustomButton(
                        text: 'SIGN UP',
                        onPressed: () {
                          _formKey.currentState!.save();
                          if (_formKey.currentState!.validate()) {
                            controller.createAccountWithEmailAndPassword(context);
                          }
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}