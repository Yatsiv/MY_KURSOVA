import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class ListMode extends StatefulWidget {
  const ListMode({Key? key}) : super(key: key);

  @override
  _ListModeState createState() => _ListModeState();
}

class _ListModeState extends State<ListMode> {
  bool _isAdmin = false;

  @override
  void initState() {
    _loadFilmsFromFirebase();
    _checkAdminStatus();
    super.initState();
  }

  int _selectedIndex = 0;
  late String _newfilm_name = 'a';
  int _newfilm_year = 0;
  late String _newfilm_url;
  late String _newfilm_short;

  List<Map<String, dynamic>> _films = [];
  List<String> _likedFilmNames = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'MovieSS',
          style: TextStyle(color: Colors.black, fontSize: 25, fontFamily: 'Steppe'),
        ),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: _films.length,
              itemBuilder: (context, index) {
                return FilmCard(
                  name: _films[index]['name'],
                  year: _films[index]['year'],
                  url: _films[index]['url'],
                  short: _films[index]['short'],
                  isLiked: _likedFilmNames.contains(_films[index]['name']),
                  onLike: () {
                    _toggleLikeStatus(_films[index]['name']);
                  },
                  onDelete: () {
                    _deleteFilm(_films[index]['name']);
                  },
                  isAdmin: _isAdmin,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_isAdmin)
            FloatingActionButton(
              heroTag: 'btn2',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Додати фільм'),
                      content: Column(
                        children: [
                          TextField(
                            onChanged: (String value) {
                              _newfilm_name = value;
                            },
                            decoration: InputDecoration(labelText: 'Назва фільму'),
                          ),
                          TextField(
                            onChanged: (String value) {
                              _newfilm_year = int.parse(value);
                            },
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(labelText: 'Рік випуску'),
                          ),
                          TextField(
                            onChanged: (String value) {
                              _newfilm_url = value;
                            },
                            decoration: InputDecoration(labelText: 'URL постера'),
                          ),
                          TextField(
                            onChanged: (String value) {
                              _newfilm_short = value;
                            },
                            decoration: InputDecoration(labelText: 'Короткий опис'),
                          ),
                        ],
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            FirebaseFirestore.instance.collection('films').add({
                              'name': _newfilm_name,
                              'year': _newfilm_year,
                              'url': _newfilm_url,
                              'short': _newfilm_short,
                            });
                            Navigator.of(context).pop();
                          },
                          child: Text('Додати'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Icon(Icons.add),
              backgroundColor: Colors.lightGreenAccent,
            ),
          SizedBox(height: 16),
          if (_isAdmin)
            FloatingActionButton(
              heroTag: 'btn1',
              onPressed: () {
                _loadFilmsFromFirebase();
              },
              child: Icon(Icons.refresh),
              backgroundColor: Colors.blue,
            ),
        ],
      ),
    );
  }

  void _loadFilmsFromFirebase() {
    FirebaseFirestore.instance.collection('films').get().then((QuerySnapshot querySnapshot) {
      _films.clear();
      querySnapshot.docs.forEach((DocumentSnapshot doc) {
        Map<String, dynamic> filmData = {
          'name': doc['name'],
          'year': doc['year'],
          'url': doc['url'],
          'short': doc['short'],
        };
        _films.add(filmData);
      });
      setState(() {});
    });
    _loadLikedFilmsFromLocalStorage();
  }

  void _loadLikedFilmsFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> likedFilmNames = prefs.getStringList('likedFilmNames') ?? [];
    setState(() {
      _likedFilmNames = likedFilmNames;
    });
  }

  void _saveLikedFilmsToLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('likedFilmNames', _likedFilmNames);
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp()));
        break;
      default:
        break;
    }
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

  void _deleteFilm(String filmName) {
    FirebaseFirestore.instance
        .collection('films')
        .where('name', isEqualTo: filmName)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
        _deleteFilmFromLiked(filmName);
      });
      _loadFilmsFromFirebase();
    });
  }

  void _deleteFilmFromLiked(String filmName) {
    setState(() {
      if (_likedFilmNames.contains(filmName)) {
        _likedFilmNames.remove(filmName);
        _saveLikedFilmsToLocalStorage();
      }
    });
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

class FilmCard extends StatelessWidget {
  final String name;
  final int year;
  final String url;
  final String short;
  final bool isLiked;
  final VoidCallback onLike;
  final VoidCallback onDelete;
  final bool isAdmin;

  FilmCard({
    required this.name,
    required this.year,
    required this.url,
    required this.short,
    required this.isLiked,
    required this.onLike,
    required this.onDelete,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(url, height: 500, width: double.infinity, fit: BoxFit.fill),
            SizedBox(height: 8),
            Text(
              '$name',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Рік: $year',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              'Короткий опис: $short',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
                  color: isLiked ? Colors.red : null,
                  onPressed: onLike,
                ),
                if (isAdmin)
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: onDelete,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
