import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
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

  @override
  void initState() {
    super.initState();
    _loadSavedLocations();
  }

  Future<void> _loadSavedLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocationsJson = prefs.getStringList('saved_locations') ?? [];

    setState(() {
      _savedLocations = savedLocationsJson
          .map((json) => SavedLocation.fromMap(jsonDecode(json)))
          .toList();
    });
  }

  Future<void> _deleteLocation(String id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedLocations.removeWhere((location) => location.id == id);
    });

    final updatedLocationsJson = _savedLocations
        .map((location) => jsonEncode(location.toMap()))
        .toList();
    await prefs.setStringList('saved_locations', updatedLocationsJson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'Saved Locations',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
      ),
      body: _savedLocations.isEmpty
          ? Center(
              child: Text(
                'No saved locations yet',
                style: GoogleFonts.roboto(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontSize: 16,
                ),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _savedLocations.length,
              itemBuilder: (context, index) {
                final location = _savedLocations[index];
                return Card(
                  color: Theme.of(context).cardColor,
                  margin: EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: () {
                      final position =
                          LatLng(location.latitude, location.longitude);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapScreen(
                            initialPosition: position,
                          ),
                        ),
                      );
                    },
                    title: Text(
                      location.name,
                      style: GoogleFonts.roboto(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      location.address,
                      style: GoogleFonts.roboto(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      onPressed: () => _deleteLocation(location.id),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
