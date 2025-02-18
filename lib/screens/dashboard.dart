import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:majdoor/screens/account.dart';
import 'package:majdoor/screens/history.dart';
import 'package:majdoor/screens/loginscreen.dart';
import 'package:majdoor/screens/services.dart';
import 'package:majdoor/screens/wallet.dart';
import 'package:majdoor/widgets/Uihelper.dart';
import 'package:majdoor/services/bottumnavbar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:majdoor/screens/mapscreen.dart';
import 'package:geocoding/geocoding.dart';
import 'savedlocations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:majdoor/services/wallet_provider.dart';
import 'package:majdoor/services/booking.dart';
import 'package:majdoor/services/booking_provider.dart';

class Labourer {
  final String name;
  final String location;
  final double reviews;
  final int Rs;
  final String photo;

  Labourer(this.name, this.location, this.reviews, this.Rs, this.photo);
}

class DashboardScreen extends StatelessWidget {
  final List<Labourer> labourers = [
    Labourer('Himanshu', 'Bihar, India', 4.5, 10000, 'himanshu.png'),
    Labourer('Shaurya', 'Mumbai, India', 4.7, 600, 'shaurya.png'),
    Labourer('Lavish', 'Hyderabad, India', 4.9, 700, 'lavish.png'),
    Labourer('Prateek', 'Chennai, India', 4.6, 550, 'prateek.png'),
    Labourer('Vatan', 'Kolkata, India', 4.8, 620, 'vatan.png'),
  ];

  DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Sangharsh',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.account_balance_wallet,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/wallet');
            },
          ),
          IconButton(
            icon: Icon(
              Icons.logout,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  style: GoogleFonts.roboto(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search for Locations',
                    hintStyle: GoogleFonts.roboto(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).primaryColor,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.schedule,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: () {},
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  ),
                ),
              ),
            ),
            _buildSectionTitle(context, 'Quick Access'),
            _buildLocationTiles(context),
            _buildSectionTitle(context, 'Services'),
            _buildServiceIcons(context),
            _buildPromoCard(context),
            _buildSectionTitle(context, 'Top Rated Labourers'),
            _buildLabourersList(context),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          color: Theme.of(context).textTheme.titleLarge?.color,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLocationTiles(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          FutureBuilder<Map<String, String>?>(
            future: _getCurrentLocationWithAddress(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLocationTile(
                    context, 'Getting location...', 'Please wait');
              }

              if (snapshot.hasError) {
                return _buildLocationTile(
                    context, 'Location Error', 'Enable location services');
              }

              final locationData = snapshot.data;
              if (locationData != null) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapScreen(
                          initialPosition: LatLng(
                            double.parse(locationData['latitude']!),
                            double.parse(locationData['longitude']!),
                          ),
                        ),
                      ),
                    );
                  },
                  child: _buildLocationTile(
                    context,
                    'Your Current Location',
                    locationData['address']!,
                  ),
                );
              }

              return _buildLocationTile(
                  context, 'Location Unavailable', 'Try again later');
            },
          ),
          SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SavedLocationsScreen(),
                ),
              );
            },
            child: _buildLocationTile(
                context, 'Saved Locations', 'View your saved places'),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationTile(
      BuildContext context, String title, String subtitle) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        title: Text(
          title,
          style: GoogleFonts.roboto(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.roboto(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildServiceIcons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ServiceIcon(
                icon: Icons.handyman,
                label: 'Carpenter',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ServicesScreen(initialCategory: 'Carpenter'),
                  ),
                ),
              ),
              ServiceIcon(
                icon: Icons.construction,
                label: 'Labourer',
                promo: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ServicesScreen(initialCategory: 'Labourer'),
                  ),
                ),
              ),
              ServiceIcon(
                icon: Icons.electrical_services,
                label: 'Electrician',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ServicesScreen(initialCategory: 'Electrician'),
                  ),
                ),
              ),
              ServiceIcon(
                icon: Icons.plumbing,
                label: 'Plumber',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ServicesScreen(initialCategory: 'Plumbing'),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ServiceIcon(
                icon: Icons.cleaning_services,
                label: 'Cleaning',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ServicesScreen(initialCategory: 'Cleaning'),
                  ),
                ),
              ),
              ServiceIcon(
                icon: Icons.home_repair_service,
                label: 'Repair',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ServicesScreen(initialCategory: 'Repair'),
                  ),
                ),
              ),
              ServiceIcon(
                icon: Icons.person,
                label: 'Painting',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ServicesScreen(initialCategory: 'Painting'),
                  ),
                ),
              ),
              ServiceIcon(
                icon: Icons.more_horiz,
                label: 'More',
                onTap: () => Navigator.pushNamed(context, '/services'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommended',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                GestureDetector(
                  onTap: () => _launchTermsAndConditions(context),
                  child: Text(
                    'Terms & Conditions Apply',
                    style: GoogleFonts.roboto(
                      color: Colors.white70,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            Icon(Icons.discount, color: Colors.white, size: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLabourersList(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: labourers.length,
      itemBuilder: (context, index) {
        final labourer = labourers[index];
        final isBooked = bookingProvider.isLabourerBooked(labourer.name);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Theme.of(context).primaryColor, width: 2),
                        ),
                        child: ClipOval(
                          child: UiHelper.customimage(
                            imagepath: labourers[index].photo,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              labourer.name,
                              style: GoogleFonts.montserrat(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Location: ${labourer.location}',
                              style: GoogleFonts.roboto(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color,
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  '${labourer.reviews}',
                                  style:
                                      GoogleFonts.roboto(color: Colors.amber),
                                ),
                                SizedBox(width: 16),
                                Icon(Icons.credit_card,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                    size: 16),
                                SizedBox(width: 4),
                                Text(
                                  '${labourer.Rs} Rupees/Day',
                                  style: GoogleFonts.roboto(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isBooked
                          ? null // Disable the button if the labourer is booked
                          : () {
                              final walletProvider =
                                  Provider.of<WalletProvider>(context,
                                      listen: false);
                              final bookingProvider =
                                  Provider.of<BookingProvider>(context,
                                      listen: false); // Get the BookingProvider
                              final labourerPrice = labourers[index].Rs.toDouble();

                              if (walletProvider.canAfford(labourerPrice)) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: Theme.of(context).cardColor,
                                    title: Text(
                                      'Confirm Booking',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.color),
                                    ),
                                    content: Text(
                                      'Do you want to book this service for ₹$labourerPrice?',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.color),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          final success = await walletProvider
                                              .deductBalance(labourerPrice);
                                          if (success) {
                                            Navigator.pop(context);

                                            // Create a new Booking object
                                            final newBooking = Booking(
                                              id: DateTime.now()
                                                  .millisecondsSinceEpoch
                                                  .toString(), // Generate a unique ID
                                              workerName: labourers[index].name,
                                              workerType: 'Labourer', // Replace with the actual service type
                                              price: labourerPrice,
                                              bookingDate: DateTime.now(),
                                              status: 'confirmed', // Or 'upcoming', depending on your logic
                                            );

                                            // Add the booking to the provider
                                            bookingProvider.addBooking(newBooking);

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Booking confirmed! ₹$labourerPrice deducted from wallet'),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          }
                                        },
                                        child: Text('Confirm'),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: Theme.of(context).cardColor,
                                    title: Text(
                                      'Insufficient Balance',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.color),
                                    ),
                                    content: Text(
                                      'Please add money to your wallet to book this service.',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.color),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          Navigator.pushNamed(context, '/wallet');
                                        },
                                        child: Text('Add Money'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                      style: TextButton.styleFrom(
                        backgroundColor: isBooked
                            ? Colors.grey // Change button color when disabled
                            : Theme.of(context).primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        isBooked ? 'Already Booked' : 'Book Now', // Change button text
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavBarFb2(currentIndex: 0);
  }

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print("Error getting location: $e");
      return null;
    }
  }

  Future<Map<String, String>?> _getCurrentLocationWithAddress() async {
    try {
      Position? position = await _getCurrentLocation();
      if (position == null) {
        throw Exception('Could not get location');
      }

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '${place.locality}, ${place.administrativeArea}';
        return {
          'latitude': position.latitude.toString(),
          'longitude': position.longitude.toString(),
          'address': address,
        };
      }
      return null;
    } catch (e) {
      print("Error getting location with address: $e");
      return null;
    }
  }

  Future<void> _launchTermsAndConditions(BuildContext context) async {
    final Uri url =
        Uri.parse('https://youtube.com'); // Replace with your actual URL
    try {
      if (!await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      )) {
        throw Exception('Could not launch Terms & Conditions');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open Terms & Conditions'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

class ServiceIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool promo;
  final VoidCallback onTap;

  ServiceIcon({
    required this.icon,
    required this.label,
    this.promo = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.all(12),
                  child: Icon(icon,
                      size: 40, color: Theme.of(context).primaryColor),
                ),
                if (promo)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(15),
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      child: Text(
                        'Recommended',
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.roboto(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 12,
              ),
            ),
          ],
        ));
  }
}
