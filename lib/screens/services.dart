import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:majdoor/services/worker.dart';
import 'package:majdoor/services/worker_service.dart';
import 'package:majdoor/screens/profiles/labourprofile.dart';
import 'package:majdoor/services/labourmodel.dart';
import 'package:provider/provider.dart';
import 'package:majdoor/providers/booking_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ServicesScreen extends StatefulWidget {
  final String? initialCategory;

  ServicesScreen({this.initialCategory});

  @override
  _ServicesScreenState createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  String selectedCategory = 'All';
  String selectedSort = 'Rating'; // Default sorting option
  TextEditingController searchController = TextEditingController();
  List<Worker> _workers = [];
  bool _isLoading = true;

  final List<String> categories = [
    'All',
    'Cleaning',
    'Electrician',
    'Labour',
    'Carpenter',
    'Painting',
    'Plumbing',
    'Repair'
  ];

  final List<String> sortingOptions = [
    'Rating',
    'Price',
  ];

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.initialCategory ?? 'All';
    _loadWorkers();
  }

  Future<void> _loadWorkers() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('https://sangharsh-backend.onrender.com/api/labors'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> workersJson = json.decode(response.body);
        _workers = workersJson.map((json) => Worker.fromJson(json)).toList();
      } else {
        print('Error loading workers: ${response.body}');
      }
    } catch (e) {
      print('Error loading workers: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Worker> get filteredWorkers {
    return _workers.where((worker) {
      final matchesCategory =
          selectedCategory == 'All' || worker.category == selectedCategory;
      final matchesSearch = searchController.text.isEmpty ||
          worker.name
              .toLowerCase()
              .contains(searchController.text.toLowerCase()) ||
          worker.location
              .toLowerCase()
              .contains(searchController.text.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<Worker> get sortedWorkers {
    List<Worker> workers = filteredWorkers;
    if (selectedSort == 'Rating') {
      workers.sort(
          (a, b) => b.rating.compareTo(a.rating)); // Sort by rating descending
    } else if (selectedSort == 'Price') {
      workers.sort((a, b) =>
          a.pricePerDay.compareTo(b.pricePerDay)); // Sort by price ascending
    }
    return workers;
  }

  Widget _buildWorkerCard(Worker worker) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).primaryColor,
              backgroundImage: worker.imageUrl.isNotEmpty
                  ? NetworkImage(worker.imageUrl)
                  : null,
            ),
            title: Text(
              worker.name,
              style: GoogleFonts.montserrat(
                color: Theme.of(context).textTheme.titleLarge?.color,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text(
                  'Location: ${worker.location}',
                  style: GoogleFonts.roboto(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    SizedBox(width: 4),
                    Text(
                      worker.rating.toString(),
                      style: GoogleFonts.roboto(color: Colors.amber),
                    ),
                    SizedBox(width: 16),
                    Icon(Icons.currency_rupee,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        size: 16),
                    Flexible(
                      child: Text(
                        '${worker.pricePerDay} Rupees/Day',
                        style: GoogleFonts.roboto(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                worker.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () async {
                // Implement bookmark toggle functionality
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
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
                          reviews: 0, // Assuming you want to pass an empty list
                          Rs: worker.pricePerDay,
                          specialization: worker.specialization ?? '',
                          experience: worker.experience ?? 0,
                        ),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Book Now',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
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
        title: Text(
          'Services',
          style:
              GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dropdown for category selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: DropdownButton<String>(
                          value: selectedCategory,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedCategory = newValue!;
                            });
                          },
                          isExpanded: true,
                          items: categories
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          underline: Container(
                            height: 2,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: DropdownButton<String>(
                          value: selectedSort,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedSort = newValue!;
                            });
                          },
                          isExpanded: true,
                          items: sortingOptions
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          underline: Container(
                            height: 2,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Search bar
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search services...',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: sortedWorkers.length,
                      itemBuilder: (context, index) {
                        final worker = sortedWorkers[index];
                        return _buildWorkerCard(worker);
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
