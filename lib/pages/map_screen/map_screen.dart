// ignore_for_file: unused_field, depend_on_referenced_packages

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(19.0760, 72.8777); // Mumbai
  LatLng? _currentLocation;
  String? _savedAddress;

  final _places = GoogleMapsPlaces(
      apiKey: "YOUR_GOOGLE_API_KEY"); // Put your Google API key here
  final TextEditingController _searchController = TextEditingController();
  List<Prediction> _suggestions = [];
  final Set<Marker> _markers = {};

  // Timer for debounce functionality
  Timer? _debounce;

  // Initialize map controller
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // Get user's current location
  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location permissions are denied")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
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

  // Fetch suggestions from Google Places API with debounce functionality
  Future<void> _getSuggestions(String query) async {
    // Cancel the previous timer if there was one
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    // Start a new timer for debounce
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        if (mounted) {
          setState(() => _suggestions = []);
        }
        return;
      }

      try {
        final response = await _places.autocomplete(
          query,
          components: [Component(Component.country, "in")],
        );

        if (response.isOkay) {
          if (mounted) {
            setState(() => _suggestions = response.predictions);
          }
        } else {
          print("Error fetching suggestions: ${response.errorMessage}");
        }
      } catch (e) {
        print("Error fetching suggestions: $e");
      }
    });
  }

  // Select a suggestion and mark it on the map
  Future<void> _selectSuggestion(Prediction prediction) async {
    // Fetch place details using the placeId from the suggestion
    PlacesDetailsResponse detail =
        await _places.getDetailsByPlaceId(prediction.placeId!);

    // Check if the response has valid details
    if (detail.result.geometry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('No valid location data found for the selected place')),
      );
      return;
    }

    final lat = detail.result.geometry!.location.lat;
    final lng = detail.result.geometry!.location.lng;
    final address = detail.result.formattedAddress ?? 'Address not available';

    // Add a marker for the selected place
    if (mounted) {
      setState(() {
        _savedAddress = address;
        _markers.add(Marker(
          markerId: MarkerId(prediction.placeId!),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: prediction.description,
            snippet: address,
          ),
        ));
        _suggestions = []; // Clear suggestions after selection
        _searchController.clear(); // Clear the search bar
      });
    }

    // Move the camera to the selected location
    mapController.animateCamera(
      CameraUpdate.newLatLng(LatLng(lat, lng)),
    );
  }

  @override
  void dispose() {
    // Cancel the debounce timer when the widget is disposed
    _debounce?.cancel();
    super.dispose();
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
            markers: _markers, // Display markers on the map
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          Positioned(
            top: 20,
            left: 10,
            right: 10,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: _getSuggestions, // Fetch suggestions as user types
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
                SizedBox(height: 5),
                // Display suggestion list
                _suggestions.isNotEmpty
                    ? Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListView.builder(
                          itemCount: _suggestions.length,
                          itemBuilder: (context, index) {
                            final suggestion = _suggestions[index];
                            return ListTile(
                              title: Text(suggestion.description!),
                              onTap: () => _selectSuggestion(suggestion),
                            );
                          },
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
          Positioned(
            bottom: 100,
            right: 7,
            child: FloatingActionButton(
              onPressed: _getCurrentLocation,
              backgroundColor: Color(0xFF00B200),
              child: Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}
