import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:majdoor/screens/profiles/account.dart';
import 'package:majdoor/screens/history.dart';
import 'package:majdoor/screens/auth/loginscreen.dart';
import 'package:majdoor/screens/services.dart';
import 'package:majdoor/screens/wallet.dart';
import 'package:majdoor/widgets/Uihelper.dart';
import 'package:majdoor/services/bottumnavbar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'favourite.dart';
import 'package:latlong2/latlong.dart';
import 'package:majdoor/screens/mapings/mapscreen.dart';
import 'package:geocoding/geocoding.dart';
import 'package:majdoor/screens/mapings/SavedLocations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:majdoor/providers/wallet_provider.dart';
import 'package:majdoor/services/booking.dart';
import 'package:majdoor/providers/booking_provider.dart';
import 'package:majdoor/screens/profiles/labourprofile.dart';
import 'package:majdoor/services/labourmodel.dart';
import 'package:majdoor/services/worker.dart';
import 'package:majdoor/services/worker_service.dart';
import 'package:majdoor/screens/chat/chat_dashboard.dart';
import 'package:majdoor/screens/bookings.dart';
import 'package:majdoor/screens/settings.dart';
import 'package:majdoor/screens/chat/chatscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ServiceProvider {
  final String name;
  final String location;
  final double rating;
  final int pricePerDay;
  final String imageUrl;
  final String category;
  final bool isBookmarked;
  final List<Color> gradient;

  ServiceProvider({
    required this.name,
    required this.location,
    required this.rating,
    required this.pricePerDay,
    required this.imageUrl,
    required this.category,
    this.isBookmarked = false,
    required this.gradient,
  });
}

class Worker {
  final String id;
  final String name;
  final String category;
  final double rating;
  final int pricePerDay;
  final String imageUrl;
  final String location;
  final String? specialization;
  final int? experience;

  Worker({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.pricePerDay,
    required this.imageUrl,
    required this.location,
    this.specialization,
    this.experience,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['_id'],
      name: json['name'],
      category: json['category'],
      rating: json['rating'].toDouble(),
      pricePerDay: json['pricePerDay'],
      imageUrl: json['imageUrl'],
      location: json['location'],
      specialization: json['specialization'],
      experience: json['experience'],
    );
  }
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final WorkerService _workerService = WorkerService();
  List<Worker> _workers = [];
  List<Worker> _featuredWorkers = [];
  bool _isLoading = true;
  List<String> _popularCategories = [];

  // Categories with icons
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Cleaning', 'icon': Icons.cleaning_services},
    {'name': 'Electrician', 'icon': Icons.electrical_services},
    {'name': 'Labourer', 'icon': Icons.construction},
    {'name': 'Carpenter', 'icon': Icons.handyman},
    {'name': 'Painting', 'icon': Icons.format_paint},
    {'name': 'Plumbing', 'icon': Icons.plumbing},
    {'name': 'Repair', 'icon': Icons.build},
  ];

  @override
  void initState() {
    super.initState();
    _clearStoredWorkersData();
    _loadWorkers();
    _loadPopularCategories();
  }

  Future<void> _clearStoredWorkersData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('workers_data');
  }

  Future<void> _loadWorkers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          'https://8402024d-94f3-49d9-a56d-2dc6043a9a34-00-2mher60iizzyr.pike.replit.dev/api/labors'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final workers = data.map((item) => Worker.fromJson(item)).toList();

        // Sort by rating for featured workers
        final featuredWorkers = List<Worker>.from(workers)
          ..sort((a, b) => b.rating.compareTo(a.rating));

        setState(() {
          _workers = workers;
          _featuredWorkers = featuredWorkers.take(5).toList();
          _isLoading = false;
        });
      } else {
        print('Failed to load workers: ${response.body}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading workers: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPopularCategories() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse(
          'https://8402024d-94f3-49d9-a56d-2dc6043a9a34-00-2mher60iizzyr.pike.replit.dev/api/labors'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final workers = data.map((item) => Worker.fromJson(item)).toList();
        // Group workers by category
        final Map<String, List<Worker>> workersByCategory = {};
        for (var worker in workers) {
          if (!workersByCategory.containsKey(worker.category)) {
            workersByCategory[worker.category] = [];
          }
          workersByCategory[worker.category]!.add(worker);
        }

        setState(() {
          _workers = workers;
          _popularCategories = workersByCategory.keys.toList();
          _isLoading = false;
        });
      } else {
        print('Failed to load workers: ${response.body}');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading workers: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final backgroundColor = isDark ? const Color(0xFF121212) : Colors.white;
    final cardColor =
        isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF7F9FC);
    final textColor = isDark ? Colors.white : Colors.black;
    final subtleTextColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Sangharsh',
          style: GoogleFonts.poppins(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: textColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NotificationPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.wallet_outlined, color: textColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WalletScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : RefreshIndicator(
              onRefresh: _loadWorkers,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          readOnly: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ServicesScreen()),
                            );
                          },
                          style: GoogleFonts.poppins(color: textColor),
                          decoration: InputDecoration(
                            hintText: "Search for services...",
                            hintStyle:
                                GoogleFonts.poppins(color: subtleTextColor),
                            prefixIcon: Icon(Icons.search, color: primaryColor),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                          ),
                        ),
                      ),

                      SizedBox(height: 16),

                      // Location Options
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MapScreen()),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal:
                                      MediaQuery.of(context).size.width *
                                          0.02, // Responsive padding
                                ),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.my_location,
                                      color: primaryColor,
                                      size: 18, // Slightly smaller icon
                                    ),
                                    SizedBox(width: 4), // Reduced spacing
                                    Flexible(
                                      // Added Flexible
                                      child: Text(
                                        'Current Location',
                                        style: GoogleFonts.poppins(
                                          color: textColor,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.033, // Responsive font size
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8), // Reduced spacing between buttons
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          SavedLocationsScreen()),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal:
                                      MediaQuery.of(context).size.width *
                                          0.02, // Responsive padding
                                ),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.bookmark_outline,
                                      color: primaryColor,
                                      size: 18, // Slightly smaller icon
                                    ),
                                    SizedBox(width: 4), // Reduced spacing
                                    Flexible(
                                      // Added Flexible
                                      child: Text(
                                        'Saved Locations',
                                        style: GoogleFonts.poppins(
                                          color: textColor,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.033, // Responsive font size
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24),

                      // Categories
                      Text(
                        "Categories",
                        style: GoogleFonts.poppins(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ServicesScreen(
                                      initialCategory: _categories[index]
                                          ['name'],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: 80,
                                margin: EdgeInsets.only(right: 16),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        _categories[index]['icon'],
                                        color: primaryColor,
                                        size: 30,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      _categories[index]['name'],
                                      style: GoogleFonts.poppins(
                                        color: textColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 24),

                      // Featured Workers
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Featured Workers",
                            style: GoogleFonts.poppins(
                              color: textColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ServicesScreen()),
                              );
                            },
                            child: Text(
                              "See All",
                              style: GoogleFonts.poppins(
                                color: primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Container(
                        height: 220,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _featuredWorkers.length,
                          itemBuilder: (context, index) {
                            final worker = _featuredWorkers[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfileScreen(
                                      labourer: Labourer(
                                        id: worker.id,
                                        name: worker.name,
                                        category: worker.category,
                                        rating: worker.rating,
                                        pricePerDay: worker.pricePerDay,
                                        imageUrl: worker.imageUrl,
                                        location: worker.location,
                                        reviews: worker.rating,
                                        Rs: worker.pricePerDay,
                                        specialization:
                                            worker.specialization ?? '',
                                        experience: worker.experience ?? 0,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: 160,
                                margin: EdgeInsets.only(right: 16),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Worker Image
                                    ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                      child: Container(
                                        width: double.infinity,
                                        height: 120,
                                        child: worker.imageUrl.isNotEmpty
                                            ? Image.network(
                                                worker.imageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                        colors: [
                                                          primaryColor
                                                              .withOpacity(0.7),
                                                          primaryColor
                                                              .withOpacity(0.3),
                                                        ],
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: Icon(
                                                        Icons.person,
                                                        size: 40,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              )
                                            : Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      primaryColor
                                                          .withOpacity(0.7),
                                                      primaryColor
                                                          .withOpacity(0.3),
                                                    ],
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Icon(
                                                    Icons.person,
                                                    size: 40,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ),
                                    // Worker Info
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            worker.name,
                                            style: GoogleFonts.poppins(
                                              color: textColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            worker.category,
                                            style: GoogleFonts.poppins(
                                              color: primaryColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            "₹${worker.pricePerDay}/day",
                                            style: GoogleFonts.poppins(
                                              color: subtleTextColor,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 24),

                      // Quick Actions
                      Text(
                        "Quick Actions",
                        style: GoogleFonts.poppins(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildQuickAction(
                            context,
                            icon: Icons.calendar_today,
                            label: "Bookings",
                            color: Colors.blue,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BookingsScreen()),
                              );
                            },
                          ),
                          _buildQuickAction(
                            context,
                            icon: Icons.wallet,
                            label: "Wallet",
                            color: Colors.green,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WalletScreen()),
                              );
                            },
                          ),
                          _buildQuickAction(
                            context,
                            icon: Icons.chat_bubble_outline,
                            label: "Chat",
                            color: Colors.purple,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChatDashboard()),
                              );
                            },
                          ),
                          _buildQuickAction(
                            context,
                            icon: Icons.settings,
                            label: "Settings",
                            color: Colors.orange,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SettingsScreen()),
                              );
                            },
                          ),
                        ],
                      ),

                      SizedBox(height: 24),

                      // Popular Categories Section
                      Text(
                        "Popular Categories",
                        style: GoogleFonts.poppins(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),

                      // Category Tabs
                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _popularCategories.length,
                        itemBuilder: (context, index) {
                          final category = _popularCategories[index];
                          final categoryWorkers = _workers
                              .where((w) => w.category == category)
                              .toList();

                          if (categoryWorkers.isEmpty) return SizedBox.shrink();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      category,
                                      style: GoogleFonts.poppins(
                                        color: textColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ServicesScreen(
                                              initialCategory: category,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        "See All",
                                        style: GoogleFonts.poppins(
                                          color: primaryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 120,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: categoryWorkers.length,
                                  itemBuilder: (context, workerIndex) {
                                    final worker = categoryWorkers[workerIndex];
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ProfileScreen(
                                              labourer: Labourer(
                                                id: worker.id,
                                                name: worker.name,
                                                category: worker.category,
                                                rating: worker.rating,
                                                pricePerDay: worker.pricePerDay,
                                                imageUrl: worker.imageUrl,
                                                location: worker.location,
                                                reviews: worker.rating,
                                                Rs: worker.pricePerDay,
                                                specialization:
                                                    worker.specialization ?? '',
                                                experience:
                                                    worker.experience ?? 0,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 200,
                                        margin: EdgeInsets.only(right: 12),
                                        decoration: BoxDecoration(
                                          color: cardColor,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.05),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.horizontal(
                                                left: Radius.circular(12),
                                              ),
                                              child: Container(
                                                width: 80,
                                                height: 120,
                                                child: worker
                                                        .imageUrl.isNotEmpty
                                                    ? Image.network(
                                                        worker.imageUrl,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context,
                                                            error, stackTrace) {
                                                          return Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              gradient:
                                                                  LinearGradient(
                                                                begin: Alignment
                                                                    .topLeft,
                                                                end: Alignment
                                                                    .bottomRight,
                                                                colors: [
                                                                  primaryColor
                                                                      .withOpacity(
                                                                          0.7),
                                                                  primaryColor
                                                                      .withOpacity(
                                                                          0.3),
                                                                ],
                                                              ),
                                                            ),
                                                            child: Center(
                                                              child: Icon(
                                                                Icons.person,
                                                                size: 30,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      )
                                                    : Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                            colors: [
                                                              primaryColor
                                                                  .withOpacity(
                                                                      0.7),
                                                              primaryColor
                                                                  .withOpacity(
                                                                      0.3),
                                                            ],
                                                          ),
                                                        ),
                                                        child: Center(
                                                          child: Icon(
                                                            Icons.person,
                                                            size: 30,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      worker.name,
                                                      style:
                                                          GoogleFonts.poppins(
                                                        color: textColor,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      worker.category,
                                                      style:
                                                          GoogleFonts.poppins(
                                                        color: primaryColor,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      "₹${worker.pricePerDay}/day",
                                                      style:
                                                          GoogleFonts.poppins(
                                                        color: subtleTextColor,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: BottomNavBarFb2(currentIndex: 0),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class Category {
  final String name;

  Category({required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'],
    );
  }
}

class Labor {
  final String name;
  final String category;

  Labor({required this.name, required this.category});

  factory Labor.fromJson(Map<String, dynamic> json) {
    return Labor(
      name: json['name'],
      category: json['category'],
    );
  }
}
