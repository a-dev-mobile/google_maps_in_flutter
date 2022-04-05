import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

/*


Latitude of Санкт-Петербург	59.9342802
Longitude of Санкт-Петербург	30.3350986

*/
class _MyAppState extends State<MyApp> {
  late GoogleMapController mapController;

  final LatLng latLangSpb = const LatLng(59.9342802, 30.3350986);

  List<Marker> _markers = <Marker>[];

  @override
  void initState() {
    _markers.add(const Marker(
        markerId: MarkerId('SomeId'),
        position: LatLng(59.9342802, 30.3350986),
        infoWindow: InfoWindow(title: 'The title of the marker')));
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: FloatingActionButton(onPressed: () async {
          print('test');
          print('pos.toString()');
          var pos = await _determinePosition();
          // latLangSpb = LatLng(pos.latitude, pos.longitude);

          print(pos.toString());
        }),
        appBar: AppBar(
          title: const Text('Maps Sample App'),
          backgroundColor: Colors.green[700],
        ),
        body: Column(
          children: [
            Expanded(
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                markers: Set<Marker>.of(_markers),
                initialCameraPosition: CameraPosition(
                  target: latLangSpb,
                  zoom: 11.0,
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: _determinePosition(),
                builder:
                    (BuildContext context, AsyncSnapshot<Position> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.done:
                      final lat = snapshot.data!.latitude;
                      final lng = snapshot.data!.longitude;
                      return GoogleMap(
                        onMapCreated: _onMapCreated,
                        markers: <Marker>{
                          Marker(
                            icon: BitmapDescriptor.defaultMarkerWithHue(200),
                              markerId: const MarkerId('markerr'),
                              position: LatLng(lat, lng))
                        },
                        initialCameraPosition: CameraPosition(
                          target: LatLng(lat, lng),
                          zoom: 15.0,
                        ),
                      );
                    default:
                      return const Text('LOAD....');
                  }
                },
              ),
            ),
            Expanded(
                child: Container(
              child: Center(
                  child: ElevatedButton(
                child: const Text('get current pos'),
                onPressed: () async {
                  var pos = await _determinePosition();
                  // latLangSpb = LatLng(pos.latitude, pos.longitude);

                  print('pos.toString()');
                  print(pos.toString());
                },
              )),
              color: Colors.blueGrey,
            ))
          ],
        ),
      ),
    );
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
