import 'package:flutter/material.dart';

import 'package:horstl_wrapper/horstl_wrapper.dart';
import 'package:horstler/screens/loginScreen.dart';
import 'package:horstler/widgets/dish_widget.dart';
import 'package:intl/intl.dart';
import 'package:splashscreen/splashscreen.dart';

class MenuScreen extends StatefulWidget {
  final String fdNumber;
  final String passWord;

  MenuScreen({Key key, this.fdNumber, this.passWord}) : super(key: key);

  @override
  _FutureBuilderWidgetState createState() => _FutureBuilderWidgetState(fdNumber, passWord);
}

Future<List> _getDataFromFuture(String fdNumber, String passWord, DateTime currentDay) async {
  var menuWeek = [];
  var day = currentDay;
  for (int i = 0; i < 6; i++) {
    var menu = await HorstlScrapper(fdNumber, passWord).getMenu(day);
    menuWeek.add(menu);
    day = day.add(Duration(days: 1));
  }
  return menuWeek;
}

class _FutureBuilderWidgetState extends State {
  String fdNumber;
  String passWord;
  final DateTime currentDay = DateTime.now();
  final DateTime currentMonday = _getCurrentMonday(DateTime.now());


  _FutureBuilderWidgetState(this.fdNumber, this.passWord);

  /*
  @override
  void initState() {
    super.initState();
  }
   */

  @override
  Widget build(BuildContext context) {
    var dayMapping = {
      'mon': 0,
      'tue': 1,
      'wed': 2,
      'thu': 3,
      'fri': 4,
      'sat': 5,
      'sun': 5,
    };
    return new FutureBuilder(
        future: _getDataFromFuture(fdNumber, passWord, currentMonday),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
          }
          if (!snapshot.hasData) {
            return SplashScreen(
              seconds: 20,
              navigateAfterSeconds: LoginScreen(),
              title: Text('horstler'),
              image: Image(
                image: AssetImage('assets/icons/horstler_icon.png'),
              ),
              photoSize: 50,
              backgroundColor: Colors.white38,
              loaderColor: Colors.green,
              styleTextUnderTheLoader: TextStyle(),
            );
          }

          var menuList;
          menuList = snapshot.data ?? []; // ?? timeTable
          var menuWidgets = <Widget>[];
          for (var menu in menuList) {
            var dishWidgets = <Widget>[];
            for (var dish in menu.dishes) {
              dishWidgets.add(DishWidget(dish: dish,));
            }
            menuWidgets.add(
              Center(
                  child: ListView(
                    padding: EdgeInsets.all(10),
                    children: dishWidgets,
                  )
              ),
            );
          }
          return DefaultTabController(
            initialIndex: dayMapping[DateFormat('E').format(currentDay).toLowerCase()],
            length: 6,
            child: Scaffold(
              backgroundColor: Colors.white38,
              appBar: AppBar(
                backgroundColor: Colors.red,
                flexibleSpace: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TabBar(
                      indicatorColor: Colors.red,
                      tabs: <Widget>[
                        Tab(text: 'Mo.\n'
                            '${currentMonday.day}.${currentMonday.month}'),
                        Tab(text: 'Di.\n'
                            '${currentMonday.add(Duration(days: 1)).day}.${currentMonday.add(Duration(days: 1)).month}'),
                        Tab(text: 'Mi.\n'
                            '${currentMonday.add(Duration(days: 2)).day}.${currentMonday.add(Duration(days: 2)).month}'),
                        Tab(text: 'Do.\n'
                            '${currentMonday.add(Duration(days: 3)).day}.${currentMonday.add(Duration(days: 3)).month}'),
                        Tab(text: 'Fr.\n'
                            '${currentMonday.add(Duration(days: 4)).day}.${currentMonday.add(Duration(days: 4)).month}'),
                        Tab(text: 'Sa.\n'
                            '${currentMonday.add(Duration(days: 5)).day}.${currentMonday.add(Duration(days: 5)).month}'),
                      ],
                    ),
                  ],
                ),
              ),
              body: TabBarView(
                  children: menuWidgets,
              ),
            ),
          );
        }
    );
  }

  static DateTime _getCurrentMonday(DateTime currentDay) {
    var monday=1;

    while(currentDay.weekday!=monday)
    {
      currentDay = currentDay.subtract(new Duration(days: 1));
    }

    return currentDay;
  }
}