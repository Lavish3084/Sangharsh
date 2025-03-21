import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:majdoor/services/worker.dart';
import 'package:majdoor/services/worker_service.dart';
import 'package:majdoor/screens/profiles/labourprofile.dart';
import 'package:majdoor/services/labourmodel.dart';

class ServicesScreen extends StatefulWidget {
  final String? initialCategory;

  ServicesScreen({this.initialCategory});

  @override
  _ServicesScreenState createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  String selectedCategory = 'All';
  TextEditingController searchController = TextEditingController();
  final WorkerService _workerService = WorkerService();
  List<Worker> _workers = [];
  bool _isLoading = true;

  final List<String> categories = [
    'All',
    'Cleaning',
    'Electrician',
    'Labourer',
    'Carpenter',
    'Painting',
    'Plumbing',
    'Repair'
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
      final workers = await _workerService.getWorkers();
      setState(() {
        _workers = workers;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading workers: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Services',
          style: GoogleFonts.montserrat(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Theme.of(context).primaryColor),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: searchController,
                    style: GoogleFonts.roboto(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    decoration: InputDecoration(
                      fillColor: Theme.of(context).cardColor,
                      filled: true,
                      hintText: 'Search services...',
                      hintStyle: GoogleFonts.roboto(
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.5),
                      ),
                      prefixIcon: Icon(Icons.search,
                          color: Theme.of(context).primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((category) {
                      bool isSelected = selectedCategory == category;
                      return Padding(
                        padding: EdgeInsets.only(
                          left: category == categories.first ? 16 : 8,
                          right: category == categories.last ? 16 : 8,
                        ),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              selectedCategory = category;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).dividerColor,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              category,
                              style: GoogleFonts.roboto(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Service List
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: filteredWorkers.length,
                    itemBuilder: (context, index) {
                      final worker = filteredWorkers[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.all(16),
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundColor: Theme.of(context).primaryColor,
                                backgroundImage: AssetImage(worker.imageUrl),
                                onBackgroundImageError: (e, s) {
                                  print(
                                      'Error loading image: ${worker.imageUrl}');
                                },
                              ),
                              title: Text(
                                worker.name,
                                style: GoogleFonts.montserrat(
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.color,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4),
                                  Text(
                                    'Location: ${worker.location}',
                                    style: GoogleFonts.roboto(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.star,
                                          color: Colors.amber, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        worker.rating.toString(),
                                        style: GoogleFonts.roboto(
                                            color: Colors.amber),
                                      ),
                                      SizedBox(width: 16),
                                      Icon(Icons.currency_rupee,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.color,
                                          size: 16),
                                      Text(
                                        '${worker.pricePerDay} Rupees/Day',
                                        style: GoogleFonts.roboto(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  worker.isBookmarked
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  color: Theme.of(context).primaryColor,
                                ),
                                onPressed: () async {
                                  await _workerService
                                      .toggleBookmark(worker.id);
                                  setState(() {});
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
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    foregroundColor:
                                        Theme.of(context).colorScheme.onPrimary,
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
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
