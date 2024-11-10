// ignore_for_file: unused_import, avoid_print, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location;
import 'package:geocoding/geocoding.dart'; // Geocoding package
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences for saving address
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final location.Location _location = location.Location();
  LatLng _initialPosition = LatLng(0.0, 0.0);
  LatLng _currentPosition = LatLng(0.0, 0.0);
  String _address = 'Current Address';
  bool _serviceEnabled = false;
  location.PermissionStatus? _permissionGranted;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  // Check if location permission is granted
  Future<void> _checkLocationPermission() async {
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == location.PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != location.PermissionStatus.granted) {
        return;
      }
    }

    // Get current location if permission granted
    _getCurrentLocation();
  }

  // Get current location and move the camera to it
  Future<void> _getCurrentLocation() async {
    final currentLocation = await _location.getLocation();

    setState(() {
      _currentPosition =
          LatLng(currentLocation.latitude!, currentLocation.longitude!);
      _initialPosition = _currentPosition;
    });

    _getAddressFromLatLng(_currentPosition);

    _mapController
        ?.moveCamera(CameraUpdate.newLatLngZoom(_currentPosition, 15));
  }

  // Get address from LatLng
  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    try {
      // Get the placemarks from the coordinates
      List<Placemark>? placemarks = await GeocodingPlatform.instance
          ?.placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      Placemark place = placemarks![0];
      setState(() {
        _address = "${place.name}, ${place.locality}, ${place.country}";
      });
    } catch (e) {
      // ignore: avoid_print
      print("Error getting address: $e");
    }
  }

  // Save the address in MongoDB
  Future<void> _saveAddress(String addressName) async {
    // Assuming you have an API endpoint like POST /save-address
    final url = Uri.parse('http://your-backend-url/save-address');
    final response = await http.post(
      url,
      body: json.encode({
        'address': _address,
        'name': addressName,
        // Include user identifier (e.g., userId) if needed
        'userId': 'user_id_here',
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Success - handle as required
      print('Address saved successfully');
    } else {
      // Error handling
      print('Failed to save address');
    }
  }

  // Show dialog to input address name
  void _showSaveAddressDialog() {
    // ignore: no_leading_underscores_for_local_identifiers
    TextEditingController _nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Save Address'),
          content: TextField(
            controller: _nameController,
            decoration: InputDecoration(hintText: 'Enter address name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String addressName = _nameController.text;
                if (addressName.isNotEmpty) {
                  _saveAddress(addressName);
                  Navigator.pop(context);
                } else {
                  // Show some error message if name is empty
                  print('Address name cannot be empty');
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Handle tap to get address from clicked location on map
  void _onMapTapped(LatLng latLng) async {
    setState(() {
      _currentPosition = latLng;
    });

    // Fetch address based on the tapped location
    await _getAddressFromLatLng(latLng);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map Screen'),
        actions: [
          IconButton(
            icon: Icon(Icons.my_location),
            onPressed: _getCurrentLocation, // Move camera to current location
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 14.0,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onTap: _onMapTapped, // On map tap, update location and address
              onCameraMove: (CameraPosition position) {
                setState(() {
                  _currentPosition = position.target;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('Current Address: $_address'),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed:
                      _showSaveAddressDialog, // Show dialog to save address
                  child: Text('Save Address'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _getCurrentLocation,
                  child: Text('Live Location'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
