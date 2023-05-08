import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class AppFunctionality extends StatefulWidget {
  @override
  State<AppFunctionality> createState() => AppFunctionalityState();
}

class AppFunctionalityState extends State<AppFunctionality> {
  late GoogleMapController mapController;
  String searchQuery = '';
  List<Location> searchResults = [];
  Set<Marker> markers = {};
  List<Polyline> _polylines = [];
  final LatLng _center = const LatLng(24.8270, 67.0251);
  Position? currentLocation;
  StreamSubscription<Position>? positionStream;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // Handle location permission denied
        return;
      }
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        currentLocation = position;
      });
      _animateToCurrentLocation();
      _listenToLocationChanges();
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  void _listenToLocationChanges() {
    positionStream = Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        currentLocation = position;
      });
    });
  }

  void _animateToCurrentLocation() {
    if (currentLocation != null) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              currentLocation!.latitude,
              currentLocation!.longitude,
            ),
            zoom: 15.0,
          ),
        ),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onSearch(String query) async {
    List<Location> locations = await locationFromAddress(query);
    if (locations.isNotEmpty) {
      Location location = locations.first;
      mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(location.latitude, location.longitude),
          zoom: 15.0,
        ),
      ));
      setState(() {
        searchQuery = query;
        searchResults = locations;
        markers.removeWhere((marker) => true);
        markers.add(
          Marker(
            markerId: MarkerId(
              location.latitude.toString() + location.longitude.toString(),
            ),
            position: LatLng(location.latitude, location.longitude),
            infoWindow: InfoWindow(title: query),
          ),
        );
      });
    } else {
      setState(() {
        searchQuery = query;
        searchResults = [];
      });
    }
  }

  void _onMapTap(LatLng latLng) {
    setState(() {
      markers.clear();
      _polylines.clear();
      if (markers.length == 1) {
        final source = markers.first.position;
        _getDirections(source, latLng);
      }
      markers.add(
        Marker(
          markerId: MarkerId('${latLng.latitude}-${latLng.longitude}'),
          position: latLng,
          draggable: true,
          onDragEnd: (LatLng newPosition) {
            print('Marker was dragged from $latLng to $newPosition');
          },
        ),
      );
    });
  }

  Future<void> _getDirections(LatLng source, LatLng destination) async {
    // TODO: Implement this method to get directions using the Google Maps Directions API
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Kavish-Arzu",
      home: Scaffold(
        appBar: AppBar(
          title: Text("Kavish-Arzu"),
          backgroundColor: Colors.green[700],
        ),
        body: Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  currentLocation?.latitude ?? _center.latitude,
                  currentLocation?.longitude ?? _center.longitude,
                ),
                zoom: 11.0,
              ),
              markers: markers,
              // onTap: _onMapTap,
            ),
            Positioned(
              top: 50.0,
              left: 10.0,
              right: 10.0,
              child: Container(
                height: 50.0,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5.0,
                      spreadRadius: 1.0,
                      offset: const Offset(0.0, 0.0),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          border: InputBorder.none,
                        ),
                        onChanged: _onSearch,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => _onSearch(searchQuery),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 100.0,
              right: 5.0,
              child: FloatingActionButton(
                onPressed: _getCurrentLocation,
                tooltip: 'Get Current Location',
                child: Icon(Icons.location_searching),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
