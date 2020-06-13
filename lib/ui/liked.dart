import 'dart:async';
import 'package:catbox/models/cat.dart';
import 'package:catbox/services/api.dart';
import 'package:catbox/ui/cat_details/details_page.dart';
import 'package:catbox/utils/routes.dart';
import 'package:flutter/material.dart';

class Liked extends StatefulWidget {
  @override
  _LikedState createState() => _LikedState();
}

class _LikedState extends State<Liked> {
  List<Cat> _cats = [];
  CatApi _api;

  @override
  void initState() {
    super.initState();
    _loadFromFirebase();
  }

  _loadFromFirebase() async {
    final api = await CatApi.signInWithGoogle();
    final cats = await api.getLikedCats();
    setState(() {
      _api = api;
      _cats = cats;
    });
  }

  _reloadItems() async {
    if (_api != null && mounted) {
      final cats = await _api.getLikedCats();
      setState(() {
        _cats = cats;
      });
    }
  }

  Widget _buildCartItem(BuildContext context, int index) {
    Cat cat = _cats[index];

    return Container(
      width: MediaQuery.of(context).size.width / 2,
      margin: const EdgeInsets.only(top: 5.0),
      child: Align(
        alignment: Alignment.topCenter,
        child: Card(
        shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              onTap: () async => _navigateToCatDetails(await _api.getCartCat(cat), '1$index'),
              leading: Hero(
                tag: '1$index',
                child: CircleAvatar(
                  backgroundImage: NetworkImage(cat.avatarUrl),
                ),
              ),
              title: Text(
                cat.name,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
              ),
              subtitle: Text(cat.description,
                style: TextStyle(fontSize: 12, color: Colors.black38),
              ),
              isThreeLine: true,
              dense: false,
            ),
          ],
        ),
      ),
    )
    );
  }

  _navigateToCatDetails(Cat cat, Object avatarTag) {
    Navigator.of(context).push(
      FadePageRoute(
        builder: (c) {
          return CatDetailsPage(cat, avatarTag: avatarTag);
        },
        settings: RouteSettings(),
      ),
    );
  }

  Widget _getAppTitleWidget() {
    return Text(
      'Liked',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 32.0,
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
          8.0,  // A left margin of 8.0
          56.0, // A top margin of 56.0
          8.0,  // A right margin of 8.0
          0.0   // A bottom margin of 0.0
      ),
      child: Column(
        // A column widget can have several
        // widgets that are placed in a top down fashion
        children: <Widget>[
          _getAppTitleWidget(),
          _getListViewWidget()
        ],
      ),
    );
  }

  Future<Null> refresh() {
    _reloadItems();
    return Future<Null>.value();
  }

  Widget _getListViewWidget() {
    return Flexible(
        child: RefreshIndicator(
            onRefresh: refresh,
            child: GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _cats.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                itemBuilder: _buildCartItem)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFA1000),
                Color(0xFFFC1920),
                Color(0xFFFE1F50),
                Color(0xFFFF2F60),
              ],
              stops: [0.1, 0.4, 0.7, 0.9],
            ),
            borderRadius: BorderRadius.circular(15.0)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: _buildBody(),
        ));
  }
}
