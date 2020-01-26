import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:klimatic/util/utils.dart' as util;
import 'package:http/http.dart' as http;

class Klimatic extends StatefulWidget {
  @override
  _KlimaticState createState() => _KlimaticState();
}

class _KlimaticState extends State<Klimatic> {

  String _cityEntered;

  Future _goToNextScreen(BuildContext context) async {
    final Map results = await Navigator.of(context)
        .push(MaterialPageRoute<Map>(builder: (BuildContext context) {
      return ChangeCity();
    }));
    if(results != null && results.containsKey('enter')) {
      _cityEntered = results['enter'].toString();
      // print(results['enter'].toString());
    }
  }
  /*
  void showStuff() async {
    Map data = await getWeather(util.appId, util.defaultCity);
    print(data.toString());
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Klimatic',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.purple.shade100,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.menu,
              color: Colors.blueGrey,
            ),
            onPressed: () => _goToNextScreen(context),
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          Container(
            child: Image.asset(
              'images/umbrella.png',
              fit: BoxFit.fill,
            ),
            height: 800,
          ),
          Container(
            alignment: Alignment.topRight,
            margin: const EdgeInsets.fromLTRB(0, 10.9, 20.9, 0),
            child: Text(
              '${_cityEntered == null ? util.defaultCity : _cityEntered}',
              style: cityStyle(),
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Image.asset('images/light_rain.png',
            height: 600,
            width: 600,),
          ),
          Container(
            // margin: const EdgeInsets.fromLTRB(30.0, 450.0, 0.0, 0.0),
            alignment: Alignment.center,
            child: updateTempWidget(_cityEntered),
          ),
        ],
      ),
    );
  }

  Widget updateTempWidget(String city) {
    Future<Map> getWeather(String appId, String city) async {
      final String apiURL =
          'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=${util.appId}&units=metric';
      final http.Response response = await http.get(apiURL);
      return json.decode(response.body);
    }

    return FutureBuilder(
      future: getWeather(util.appId, city == null ? util.defaultCity : city),
      builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
        if (snapshot.hasData) {
          final Map content = snapshot.data;
          return Container(
            margin: const EdgeInsets.fromLTRB(30, 450, 0, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ListTile(
                  title: Text(
                    "${content['main']['temp'].toString()} C",
                    style: TextStyle(
                        fontStyle: FontStyle.normal,
                        fontSize: 49.9,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                  subtitle: ListTile(
                    title: Text(
                      "Humidity: ${content['main']['humidity'].toString()}\n"
                      "Min: ${content['main']['temp_min'].toString()} C\n"
                      "Max: ${content['main']['temp_max'].toString()} C",
                      style: extraTemp(),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}

class ChangeCity extends StatelessWidget {
  final _cityFieldController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text('Change City'),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: Image.asset(
              'images/white_snow.png',
              width: 490,
              height: 1200,
              fit: BoxFit.fill,
            ),
          ),
          ListView(
            children: <Widget>[
              ListTile(
                title: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Enter City',
                  ),
                  controller: _cityFieldController,
                  keyboardType: TextInputType.text,
                ),
              ),
              ListTile(
                title: FlatButton(
                  child: const Text(
                    'Get Weather'
                  ), 
                  onPressed: () {
                    Navigator.pop(context, {
                      'enter' : _cityFieldController.text
                    });
                  },
                  color: Colors.redAccent,
                  textColor: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

TextStyle cityStyle() {
  return TextStyle(
    color: Colors.white,
    fontSize: 22.9,
    fontStyle: FontStyle.italic,
  );
}

TextStyle extraTemp() {
  return TextStyle(
      color: Colors.white70,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.bold,
      fontSize: 17);
}

TextStyle weatherTemp() {
  return TextStyle(
      color: Colors.white,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w500,
      fontSize: 49.9);
}
