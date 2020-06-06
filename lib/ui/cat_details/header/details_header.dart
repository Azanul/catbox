import 'dart:async';
import 'package:catbox/services/api.dart';
import 'package:catbox/models/cat.dart';
import 'package:catbox/ui/cat_details/header/cut_colored_image.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class CatDetailHeader extends StatefulWidget {
  final Cat cat;
  final Object avatarTag;

  CatDetailHeader(
    this.cat, {
    @required this.avatarTag,
  });

  @override
  _CatDetailHeaderState createState() => new _CatDetailHeaderState();
}

class _CatDetailHeaderState extends State<CatDetailHeader> {
  bool _likeDisabled = true;
  String _likeText = "";
  bool _cartDisabled = true;
  String _cartText = "";
  int _likeCounter = 0;
  StreamSubscription _watcher;

  Future<CatApi> _api;

  @override
  void initState() {
    super.initState();
    _likeCounter = widget.cat.likeCounter;
    _api = CatApi.signInWithGoogle();
    updateLikeState();
    updateCartState();
  }
  void likeCat() async {
    final api = await _api;
    if(await api.hasLikedCat(widget.cat)) {
      api.unlikeCat(widget.cat);
      setState(() {
        _likeCounter--;
        _likeText = "LikE";
      });
    }
    else {
      api.likeCat(widget.cat);
      setState(() {
        _likeCounter++;
        _likeText = "UnlikE";
      });
    }
  }

  void cartCat() async {
    final api = await _api;
    if(await api.inCart(widget.cat)) {
      api.removeFromCart(widget.cat);
      setState(() {
        _cartText = "Add to cart";
      });
    }
    else {
      api.addToCart(widget.cat);
      setState(() {
        _cartText = "DiscarT";
      });
    }
  }

  void updateLikeState() async{
    final api = await _api;
    _watcher = api.watch(widget.cat, (cat){
      if(mounted) {
        setState(() {
          _likeCounter = cat.likeCounter;
        });
      }
    });
    bool liked = await api.hasLikedCat(widget.cat);
    if(mounted){
      setState(() {
        _likeDisabled = false;
        _likeText = liked?'UnlikE':'LikE';
      });
    }
  }

  void updateCartState() async {
    final api = await _api;
    bool added = await api.inCart(widget.cat);
    if(mounted){
      setState(() {
        _cartDisabled = false;
        _cartText = added?'DiscarT':'Add to cart';
      });
    }
  }
  static const BACKGROUND_IMAGE = 'images/profile_header_background.png';

  @override
  void dispose(){
    if(_watcher == null)
      _watcher.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textTheme = theme.textTheme;
    var screenWidth = MediaQuery.of(context).size.width;

    var diagonalBackground = new DiagonallyCutColoredImage(
      new Image.asset(
        BACKGROUND_IMAGE,
        width: screenWidth,
        height: 280.0,
        fit: BoxFit.cover,
      ),
      color: const Color(0xBB42A5F5),
    );

    var avatar = new Hero(
      tag: widget.avatarTag,
      child: new CircleAvatar(
        backgroundImage: new NetworkImage(widget.cat.avatarUrl),
        radius: 75.0,
      ),
    );

    var likeInfo = new Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          new Icon(
            Icons.thumb_up,
            color: Colors.white,
            size: 16.0,
          ),
          new Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: new Text(
              _likeCounter.toString(),
              style: textTheme.subtitle1.copyWith(color: Colors.white),
            )
          )
        ],
      ),
    );

    var actionButtons = new Padding(
      padding: const EdgeInsets.only(
        top: 16.0,
        left: 16.0,
        right: 16.0,
      ),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          new ClipRRect(
            borderRadius: new BorderRadius.circular(30.0),
            child: new RaisedButton(
              color: Colors.lightGreen,
              disabledColor: Colors.grey,
              textColor: Colors.white,
              onPressed: () async {_likeDisabled ? null : likeCat();},
              child: new Text(_likeText),
            ),
          ),
          new ClipRRect(
            borderRadius: new BorderRadius.circular(30.0),
            child: new RaisedButton(
              color: Colors.orange,
              disabledColor: Colors.grey,
              textColor: Colors.white,
              onPressed: () async {_cartDisabled ? null : cartCat();},
              child: new Text(_cartText),
            ),
          ),
        ],
      ),
    );

    return new Stack(
      children: [
        diagonalBackground,
        new Align(
          alignment: FractionalOffset.bottomCenter,
          heightFactor: 1.4,
          child: new Column(
            children: [
              avatar,
              likeInfo,
              actionButtons,
            ],
          ),
        ),
        new Positioned(
          top: 26.0,
          left: 4.0,
          child: new BackButton(color: Colors.white),
        ),
      ],
    );
  }
}
