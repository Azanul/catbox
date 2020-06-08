import 'package:catbox/ui/cat_list.dart';
import 'package:catbox/ui/profile/dashboard.dart';
import 'package:catbox/ui/cart.dart';
import 'package:catbox/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

void main() async {
  runApp(new CatBoxApp());
}

class CatBoxApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        initialRoute: 'initial',
        theme: new ThemeData(
            primarySwatch: Colors.blue,
            accentColor: Colors.pinkAccent,
            fontFamily: 'Ubuntu'),
        home: Home());
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _crrindex = 0;
  PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = new PageController(initialPage: _crrindex);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _tabs = [MyDashboard(), new CatList(), new MyCart()];
    return new Container(
        decoration: BoxDecoration(gradient: kGradient),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: PageView(
              controller: _controller,
              children: _tabs,
              onPageChanged: (newPage) {
                setState(() {
                  this._crrindex = newPage;
                });
              }),
          bottomNavigationBar: CurvedNavigationBar(
            backgroundColor: Colors.transparent,
            items: [
              Icon(Icons.perm_identity, size: 30),
              Icon(Icons.pets, size: 30),
              Icon(Icons.shopping_cart, size: 30)
            ],
            onTap: (index) {
              this._controller.animateToPage(index,
                  duration: Duration(milliseconds: 250),
                  curve: Curves.easeInOut);
            },
            index: _crrindex,
          ),
        ));
  }
}
