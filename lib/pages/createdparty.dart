import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'home.dart';

class CreatedPartyPage extends StatefulWidget {
  final String roomName;

  CreatedPartyPage({required this.roomName});

  @override
  _CreatedPartyPageState createState() => _CreatedPartyPageState();
}

class _CreatedPartyPageState extends State<CreatedPartyPage> {
  late String currentFilmName = '';
  late String currentFilmUrl = '';
  late String currentFilmShort = '';
  List<String> shownFilmIds = [];
  late Timer matchTimer;

  @override
  void initState() {
    super.initState();
    loadNextFilm();

    matchTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      checkMatch();

    });
  }

  @override
  void dispose() {
    matchTimer.cancel(); // При знищенні сторінки відміняємо таймер
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Room Name: ${widget.roomName}',
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontFamily: 'Steppe',
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white70,
        elevation: 4,
      ),
      body: WillPopScope(onWillPop: ()  async {return false;},
        child: Container(
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
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (currentFilmName != null)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15.0),
                              child: Image.network(
                                currentFilmUrl,
                                height: 400,
                                width: 300,
                                fit: BoxFit.fill,
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              '$currentFilmName',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 35,
                                fontFamily: 'Steppe',
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              '$currentFilmShort',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'Steppe',
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.2),
                      ),
                      child: IconButton(
                        //  onDoubleTap: () {}
                        icon: Icon(Icons.check, size: 60),
                        color: Colors.lightGreenAccent,
                        onPressed: () {
                          onLike();
                        },
                      ),
                    ),
                    SizedBox(width: 20),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.2),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.close, size: 60),
                        color: Colors.redAccent,
                        onPressed: () {
                          loadNextFilm();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void loadNextFilm() {
    FirebaseFirestore.instance.collection('films').get().then((
        QuerySnapshot querySnapshot,
        ) {
      List<Map<String, dynamic>> films = [];
      querySnapshot.docs.forEach((DocumentSnapshot doc) {
        Map<String, dynamic> filmData = {
          'id': doc.id,
          'name': doc['name'],
          'url': doc['url'],
          'short': doc['short'],
        };
        films.add(filmData);
      });

      Random random = Random();
      Map<String, dynamic> randomFilm;

      do {
        randomFilm = films[random.nextInt(films.length)];
      } while (shownFilmIds.contains(randomFilm['id']));

      shownFilmIds.add(randomFilm['id']);

      currentFilmName = randomFilm['name'];
      currentFilmUrl = randomFilm['url'];
      currentFilmShort = randomFilm['short'];

      if (shownFilmIds.length == films.length) {
        showAllDialog();
      } else {
        setState(() {});
      }
    });
  }

  void showAllDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Це все'),
          content: Text('Всі фільми виведено.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('rooms')
                    .doc(widget.roomName)
                    .delete();
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Home()),
                );
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void onLike() {
    FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomName)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> doc) {
      if (doc.exists) {
        List<dynamic>? likedFilmsData =
        (doc.data()?['likedFilms'] as List<dynamic>?);

        if (likedFilmsData != null) {
          List<dynamic> likedFilms = likedFilmsData;

          likedFilms.add({
            'name': currentFilmName,
            'url': currentFilmUrl,
            'short': currentFilmShort,
          });

          FirebaseFirestore.instance
              .collection('rooms')
              .doc(widget.roomName)
              .update({
            'likedFilms': likedFilms,
          }).then((value) {
            checkMatch();
            loadNextFilm();
          });
        } else {
          FirebaseFirestore.instance
              .collection('rooms')
              .doc(widget.roomName)
              .set(
            {
              'likedFilms': [
                {
                  'name': currentFilmName,
                  'url': currentFilmUrl,
                  'short': currentFilmShort,
                },
              ],
            },
            SetOptions(merge: true),
          ).then((value) {
            loadNextFilm();
          });
        }
      }
    });
  }

  Future<bool> _checkRoomExists(String roomCode) async {
    DocumentSnapshot roomSnapshot = await FirebaseFirestore.instance.collection('rooms').doc(roomCode).get();
    print(roomSnapshot.exists);
    return roomSnapshot.exists;
  }

  void checkMatch() async {
    bool isRoom = await _checkRoomExists(widget.roomName);
    if(isRoom == false){
      FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.roomName)
          .delete();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
      matchTimer.cancel();
    }else{
    FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomName)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> doc) {
      List<dynamic>? likedFilmsData =
      (doc.data()?['likedFilms'] as List<dynamic>?);

      if (likedFilmsData != null && likedFilmsData.length >= 2) {
        // Перебирайте всі фільми та порівнюйте їхні пари
        for (int i = 0; i < likedFilmsData.length - 1; i++) {
          for (int j = i + 1; j < likedFilmsData.length; j++) {
            String filmName1 = likedFilmsData[i]['name'] as String;
            String filmName2 = likedFilmsData[j]['name'] as String;

            if (filmName1 == filmName2) {
              showMatchDialog(likedFilmsData[i]);
            }
          }
        }
      }
    });}
  }
  void showMatchDialog(Map<String, dynamic> matchedFilm) {
    matchTimer.cancel();

    showDialog(
      useRootNavigator: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: AlertDialog(
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'MATCH!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Image.network(
                  matchedFilm['url'] as String,
                  height: 500,
                  width: 350,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 10),
                Text(
                  matchedFilm['name'] as String,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  loadNextFilm();
                  Navigator.of(context).pop();
                  FirebaseFirestore.instance.collection('rooms')
                      .doc(widget.roomName)
                      .update({
                    'likedFilms': [],
                  });
                },
                child: Text('Далі'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  FirebaseFirestore.instance.collection('rooms').doc(
                      widget.roomName).delete();
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => Home()));
                },
                child: Text('Завершити'),
              ),
            ],
          ),
        );
      },
    );
  }
}
