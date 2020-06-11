import 'dart:async';
import 'package:catbox/models/cat.dart';
import 'package:catbox/services/api.dart';
import 'package:catbox/ui/cat_details/details_page.dart';
import 'package:catbox/utils/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Liked extends StatefulWidget {
  @override
  _LikedState createState() => new _LikedState();
}

class _LikedState extends State<Liked> {
  List<Cat> _items = [];
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
      _items = cats;
    });
  }

  _reloadItems() async {
    if (_api != null) {
      final cats = await _api.getLikedCats();
      setState(() {
        _items = cats;
      });
    }
  }

  Widget _buildCartItem(BuildContext context, int index) {
    Cat cat = _items[index];

    return new Container(
      margin: const EdgeInsets.only(top: 5.0),
      child: new Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new ListTile(
              onTap: () async =>
                  _navigateToCatDetails(await _api.getCartCat(cat), index),
              leading: new Hero(
                tag: index,
                child: new CircleAvatar(
                  backgroundImage: new NetworkImage(cat.avatarUrl),
                ),
              ),
              title: new Text(
                cat.name,
                style: new TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black54),
              ),
              subtitle: new Text(cat.description),
              isThreeLine: true,
              dense: false,
            ),
          ],
        ),
      ),
    );
  }

  _navigateToCatDetails(Cat cat, Object avatarTag) {
    Navigator.of(context).push(
      new FadePageRoute(
        builder: (c) {
          return new CatDetailsPage(cat, avatarTag: avatarTag);
        },
        settings: new RouteSettings(),
      ),
    );
  }

  Widget _getAppTitleWidget() {
    return new Text(
      'Liked',
      style: new TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 32.0,
      ),
    );
  }

  Widget _buildBody() {
    return new Container(
      margin: const EdgeInsets.fromLTRB(8, 56, 8, 0),
      child: new Column(
        // A column widget can have several
        // widgets that are placed in a top down fashion
        children: <Widget>[_getAppTitleWidget(), _getListViewWidget()],
      ),
    );
  }

  Future<Null> refresh() {
    _reloadItems();
    return new Future<Null>.value();
  }

  Widget _getListViewWidget() {
    return new Flexible(
        child: new RefreshIndicator(
            onRefresh: refresh,
            child: new ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _items.length,
                itemBuilder: _buildCartItem)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFA1000),
            Color(0xFFFC1920),
            Color(0xFFFE1F50),
            Color(0xFFFF2F60),
          ],
          stops: [0.1, 0.4, 0.7, 0.9],
        ), borderRadius: BorderRadius.circular(15.0)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: _buildBody(),
        ));
  }
}
