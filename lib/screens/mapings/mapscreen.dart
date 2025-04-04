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
import 'package:majdoor/screens/profiles/account.dart';

class MapScreen extends StatefulWidget {
  final LatLng? initialPosition;
  final SavedLocation? savedLocation;

  const MapScreen({
    Key? key,
    this.initialPosition,
    this.savedLocation,
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
  LatLng? _searchedLocation;
  String? _searchedAddress;
  LatLng? _tappedLocation;

  // Example worker locations - replace with your actual data
  final List<Map<String, dynamic>> workerLocations = [
    {
      'id': '1',
      'name': 'Himanshu',
      'position': LatLng(30.7046, 76.7179),
      'skill': 'Carpenter'
    },
    {
      'id': '2',
      'name': 'Shaurya',
      'position': LatLng(30.7333, 76.7794),
      'skill': 'Plumber'
    },
  ];

  @override
  void initState() {
    super.initState();

    // Print debugging info
    if (widget.savedLocation != null) {
      print(
          "MapScreen opened with saved location: ${widget.savedLocation!.name}");
      print(
          "Coordinates: (${widget.savedLocation!.latitude}, ${widget.savedLocation!.longitude})");
    }

    _initializeMap();
  }

  Future<void> _initializeMap() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // First, try to get actual current location regardless of what we're showing
      try {
        final permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          await Geolocator.requestPermission();
        }

        Position actualPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        _currentPosition = actualPosition;
      } catch (e) {
        print("Could not get actual current location: $e");
        // Continue without actual current location
      }

      // If we're showing a saved location and couldn't get current location,
      // create a position for the saved location but ONLY for map centering
      if (_currentPosition == null && widget.savedLocation != null) {
        print("Creating position for saved location (for map center only)");
        _currentPosition = Position(
          latitude: widget.savedLocation!.latitude,
          longitude: widget.savedLocation!.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      }

      // Update markers based on the current state
      _updateMarkers();

      setState(() {
        _isLoading = false;
      });

      // Post-initialization tasks
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.savedLocation != null) {
          // Center map on saved location
          Future.delayed(Duration(milliseconds: 300), () {
            _mapController.move(
                LatLng(widget.savedLocation!.latitude,
                    widget.savedLocation!.longitude),
                15.0);

            // Show notification about the saved location
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Viewing ${widget.savedLocation!.name}'),
                backgroundColor: Theme.of(context).primaryColor,
              ),
            );
          });
        }
      });
    } catch (e) {
      print("Error initializing map: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateMarkers() {
    _markers.clear();

    // Add markers for different location types, being careful about overlapping markers

    // 1. Add saved location marker if we're viewing one
    if (widget.savedLocation != null) {
      _markers.add(
        Marker(
          point: LatLng(
              widget.savedLocation!.latitude, widget.savedLocation!.longitude),
          width: 120,
          height: 120,
          child: Column(
            children: [
              Icon(
                Icons.place,
                color: Colors.red,
                size: 50,
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  widget.savedLocation!.name,
                  style: GoogleFonts.roboto(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 2. Add current location marker ONLY if it's different from the saved location
    if (_currentPosition != null) {
      LatLng currentLatLng =
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

      // Check if current position is different from saved location
      bool isCurrentDifferentFromSaved = true;
      if (widget.savedLocation != null) {
        // Calculate distance between current position and saved location
        const double minDistanceThreshold = 0.0001; // Approximately 10 meters
        double latDiff =
            (_currentPosition!.latitude - widget.savedLocation!.latitude).abs();
        double lngDiff =
            (_currentPosition!.longitude - widget.savedLocation!.longitude)
                .abs();

        // Only consider them different if they're more than the threshold apart
        isCurrentDifferentFromSaved =
            latDiff > minDistanceThreshold || lngDiff > minDistanceThreshold;
      }

      // Only add current position marker if it's different from saved location
      if (isCurrentDifferentFromSaved) {
        _markers.add(
          Marker(
            point: currentLatLng,
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
    }

    // 3. Add tapped location marker if applicable
    if (_tappedLocation != null) {
      _markers.add(
        Marker(
          point: _tappedLocation!,
          width: 80,
          height: 80,
          child: Icon(
            Icons.push_pin,
            color: Colors.orange,
            size: 30,
          ),
        ),
      );
    }

    // 4. Add searched location marker if applicable
    if (_searchedLocation != null) {
      _markers.add(
        Marker(
          point: _searchedLocation!,
          width: 80,
          height: 80,
          child: Icon(
            Icons.location_on,
            color: Colors.blue,
            size: 30,
          ),
        ),
      );
    }

    // 5. Add worker markers
    for (var worker in workerLocations) {
      _markers.add(
        Marker(
          point: worker['position'],
          width: 120,
          height: 120,
          child: Column(
            children: [
              Icon(
                Icons.person_pin_circle,
                color: Colors.redAccent,
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

        // Get address details for the searched location
        List<Placemark> placemarks = await placemarkFromCoordinates(
            location.latitude, location.longitude);

        String address = 'Unknown location';
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          address =
              '${place.name ?? ''} ${place.locality ?? ''}, ${place.administrativeArea ?? ''}';
          address = address.trim();
          if (address.startsWith(',')) {
            address = address.substring(1).trim();
          }
        }

        // Store the searched location and address
        setState(() {
          _searchedLocation = newPosition;
          _searchedAddress = address;

          // Add a marker for the searched location
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

        // Show the address in a snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              address,
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color(0xFF1E1E1E),
            duration: Duration(seconds: 2),
          ),
        );
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
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          'Save Location',
          style: GoogleFonts.roboto(
              color: Theme.of(context).textTheme.titleLarge?.color),
        ),
        content: TextField(
          controller: nameController,
          style: GoogleFonts.roboto(
              color: Theme.of(context).textTheme.bodyLarge?.color),
          decoration: InputDecoration(
            hintText: 'Enter location name',
            hintStyle: GoogleFonts.roboto(
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.7)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Save',
                style: TextStyle(color: Theme.of(context).primaryColor)),
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
                    backgroundColor: Colors.green,
                  ),
                );

                // Clear the searched location after saving it
                setState(() {
                  _searchedLocation = null;
                  _searchedAddress = null;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleMapTap(LatLng tappedPoint, BuildContext context) async {
    try {
      setState(() {
        _tappedLocation = tappedPoint;
        _updateMarkers();
      });

      // Move map to the tapped location
      _mapController.move(tappedPoint, _mapController.zoom);

      // Get address for the tapped location
      List<Placemark> placemarks = await placemarkFromCoordinates(
          tappedPoint.latitude, tappedPoint.longitude);

      String address = 'Unknown location';
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        address = [
          place.name,
          place.locality,
          place.administrativeArea,
          place.country
        ].where((element) => element != null && element.isNotEmpty).join(', ');
      }

      // Show address in a snackbar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location: $address'),
            backgroundColor: Colors.black87,
            action: SnackBarAction(
              label: 'SAVE',
              textColor: Colors.orange,
              onPressed: () {
                _saveLocation(tappedPoint, address);
              },
            ),
          ),
        );
      }
    } catch (e) {
      print('Error handling map tap: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not get location details'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine initial center for the map
    LatLng initialCenter;

    if (widget.savedLocation != null) {
      // If we're opening a saved location, center on it
      initialCenter = LatLng(
          widget.savedLocation!.latitude, widget.savedLocation!.longitude);
    } else if (_currentPosition != null) {
      // Otherwise, use current position if available
      initialCenter =
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    } else {
      // Default fallback
      initialCenter = LatLng(30.7333, 76.7794); // Default coordinates
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          widget.savedLocation != null
              ? 'Location: ${widget.savedLocation!.name}'
              : 'Nearby Workers',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Theme.of(context).primaryColor),
            onPressed: _initializeMap,
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
                    initialCenter: initialCenter,
                    initialZoom: 13.0,
                    minZoom: 5.0,
                    maxZoom: 18.0,
                    onLongPress: (point, latLng) {
                      _handleMapTap(latLng, context);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: Theme.of(context).brightness ==
                              Brightness.dark
                          ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
                          : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.majdoor',
                      tileProvider: NetworkTileProvider(),
                      maxZoom: 19,
                      keepBuffer: 5,
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
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                        isDense: false,
                        alignLabelWithHint: true,
                      ),
                      textAlignVertical: TextAlignVertical.center,
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          _searchLocation(value);
                        }
                      },
                    ),
                  ),
                ),
                // Add a Save button for searched location
                if (_searchedLocation != null)
                  Positioned(
                    top: 80,
                    left: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Theme.of(context).shadowColor.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.save_alt,
                              color: Theme.of(context).primaryColor,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                if (_searchedLocation != null &&
                                    _searchedAddress != null) {
                                  _saveLocation(
                                      _searchedLocation!, _searchedAddress!);
                                }
                              },
                              child: Text(
                                'Save searched location',
                                style: GoogleFonts.roboto(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
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
                // Help tooltip for saving any location

                // Clear tapped location button (only show when a location is tapped)
                if (_tappedLocation != null)
                  Positioned(
                    bottom: 150,
                    right: 16,
                    child: FloatingActionButton.small(
                      heroTag: "clear_tapped",
                      backgroundColor: Colors.white,
                      child: Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _tappedLocation = null;
                          _updateMarkers();
                        });
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
