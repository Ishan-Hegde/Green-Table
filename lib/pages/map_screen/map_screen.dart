import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapScreen extends StatefulWidget {
  final LatLng initialPosition;

  const MapScreen({super.key, required this.initialPosition});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  LatLng _center = const LatLng(19.0760, 72.8777); // Default to Mumbai
  LatLng _pickedLocation = const LatLng(19.0760, 72.8777);
  final List<Marker> _markers = [];
  Circle? _currentLocationCircle;
  String _addressName = "";
  final Location _location = Location();
  StreamSubscription<LocationData>? _locationSubscription;

  List<Map<String, dynamic>> _savedAddresses = [];

  Future<void> _getCurrentLocation() async {
    var userLocation = await _location.getLocation();
    if (!mounted) return;

    LatLng currentLocation = LatLng(
      userLocation.latitude ?? 19.0760,
      userLocation.longitude ?? 72.8777,
    );

    setState(() {
      _center = currentLocation;
      _pickedLocation = _center;

      _markers.removeWhere(
          (marker) => marker.markerId == const MarkerId('currentLocation'));
      _markers.add(Marker(
        markerId: const MarkerId('currentLocation'),
        position: currentLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));

      _currentLocationCircle = Circle(
        circleId: const CircleId('currentLocationCircle'),
        center: currentLocation,
        radius: 50,
        fillColor: Colors.blue.withOpacity(0.3),
        strokeColor: Colors.blueAccent,
        strokeWidth: 2,
      );
    });

    mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: currentLocation,
        zoom: 17.0,
      ),
    ));
  }

  Future<void> _startLocationUpdates() async {
    _locationSubscription = _location.onLocationChanged.listen((userLocation) {
      if (!mounted) return;

      LatLng currentLocation = LatLng(
        userLocation.latitude ?? 19.0760,
        userLocation.longitude ?? 72.8777,
      );

      setState(() {
        _center = currentLocation;
        _pickedLocation = _center;

        _currentLocationCircle = Circle(
          circleId: const CircleId('currentLocationCircle'),
          center: currentLocation,
          radius: 50,
          fillColor: Colors.blue.withOpacity(0.3),
          strokeColor: Colors.blueAccent,
          strokeWidth: 2,
        );
      });

      mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: currentLocation,
          zoom: 17.0,
          bearing: userLocation.heading ?? 0.0,
        ),
      ));
    });
  }

  Future<String> _getAddressFromLatLng(LatLng location) async {
    final apiKey = 'YOUR_GOOGLE_API_KEY'; // Replace with your Google API Key
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${location.latitude},${location.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'].isNotEmpty) {
        return data['results'][0]['formatted_address'];
      } else {
        return 'Address not found';
      }
    } else {
      throw Exception('Failed to load address');
    }
  }

  Future<void> _saveAddress() async {
    if (_addressName.isEmpty) {
      _showErrorDialog("Please enter an address name.");
      return;
    }

    final fullAddress = await _getAddressFromLatLng(_pickedLocation);

    final newAddress = {
      'latitude': _pickedLocation.latitude,
      'longitude': _pickedLocation.longitude,
      'name': _addressName,
      'full_address': fullAddress,
    };

    if (!mounted) return;
    setState(() {
      _savedAddresses.add(newAddress);
    });

    await _saveAddressesToPreferences();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Address saved successfully!')),
    );
  }

  Future<void> _loadAddressesFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAddressesString = prefs.getString('saved_addresses');

    if (savedAddressesString != null) {
      if (!mounted) return;
      setState(() {
        _savedAddresses = List<Map<String, dynamic>>.from(
          json.decode(savedAddressesString),
        );
      });
    }
  }

  Future<void> _saveAddressesToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAddressesString = json.encode(_savedAddresses);
    await prefs.setString('saved_addresses', savedAddressesString);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSavedAddresses() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Saved Addresses'),
          content: ListView.builder(
            itemCount: _savedAddresses.length,
            itemBuilder: (context, index) {
              final address = _savedAddresses[index];
              return ListTile(
                title: Text(address['name']),
                subtitle: Text(address['full_address']),
              );
            },
          ),
        );
      },
    );
  }

  void _onMapTapped(LatLng location) {
    setState(() {
      _pickedLocation = location;
      _markers.clear();
      _markers.add(Marker(
        markerId: MarkerId(location.toString()),
        position: location,
        infoWindow: const InfoWindow(title: 'Selected Location'),
      ));
    });

    _showSaveAddressDialog();
  }

  // Show dialog to enter name for the address
  void _showSaveAddressDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Save Address'),
          content: TextField(
            onChanged: (value) {
              _addressName = value;
            },
            decoration: const InputDecoration(hintText: 'Enter Address Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _saveAddress();
              },
              style: TextButton.styleFrom(
                foregroundColor:
                    const Color(0xFF00B200), // Same color as app bar
              ),
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor:
                    const Color(0xFF00B200), // Same color as app bar
              ),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadAddressesFromPreferences();
    _getCurrentLocation();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    mapController.dispose();
    _locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00B200),
        title: const Text('GT MAPS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_home_sharp),
            onPressed: _showSavedAddresses,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 10.0,
            ),
            markers: Set<Marker>.of(_markers),
            circles: _currentLocationCircle != null
                ? <Circle>{_currentLocationCircle!}
                : {},
            onTap: _onMapTapped,
          ),
          Positioned(
            bottom: 110,
            right: 8,
            child: FloatingActionButton(
              onPressed: _getCurrentLocation,
              backgroundColor: const Color(0xFF00B200),
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}
