import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<LatLng> points = [];
  //List<LatLng> points=[LatLng(29.317652, 30.846704 ),LatLng(29.312052, 30.846004 ),LatLng(29.307652, 30.846704 ),LatLng(29.317652, 30.846704)];

  MapController mapController = MapController();
  late Stream<Position> positionStream;

  @override
  void initState() {
    super.initState();
    _getCurrentPosition();

    positionStream = Geolocator.getPositionStream();
    positionStream.listen((Position position) {
      setState(() {
        points.add(LatLng(position.latitude, position.longitude)); // Add location points
      });
    });

    print(points);
   // _getStreamPosition();
  }

  Position? _currentPosition;

  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _checkLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      //_getAddressFromLatLng(_currentPosition!);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _getStreamPosition() async {
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );
    StreamSubscription<Position> positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings).listen(
            (Position? position) {
              print('streammm');
          print(position == null ? 'Unknown' : '${position.latitude
              .toString()}, ${position.longitude.toString()}');



        });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Offline Map For Fayoum", style: TextStyle(fontWeight: FontWeight.w500),),          actions: [
        IconButton(
            onPressed: () {
              //_StreamPosition();
              setState(() {
              });
              //print(points1.last);
              //_MyHomePageState() => _MyHomePageState();
            },
            tooltip: 'Start Tracking',
            icon: Icon(Icons.track_changes_outlined)),
        IconButton(
            onPressed: () {
              setState(() {
                points.clear();
              });
              // print(points.last);
            },
            tooltip: 'Reset your route',
            icon: Icon(Icons.settings_backup_restore_rounded)),
      ],),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('LAT: ${_currentPosition?.latitude ?? ""}'),
              Text('LNG: ${_currentPosition?.longitude ?? ""}'),
              Flexible(
                child: FlutterMap(
                  options: MapOptions(
                    center: LatLng(29.307652, 30.846704),
                    minZoom: 12,
                    maxZoom: 18,
                    swPanBoundary: LatLng(29.2691, 30.8062),
                    nePanBoundary: LatLng(29.3429, 30.8818),
                  ),
                  children: [
                    TileLayer(
                      tileProvider: AssetTileProvider(),
                      urlTemplate: 'assets/Fayom/{z}/{x}/{y}.png',
                    ),
                    // TileLayerWidget (),
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 15.0,
                          height: 15.0,
                          point: LatLng(_currentPosition?.latitude ?? 0.0,_currentPosition?.longitude ?? 0.0),
                          //point: LatLng(29.3195233, 30.8330717),
                          builder: (ctx) =>const Icon(Icons.pix_outlined, color: Color.fromARGB(255, 13, 146, 146)),
                        ),
                      ],
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: points, // Set the points of the polyline to the user's route points
                          color: Colors.blue,
                          strokeWidth: 3,
                          strokeCap: StrokeCap.round,
                          strokeJoin: StrokeJoin.round,
                          isDotted: true,
                          useStrokeWidthInMeter: false,
                        ),
                      ],
                    )
                  ],
                ),
              ),
              //Text('ADDRESS: ${_currentAddress ?? ""}'),
              const SizedBox(height: 32),

            ],
          ),
        ),
      ),
    floatingActionButton: FloatingActionButton(
      onPressed: _getCurrentPosition,
      child: Icon(
        Icons.my_location_rounded,
      ),
    ),
    );
  }
}