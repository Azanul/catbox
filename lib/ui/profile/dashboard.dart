import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:catbox/utils/routes.dart';
import 'package:catbox/ui/liked.dart';

class MyDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
            backgroundColor: Colors.transparent,
            body: ListView(
              children: <Widget>[
                SizedBox(height: 100.0,),
                Padding(
                  padding: EdgeInsets.only(top: 15.0, left: 10.0),
                  child: Text(
                    'Azanul Haque',
                    style: TextStyle(color: Colors.white, fontSize: 30.0),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.all(Radius.circular(75.0))),
                  height: MediaQuery.of(context).size.height - 300.0,
                  width: MediaQuery.of(context).size.width,
                  child: ListView(
                    primary: false,
                    padding: EdgeInsets.only(top: 40.0),
                    children: [
                      _generateOption(context, Icons.favorite, Colors.redAccent,
                          "Favorites", "All the pets that you love", tap: Liked()),
                      _generateOption(context,
                          Icons.home, Colors.blueGrey, "Find a home", "Cats you put for donation"),
                      _generateOption(context,
                          Icons.settings, Colors.blueGrey, "Settings", " "),
                      _generateOption(context, Icons.exit_to_app, Colors.grey, "Logout", "")
                    ],
                  ),
                )
              ],
            ));
  }

  Widget _generateOption(BuildContext parent, IconData icon, Color color, String title, String sub, {Widget tap}) {
    return Padding(
        padding: EdgeInsets.only(top: 20.0, left: 40.0, right: 40.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: new BorderSide(color: Colors.grey),
            ),
          ),
          child:
          Row(
            children: <Widget>[
              FlatButton(
                  child: Icon(
                    icon,
                    color: color,
                    size: 45.0,
                  ),
                  onPressed:() => Navigator.push(parent, EnterExitRoute(exitPage: this,enterPage: tap))),
              SizedBox(width: 8.0),
              FlatButton(
                  onPressed: () => Navigator.push(parent, EnterExitRoute(exitPage: this,enterPage: tap)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(fontSize: 20.0),
                        ),
                        Text(sub, style: TextStyle(fontSize: 12.0, color: Colors.grey))])
              ),
              SizedBox(height: 20.0)
            ],
          ),
        ));
  }
}
