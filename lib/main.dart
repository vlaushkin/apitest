import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Album> fetchAlbum() async {
  final response = await http
      .get(Uri.parse('https://jsonplaceholder.typicode.com/albums/1'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    print(response.body);
    return Album.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

Future<List<CityLocation>> fetchCityLocations(String query) async {
  final response = await http.get(Uri.parse("https://www.metaweather.com/api/location/search/?query=$query"));

  if (response.statusCode == 200) {
    print(response.body);
    List<dynamic> jsons = jsonDecode(response.body);
    List<CityLocation> result = [];

    for (var value in jsons) {
      result.add(CityLocation.fromJson(value as Map<String, dynamic>));
    }

    return result;
  } else {
    throw Exception('Failed to load city locations');
  }
}

/*
  {
    "title": "Stoke-on-Trent",
    "location_type": "City",
    "woeid": 36240,
    "latt_long": "53.018581,-2.16596"
  }
  */
class CityLocation {
  final String title;
  final String locationType;
  final int woeid;
  final String latLong;

  CityLocation({
    required this.title,
    required this.locationType,
    required this.woeid,
    required this.latLong,
  });

  factory CityLocation.fromJson(Map<String, dynamic> json) {
    return CityLocation(
        title: json["title"],
        locationType: json["location_type"],
        woeid: json["woeid"],
        latLong: json["latt_long"]
    );
  }
}

class Album {
  final int userId;
  final int id;
  final String title;

  const Album({
    required this.userId,
    required this.id,
    required this.title,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
    );
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<Album> futureAlbum;

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Fetch Data Example'),
        ),
        body: Center(
          child: FutureBuilder<List<CityLocation>>(
            future: fetchCityLocations("ni"),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final List<CityLocation> futureResult = snapshot.data!;

                if (futureResult.isEmpty) {
                  return Text("The result is empty!", style: TextStyle(fontSize: 24),);
                } else {
                  List<Widget> resultChildren = [];
                  for (var value in futureResult) {
                    resultChildren.add(Text("${value.title} - ${value.locationType}", style: TextStyle(fontSize: 24),));
                  }

                  return ListView(
                    children: resultChildren,
                  );
                }
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}