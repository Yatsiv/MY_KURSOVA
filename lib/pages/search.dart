import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _searchQuery = '';
  late TextEditingController controller;
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    controller = TextEditingController();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search',
          style: TextStyle(color: Colors.black, fontSize: 25, fontFamily: 'Steppe'),
        ),
        centerTitle: true,
        backgroundColor: Colors.white70,
        elevation: 4,
      ),
      body: Stack(
        children: [
          Image.asset(
            'img/background.jpg', // Замініть 'img/background.jpg' на ваш шлях до зображення
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  onChanged: (value) {
                  _searchResults.clear();
                  // setState(() {
                  //   _searchQuery = controller.text;
                  //   _performSearch();
                  // });
                  },
                  onEditingComplete: () {
                    if(controller.text != '' && controller.text != _searchQuery ){
                    setState(() {
                      _searchQuery = controller.text;
                      _performSearch();
                    });
                  }},
                  controller: controller,
                  decoration: InputDecoration(
                    suffix: IconButton(icon: Icon(Icons.search), onPressed: () {
                      if(controller.text !=''&& controller.text != _searchQuery ){
                      setState(() {
                      _searchQuery = controller.text;
                      _performSearch();
                  });
                  }}),
                    labelText: 'Пошук за ім\'ям, роком або коротким описом',
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: _buildSearchResults(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Text('Немає результатів пошуку'),
      );
    } else {
      return ListView.builder(
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          return FilmCard(
            name: _searchResults[index]['name'],
            year: _searchResults[index]['year'],
            url: _searchResults[index]['url'],
            short: _searchResults[index]['short'],
          );
        },
      );
    }
  }

  void _performSearch() {
    // Виконання пошуку в базі даних Firestore
    FirebaseFirestore.instance.collection('films').get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((DocumentSnapshot doc) {
        // Перевірка, чи задовольняє документ умовам пошуку
        if (_matchesSearchQuery(doc)) {
          Map<String, dynamic> filmData = {
            'name': doc['name'],
            'year': doc['year'],
            'url': doc['url'],
            'short': doc['short'],
          };
          if(_searchResults.contains(filmData)){
            return;
          }else{
            print(filmData.entries.toString());
          _searchResults.add(filmData);
        }}
      });

      // Оновлення інтерфейсу після виконання пошуку
      setState(() {});
    });
  }


  bool _matchesSearchQuery(DocumentSnapshot doc) {
    // Перевірка, чи документ відповідає умовам пошуку
    String name = doc['name'].toLowerCase();
    String year = doc['year'].toString();
    String short = doc['short'].toLowerCase();
    String query = _searchQuery.toLowerCase();

    return name.contains(query) || year.contains(query) || short.contains(query);
  }
}

class FilmCard extends StatelessWidget {
  final String name;
  final int year;
  final String url;
  final String short;

  FilmCard({
    required this.name,
    required this.year,
    required this.url,
    required this.short,
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
          ],
        ),
      ),
    );
  }
}
