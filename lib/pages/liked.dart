import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/pages/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LikedMovies(),
    );
  }
}

class LikedMovies extends StatefulWidget {
  const LikedMovies({Key? key}) : super(key: key);

  @override
  _LikedMoviesState createState() => _LikedMoviesState();
}

class _LikedMoviesState extends State<LikedMovies> {
  late List<String> _likedFilmNames;

  @override
  void initState() {
    super.initState();
    _likedFilmNames = [];
    _loadLikedFilmNamesFromLocalStorage();
  }
  void _toggleLikeStatus(String filmName) {
    setState(() {
      if (_likedFilmNames.contains(filmName)) {
        _likedFilmNames.remove(filmName);
      } else {
        _likedFilmNames.add(filmName);
      }
      _saveLikedFilmsToLocalStorage();
    });
  }

  void _saveLikedFilmsToLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('likedFilmNames', _likedFilmNames);
  }
  void _loadLikedFilmNamesFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> likedFilmNames = prefs.getStringList('likedFilmNames') ?? [];
    setState(() {
      _likedFilmNames = likedFilmNames;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
          },
        ),
        title: Text('Liked Movies', style: TextStyle(color: Colors.black, fontSize: 25, fontFamily: 'Steppe')),
        centerTitle: true,
        backgroundColor: Colors.white70,
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: _likedFilmNames.length,
              itemBuilder: (context, index) {
                return LikedFilmCard(
                  filmName: _likedFilmNames[index],
                  loadLikedFilmNames: _toggleLikeStatus,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LikedFilmCard extends StatelessWidget {
  final String filmName;
  final Function loadLikedFilmNames;

  LikedFilmCard({
    required this.filmName,
    required this.loadLikedFilmNames,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadFilmDataFromFirebase(filmName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Помилка завантаження даних');
        } else {
          Map<String, dynamic> filmData = snapshot.data as Map<String, dynamic>;

          // Отримання URL-адреси постера
          String posterUrl = filmData['url'] ?? '';

          return Card(
            margin: EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(posterUrl, height: 500, width: double.infinity, fit: BoxFit.cover),
                  SizedBox(height: 8),
                  Text(
                    '${filmData['name']}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Рік: ${filmData['year']}',
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Короткий опис: ${filmData['short']}',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.favorite),
                        color: Colors.red,
                        onPressed: () {
                          loadLikedFilmNames(filmName);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Future<Map<String, dynamic>> _loadFilmDataFromFirebase(String filmName) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('films')
        .where('name', isEqualTo: filmName)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.data() as Map<String, dynamic>;
    } else {
      return {};
    }
  }

  void _deleteLikedFilm(String filmName) {
    loadLikedFilmNames();
  }
}
