import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

import 'createdparty.dart';

class PartyPage extends StatelessWidget {
  PartyPage() {
    // Ініціалізація Firebase
    WidgetsFlutterBinding.ensureInitialized();
    FirebaseFirestore.instance.settings = Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Party Page',
          style: TextStyle(color: Colors.black, fontSize: 25, fontFamily: 'Steppe'),
        ),
        centerTitle: true,
        backgroundColor: Colors.white70,
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('img/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  String roomName = createRandomRoom();
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CreatedPartyPage(roomName: roomName)));
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.lightGreenAccent,
                  onPrimary: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                ),
                child: Text(
                  'Створити кімнату',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _showJoinRoomDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  onPrimary: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                ),
                child: Text(
                  'Доєднатись до кімнати',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String createRandomRoom() {
    // Генеруємо випадкову назву кімнати (4 символи)
    String roomName = generateRandomRoomName();

    // Додаємо запис у колекцію "rooms" з додатковими полями
    FirebaseFirestore.instance.collection('rooms').doc(roomName).set({
      'name': roomName,
      'IsMatched': 0,  // Початкове значення для IsMatched
      'MatchedFilm': '',  // Початкове значення для MatchedFilm

      // Додайте інші дані кімнати, які вам потрібні
    }).then((value) {
      print('Кімната створена з назвою: $roomName');
      // Додайте дії, які повинні відбутися після створення кімнати
    });

    return roomName;
  }

  String generateRandomRoomName() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    Random random = Random();
    String result = '';

    for (int i = 0; i < 5; i++) {
      result += chars[random.nextInt(chars.length)];
    }

    return result;
  }

  Future<void> _showJoinRoomDialog(BuildContext context) async {
    TextEditingController codeController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Введіть код кімнати:'),
          content: TextField(
            controller: codeController,
            decoration: InputDecoration(
              hintText: 'Код кімнати',
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                String roomCode = codeController.text.trim();

                // Перевірка чи існує кімната з введеним кодом
                bool roomExists = await _checkRoomExists(roomCode);

                if (roomExists) {
                  Navigator.pop(context); // Закриваємо діалогове вікно

                  // Перехід на сторінку з кімнатою
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreatedPartyPage(roomName: roomCode),
                    ),
                  );
                } else {
                  // Виведення повідомлення про помилку
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Кімната з кодом $roomCode не знайдена.'),
                    ),
                  );
                }
              },
              child: Text('Доєднатись'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _checkRoomExists(String roomCode) async {
    // Перевірка чи існує кімната з введеним кодом
    DocumentSnapshot roomSnapshot = await FirebaseFirestore.instance.collection('rooms').doc(roomCode).get();

    return roomSnapshot.exists;
  }
}
