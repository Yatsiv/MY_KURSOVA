import 'package:flutter/material.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        title: Text('MovieSS', style: TextStyle(color: Colors.black, fontSize: 25, fontFamily: 'Steppe')),
        centerTitle: true,
        backgroundColor: Colors.white70,
        elevation: 4,
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'img/background.jpg',
              fit: BoxFit.fill,
            ),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Всім привіт',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 45,
                    fontFamily: 'Steppe',
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.2), // Тінь для тексту
                        offset: Offset(0, 5),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/my_app');
                  },
                  child: Text(
                    'Let`s start',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontFamily: 'Steppe',
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(170, 135),
                    shadowColor: Colors.black.withOpacity(0.5), // Тінь для кнопки
                    elevation: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
