import 'package:flutter/material.dart';
import 'custom_text.dart';

class CustomButtonSocial extends StatelessWidget {
  final String text;
  final String imageName;
  final void Function()? onPressed;
  const CustomButtonSocial(
      {super.key,
      required this.text,
      required this.imageName,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Colors.grey.shade200),
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)))),
        child: Row(
          children: [
            Image.asset(
              imageName,
              height: 25,
              width: 25,
            ),
            const SizedBox(
              width: 80,
            ),
            CustomText(
              text: text,
            ),
          ],
        ),
      ),
    );
  }
}
