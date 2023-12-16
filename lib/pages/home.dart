import 'package:flutter/material.dart';
import 'package:my_app/pages/liked.dart';
import 'package:my_app/pages/party.dart';
import 'package:my_app/pages/listmode.dart';
import 'package:my_app/pages/search.dart';
import 'package:my_app/profile_view.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,

      body: WillPopScope(
        onWillPop: () async=>false,
        child: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'img/background.jpg',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.fill,
              ),
              Positioned(
                right: 22,
                top: 22,
                child:
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileView()));
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Icon(Icons.person, color: Colors.black,size: 35,),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 400),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ListMode()));
                    },
                    child: Text(
                      'List mode',
                      style: TextStyle(color: Colors.black, fontSize: 30, fontFamily: 'Steppe'),
                      textAlign: TextAlign.center,
                    ),
                    style: ElevatedButton.styleFrom(fixedSize: Size(170, 135)),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PartyPage()));
                    },
                    child: Text(
                      'Match mode',
                      style: TextStyle(color: Colors.black, fontSize: 30, fontFamily: 'Steppe'),
                      textAlign: TextAlign.center,
                    ),
                    style: ElevatedButton.styleFrom(fixedSize: Size(170, 135), alignment: Alignment.center),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
        currentIndex: _selectedIndex,
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.black,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            if (index == 0) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp()));
            } else if(index == 1){
              Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage()));
            }
          });
        },
      ),
    );
  }
}
