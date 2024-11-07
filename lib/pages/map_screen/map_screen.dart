// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final LatLng _center =
      const LatLng(19.0760, 72.8777); // Coordinates for Mumbai
  LatLng? _currentLocation;
  String? _savedAddress;

  // Initialize Places API with your Google API Key
  final _places = GoogleMapsPlaces(
      apiKey:
          "AIzaSyDNdM7R0dcqvV8BW8nigVS3bwgSjc3A-RQ"); // Replace with your API key

  // Method to handle map creation
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // Method to get the user's current location
  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, show a message to the user.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location permissions are denied")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location permissions are permanently denied")),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
    mapController.animateCamera(
      CameraUpdate.newLatLng(_currentLocation!),
    );
  }

  // Method to search for a place
  Future<void> _searchPlace() async {
    Prediction? prediction = await PlacesAutocomplete.show(
      context: context,
      apiKey: "YOUR_GOOGLE_MAPS_API_KEY",
      mode: Mode.overlay,
      language: "en",
      components: [Component(Component.country, "in")],
    );

    if (prediction != null) {
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(prediction.placeId!);
      final lat = detail.result.geometry!.location.lat;
      final lng = detail.result.geometry!.location.lng;

      setState(() {
        _savedAddress = detail.result.formattedAddress;
        mapController.animateCamera(CameraUpdate.newLatLng(LatLng(lat, lng)));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Green Table Map'),
        backgroundColor: Color(0xFF00B200),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 11.0,
            ),
            markers: _currentLocation != null
                ? {
                    Marker(
                      markerId: MarkerId("current_location"),
                      position: _currentLocation!,
                      infoWindow: InfoWindow(title: 'Your Location'),
                    )
                  }
                : {},
          ),
          Positioned(
            top: 20,
            left: 10,
            right: 10,
            child: Column(
              children: [
                // Search bar to find a location
                TextField(
                  readOnly: true,
                  onTap: _searchPlace,
                  decoration: InputDecoration(
                    hintText: 'Search for a place',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: _getCurrentLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF00B200),
                      ),
                      child: Text('Detect Location'),
                    ),
                    if (_savedAddress != null)
                      Expanded(
                        child: Text(
                          'Saved Address: $_savedAddress',
                          style: TextStyle(color: Colors.black, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
