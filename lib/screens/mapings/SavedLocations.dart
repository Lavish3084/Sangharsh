import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:majdoor/services/saved_location.dart';
import 'package:majdoor/screens/mapings/mapscreen.dart';

class SavedLocationsScreen extends StatefulWidget {
  @override
  _SavedLocationsScreenState createState() => _SavedLocationsScreenState();
}

class _SavedLocationsScreenState extends State<SavedLocationsScreen> {
  List<SavedLocation> _savedLocations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedLocations();
  }

  Future<void> _loadSavedLocations() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocations = prefs.getStringList('saved_locations') ?? [];

      final locations = savedLocations.map((locationStr) {
        final Map<String, dynamic> locationMap = jsonDecode(locationStr);
        return SavedLocation.fromMap(locationMap);
      }).toList();

      setState(() {
        _savedLocations = locations;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading saved locations: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteLocation(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocations = prefs.getStringList('saved_locations') ?? [];

      final updatedLocations = savedLocations.where((locationStr) {
        final Map<String, dynamic> locationMap = jsonDecode(locationStr);
        return locationMap['id'] != id;
      }).toList();

      await prefs.setStringList('saved_locations', updatedLocations);

      setState(() {
        _savedLocations.removeWhere((location) => location.id == id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location deleted'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print("Error deleting location: $e");
    }
  }

  void _viewOnMap(SavedLocation location) {
    print(
        "Opening location on map: ${location.name} at (${location.latitude}, ${location.longitude})");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          savedLocation: location,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          'Saved Locations',
          style: GoogleFonts.montserrat(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
          : _savedLocations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off,
                        size: 64,
                        color: Theme.of(context).disabledColor,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No saved locations',
                        style: GoogleFonts.montserrat(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your saved locations will appear here',
                        style: GoogleFonts.montserrat(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _savedLocations.length,
                  padding: EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final location = _savedLocations[index];
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.only(bottom: 16),
                      color: Theme.of(context).cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () => _viewOnMap(location),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.place,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      location.name,
                                      style: GoogleFonts.montserrat(
                                        color: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.color,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      location.address,
                                      style: GoogleFonts.montserrat(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteLocation(location.id),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
