import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesScreen extends StatelessWidget {
  Future<List<String>> _getFavoriteLabourers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('favoriteLabourers') ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Color(0xFF1E1E1E),
        elevation: 0,
        title: Text(
          'Favorites',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ),
      body: FutureBuilder<List<String>>(
        future: _getFavoriteLabourers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            List<String> favoriteLabourers = snapshot.data!;
            return ListView.builder(
              itemCount: favoriteLabourers.length,
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text(
                    favoriteLabourers[index],
                    style: GoogleFonts.roboto(color: Colors.white),
                  ),
                  tileColor: Color(0xFF1E1E1E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  trailing: Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                );
              },
            );
          } else {
            return Center(
              child: Text(
                'No Favorites Yet',
                style: GoogleFonts.roboto(color: Colors.white),
              ),
            );
          }
        },
      ),
    );
  }
}
