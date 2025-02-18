import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:majdoor/services/saved_location.dart';

class MapScreen extends StatefulWidget {
  final LatLng? initialPosition;

  const MapScreen({
    Key? key,
    this.initialPosition,
  }) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  Position? _currentPosition;
  List<Marker> _markers = [];
  bool _isLoading = true;
  bool _isSearching = false;

  // Example worker locations - replace with your actual data
  final List<Map<String, dynamic>> workerLocations = [
    {
      'id': '1',
      'name': 'Himanshu',
      'position': LatLng(30.7046, 76.7179), // Chandigarh coordinates
      'skill': 'Carpenter'
    },
    {
      'id': '2',
      'name': 'Shaurya',
      'position': LatLng(30.7333, 76.7794), // Mohali coordinates
      'skill': 'Plumber'
    },
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    if (widget.initialPosition != null) {
      setState(() {
        _currentPosition = Position(
          latitude: widget.initialPosition!.latitude,
          longitude: widget.initialPosition!.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
        _addMarkers();
        _isLoading = false;
      });
      return;
    }

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
        _addMarkers();
        _isLoading = false;
      });
    } catch (e) {
      print("Error getting location: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addMarkers() {
    _markers.clear();

    // Add current location marker
    if (_currentPosition != null) {
      _markers.add(
        Marker(
          point:
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          width: 80,
          height: 80,
          child: Icon(
            Icons.my_location,
            color: Color(0xFF8A4FFF),
            size: 30,
          ),
        ),
      );
    }

    // Add worker markers
    for (var worker in workerLocations) {
      _markers.add(
        Marker(
          point: worker['position'],
          width: 120,
          height: 120,
          child: Column(
            children: [
              Icon(
                Icons.location_on,
                color: Colors.red,
                size: 30,
              ),
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  worker['name'],
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _searchLocation(String query) async {
    setState(() => _isSearching = true);

    try {
      List<Location> locations = await locationFromAddress(query);

      if (locations.isNotEmpty) {
        Location location = locations.first;
        LatLng newPosition = LatLng(location.latitude, location.longitude);

        setState(() {
          _markers.add(
            Marker(
              point: newPosition,
              width: 80,
              height: 80,
              child: Icon(
                Icons.location_on,
                color: Colors.blue,
                size: 30,
              ),
            ),
          );
        });

        _mapController.move(newPosition, 15);

        // Get address details
        List<Placemark> placemarks = await placemarkFromCoordinates(
            location.latitude, location.longitude);

        if (placemarks.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${placemarks.first.locality}, ${placemarks.first.administrativeArea}',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Color(0xFF1E1E1E),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location not found'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _saveLocation(LatLng position, String address) async {
    final nameController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1E1E1E),
        title: Text(
          'Save Location',
          style: GoogleFonts.roboto(color: Colors.white),
        ),
        content: TextField(
          controller: nameController,
          style: GoogleFonts.roboto(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter location name',
            hintStyle: GoogleFonts.roboto(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF8A4FFF)),
            ),
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Save', style: TextStyle(color: Color(0xFF8A4FFF))),
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final location = SavedLocation(
                  id: DateTime.now().toString(),
                  name: nameController.text,
                  latitude: position.latitude,
                  longitude: position.longitude,
                  address: address,
                );

                final prefs = await SharedPreferences.getInstance();
                final savedLocations =
                    prefs.getStringList('saved_locations') ?? [];
                savedLocations.add(jsonEncode(location.toMap()));
                await prefs.setStringList('saved_locations', savedLocations);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Location saved successfully'),
                    backgroundColor: Color(0xFF1E1E1E),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'Nearby Workers',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Theme.of(context).primaryColor),
            onPressed: _getCurrentLocation,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter:
                        widget.initialPosition ?? LatLng(30.7333, 76.7794),
                    initialZoom: 13.0,
                    minZoom: 5.0,
                    maxZoom: 18.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: Theme.of(context).brightness ==
                              Brightness.dark
                          ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png' // Dark theme map
                          : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // Light theme map
                      subdomains: ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.majdoor',
                      tileProvider: NetworkTileProvider(),
                      // Add additional parameters for better performance
                      maxZoom: 19,
                      keepBuffer: 5,
                      tileBuilder: (context, child, tile) {
                        return child;
                      },
                    ),
                    MarkerLayer(markers: _markers),
                  ],
                ),
                // Search bar overlay
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: GoogleFonts.roboto(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search location',
                        hintStyle: GoogleFonts.roboto(
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.5),
                        ),
                        prefixIcon: Icon(Icons.search,
                            color: Theme.of(context).primaryColor),
                        suffixIcon: _isSearching
                            ? Padding(
                                padding: EdgeInsets.all(10),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context).primaryColor,
                                ),
                              )
                            : IconButton(
                                icon: Icon(Icons.clear,
                                    color: Theme.of(context).primaryColor),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          _searchLocation(value);
                        }
                      },
                    ),
                  ),
                ),
                // Zoom controls
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        heroTag: "zoom_in",
                        mini: true,
                        backgroundColor: Theme.of(context).cardColor,
                        child: Icon(Icons.add,
                            color: Theme.of(context).primaryColor),
                        onPressed: () {
                          final newZoom = _mapController.zoom + 1;
                          _mapController.move(_mapController.center, newZoom);
                        },
                      ),
                      SizedBox(height: 8),
                      FloatingActionButton(
                        heroTag: "zoom_out",
                        mini: true,
                        backgroundColor: Theme.of(context).cardColor,
                        child: Icon(Icons.remove,
                            color: Theme.of(context).primaryColor),
                        onPressed: () {
                          final newZoom = _mapController.zoom - 1;
                          _mapController.move(_mapController.center, newZoom);
                        },
                      ),
                      SizedBox(height: 8),
                      FloatingActionButton(
                        heroTag: "my_location",
                        mini: true,
                        backgroundColor: Theme.of(context).cardColor,
                        child: Icon(Icons.my_location,
                            color: Theme.of(context).primaryColor),
                        onPressed: () {
                          if (_currentPosition != null) {
                            _mapController.move(
                              LatLng(_currentPosition!.latitude,
                                  _currentPosition!.longitude),
                              15,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                // Save location button
                Positioned(
                  top: 80,
                  right: 16,
                  child: FloatingActionButton(
                    heroTag: "save_location",
                    backgroundColor: Theme.of(context).cardColor,
                    child:
                        Icon(Icons.save, color: Theme.of(context).primaryColor),
                    onPressed: () async {
                      if (_currentPosition != null) {
                        final placemarks = await placemarkFromCoordinates(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                        );
                        if (placemarks.isNotEmpty) {
                          final place = placemarks.first;
                          final address =
                              '${place.locality}, ${place.administrativeArea}';
                          _saveLocation(
                            LatLng(_currentPosition!.latitude,
                                _currentPosition!.longitude),
                            address,
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
