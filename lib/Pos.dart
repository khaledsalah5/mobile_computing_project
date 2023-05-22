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
  //List<LatLng> pointsTest =[LatLng(29.317652, 30.846704 ),LatLng(29.312052, 30.846004 ),LatLng(29.307652, 30.846704 ),LatLng(29.317652, 30.846704)];

  MapController mapController = MapController();
  late Stream<Position> positionStream;

  @override
  void initState() {
    super.initState();
    _getCurrentPosition();

    Timer.periodic(const Duration(seconds: 1), (timer) {
      positionStream = Geolocator.getPositionStream();
      positionStream.listen((Position position) {
        setState(() {
          points.add(LatLng(
              position.latitude, position.longitude)); // Add location points
        });
      });
      print(points);
    });
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
    }).catchError((e) {
      debugPrint(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Offline Map For Fayoum",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
              onPressed: () {
                  points.clear();
              },
              tooltip: 'Reset your route',
              icon: const Icon(Icons.settings_backup_restore_rounded)),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Latitude: ${_currentPosition?.latitude ?? ""}'),
              Text('Longitude: ${_currentPosition?.longitude ?? ""}'),
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
                          width: 10,
                          height: 10,
                          point: LatLng(
                              _currentPosition?.latitude ?? 29.3195233,
                              _currentPosition?.longitude ?? 30.8330717),
                          builder: (ctx) => const Icon(Icons.arrow_drop_down_circle,
                              color: Color.fromARGB(255, 13, 146, 146)),
                        ),
                      ],
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: points,
                          color: Colors.blue,
                          strokeWidth: 5,
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
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentPosition,
        child: const Icon(
          Icons.my_location_rounded,
        ),
      ),
    );
  }
}
