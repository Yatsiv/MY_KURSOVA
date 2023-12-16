import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/constance.dart';
import 'custom_text.dart';

// ignore: must_be_immutable
class CustomButtonCategory extends StatelessWidget {
  late dynamic page;
  late String categoryName;
  late String image;

  CustomButtonCategory(
      {super.key,
      required this.page,
      required this.categoryName,
      required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        onTap: () {
          Get.to(page);
        },
        child: Column(
          children: [
            Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.grey.shade100),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    'assets/category_icons/$image.png',
                    color: Colors.black87,
                  ),
                )),
            const SizedBox(
              height: 10,
            ),
            CustomText(text: categoryName, fontSize: 15),
          ],
        ),
      ),
    );
  }
}
