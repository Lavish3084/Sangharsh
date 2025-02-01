import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Service {
  final String name;
  final String location;
  final double rating;
  final int pricePerDay;
  final String imageUrl;
  final String category;
  final bool isBookmarked;

  Service({
    required this.name,
    required this.location,
    required this.rating,
    required this.pricePerDay,
    required this.imageUrl,
    required this.category,
    this.isBookmarked = false,
  });
}

class ServicesScreen extends StatefulWidget {
  final String? initialCategory;

  ServicesScreen({this.initialCategory});

  @override
  _ServicesScreenState createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  String selectedCategory = 'All';
  TextEditingController searchController = TextEditingController();

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
  }

  // Dummy data
  final List<Service> services = [
    Service(
      name: 'Himanshu',
      location: 'Bihar, India',
      rating: 4.5,
      pricePerDay: 500,
      imageUrl: 'assets/worker1.jpg',
      category: 'Labourer',
    ),
    Service(
      name: 'Rajesh Kumar',
      location: 'Delhi, India',
      rating: 4.7,
      pricePerDay: 600,
      imageUrl: 'assets/worker2.jpg',
      category: 'Electrician',
    ),
    Service(
      name: 'Rajesh Kumar',
      location: 'Delhi, India',
      rating: 4.7,
      pricePerDay: 600,
      imageUrl: 'assets/worker2.jpg',
      category: 'Electrician',
    ),
    Service(
      name: 'Sanm',
      location: 'Delhi, India',
      rating: 4.7,
      pricePerDay: 600,
      imageUrl: 'assets/worker2.jpg',
      category: 'Plumbing',
    ),
    Service(
      name: 'Rajesh Kumar',
      location: 'Delhi, India',
      rating: 4.7,
      pricePerDay: 600,
      imageUrl: 'assets/worker2.jpg',
      category: 'Electrician',
    ),
    Service(
      name: 'Chulla',
      location: 'Delhi, India',
      rating: 4.7,
      pricePerDay: 600,
      imageUrl: 'assets/worker2.jpg',
      category: 'Labourer',
    ),
    Service(
      name: 'Rajesh ',
      location: 'Delhi, India',
      rating: 4.7,
      pricePerDay: 600,
      imageUrl: 'assets/worker2.jpg',
      category: 'Cleaning',
    ),
    Service(
      name: 'Mahesh',
      location: 'Delhi, India',
      rating: 4.7,
      pricePerDay: 600,
      imageUrl: 'assets/worker2.jpg',
      category: 'Carpenter',
    ),
    Service(
      name: 'Rajesh Kumar',
      location: 'Delhi, India',
      rating: 4.7,
      pricePerDay: 600,
      imageUrl: 'assets/worker2.jpg',
      category: 'Repair',
    ),
    // Add more services as needed
  ];

  List<Service> get filteredServices {
    return services.where((service) {
      final matchesCategory =
          selectedCategory == 'All' || service.category == selectedCategory;
      final matchesSearch = searchController.text.isEmpty ||
          service.name
              .toLowerCase()
              .contains(searchController.text.toLowerCase()) ||
          service.location
              .toLowerCase()
              .contains(searchController.text.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Color(0xFF1E1E1E),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Services',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Color(0xFF8A4FFF)),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              style: GoogleFonts.roboto(color: Colors.white),
              decoration: InputDecoration(
                fillColor: Color.fromARGB(255, 255, 255, 255),
                filled: true,
                hintText: 'Search services...',
                hintStyle: GoogleFonts.roboto(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Color(0xFF8A4FFF)),
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? Color(0xFF8A4FFF) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Color(0xFF8A4FFF) : Colors.grey,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        category,
                        style: GoogleFonts.roboto(
                          color: isSelected ? Colors.white : Colors.grey,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
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
              itemCount: filteredServices.length,
              itemBuilder: (context, index) {
                final service = filteredServices[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.all(16),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundColor: Color(0xFF8A4FFF),
                          backgroundImage: AssetImage(service.imageUrl),
                        ),
                        title: Text(
                          service.name,
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text(
                              'Location: ${service.location}',
                              style: GoogleFonts.roboto(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  service.rating.toString(),
                                  style:
                                      GoogleFonts.roboto(color: Colors.amber),
                                ),
                                SizedBox(width: 16),
                                Icon(Icons.currency_rupee,
                                    color: Colors.white70, size: 16),
                                Text(
                                  '${service.pricePerDay} Rupees/Day',
                                  style:
                                      GoogleFonts.roboto(color: Colors.white70),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            service.isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: Color(0xFF8A4FFF),
                          ),
                          onPressed: () {
                            setState(() {
                              final index = services.indexOf(service);
                              services[index] = Service(
                                name: service.name,
                                location: service.location,
                                rating: service.rating,
                                pricePerDay: service.pricePerDay,
                                imageUrl: service.imageUrl,
                                category: service.category,
                                isBookmarked: !service.isBookmarked,
                              );
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Implement booking functionality
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF8A4FFF),
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Book Now',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
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
