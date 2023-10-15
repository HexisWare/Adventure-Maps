import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Map Tracking Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final MapController _mapController = MapController();
  Position? _currentPosition;
  List<LatLng> visitedPoints = [];

  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _locateUser();
    _trackUser();
  }

  _locateUser() async {
    // ... [No changes here, same as your code]
  }

  _trackUser() {
    final positionStream = Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.best,
      distanceFilter: 10, // update every 10 meters
    );

    _positionStreamSubscription = positionStream.listen((Position position) {
      setState(() {
        _currentPosition = position;
        visitedPoints.add(LatLng(position.latitude, position.longitude));
        _mapController.move(
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            15);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _positionStreamSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter Map Tracking Demo')),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: LatLng(40.71, -74.01), // New York's LatLng as default
          zoom: 15.0,
        ),
        layers: [
          TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          PolylineLayerOptions(
            polylines: [
              Polyline(
                points: visitedPoints,
                strokeWidth: 4.0,
                color: Colors.blue,
              ),
            ],
          ),
          MarkerLayerOptions(
            markers: _currentPosition != null
                ? [
              Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(
                    _currentPosition!.latitude, _currentPosition!.longitude),
                builder: (ctx) => Icon(Icons.location_on, size: 40),
              )
            ]
                : [],
          ),
        ],
      ),
    );
  }
}
