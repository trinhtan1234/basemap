import 'package:basemap/location_gps/location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final MapController mapController = MapController();
  Future<LatLng?> _currentPositionFuture = Future.value(null);
  final LocationService _locationService = LocationService();
  double _currentZoom = 8.0;
  bool _isButtonVisible = true;

  final List<Marker> _additionalMarkers = [
    const Marker(
      point: LatLng(21.028511, 105.804817),
      child: Icon(
        Icons.location_pin,
        color: Colors.red,
      ),
    )
  ];

  @override
  void initState() {
    super.initState();
    _currentPositionFuture = _locationService.getCurrentPositionFuture();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<LatLng?>(
            future: _currentPositionFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError || !snapshot.hasData) {
                return const Center(child: Text('Lỗi khi lấy vị trí'));
              } else {
                final currentPosition = snapshot.data!;
                return FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: currentPosition,
                    initialZoom: _currentZoom,
                    onPositionChanged: (position, hasGesture) {
                      _currentZoom = position.zoom;
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.basemap',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: currentPosition,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Container(
                                width: 9,
                                height: 9,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),
                        ..._additionalMarkers,
                      ],
                    ),
                  ],
                );
              }
            },
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            bottom: _isButtonVisible ? 20 : -100,
            right: 20,
            child: FloatingActionButton(
              onPressed: () async {
                setState(() {
                  _isButtonVisible = false; //Hide the button
                });
                await Future.delayed(
                    const Duration(milliseconds: 300)); // Wait for animation
                final newPosition =
                    await _locationService.getCurrentPositionFuture();
                if (newPosition != null) {
                  setState(() {
                    _currentPositionFuture = Future.value(newPosition);
                  });
                  mapController.move(newPosition, _currentZoom);
                }
                setState(() {
                  _isButtonVisible = true; // Show the button again
                });
              },
              child: const Icon(
                Icons.my_location,
              ),
            ),
          )
        ],
      ),
    );
  }
}
