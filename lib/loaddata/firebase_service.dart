import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class FirebaseService {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref('features');

  Future<List<Marker>> getMarkers() async {
    DataSnapshot snapshot = await _databaseReference.get();
    if (snapshot.exists) {
      List<Marker> markers = [];
      List<dynamic> data = snapshot.value as List<dynamic>;
      for (var item in data) {
        double lat = item['geometry']['coordinates'][1] as double;
        double lng = item['geometry']['coordinates'][0] as double;
        markers.add(Marker(
          point: LatLng(lat, lng),
          child:  const Icon(
            Icons.location_pin,
            color: Colors.red,
          ),
        ));
      }
      return markers;
    } else {
      return [];
    }
  }
}
