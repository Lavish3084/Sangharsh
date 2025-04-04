import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:majdoor/services/worker.dart';
import 'package:majdoor/services/worker_service.dart';
import 'package:majdoor/screens/profiles/labourprofile.dart';
import 'package:majdoor/services/labourmodel.dart';
import 'package:provider/provider.dart';
import 'package:majdoor/providers/booking_provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class FavouriteScreen extends StatefulWidget {
  @override
  _FavouriteScreenState createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  final WorkerService _workerService = WorkerService();
  List<Worker> _favouriteWorkers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavouriteWorkers();
  }

  Future<void> _loadFavouriteWorkers() async {
    setState(() => _isLoading = true);
    try {
      final workers = await _workerService.getFavouriteWorkers();
      setState(() {
        _favouriteWorkers = workers;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading favourite workers: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Favourite Workers',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(1.0, 1.0),
                      blurRadius: 3.0,
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/favourite_bg.jpg', // Add a background image
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _favouriteWorkers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 40),
                            Icon(
                              Icons.favorite_border,
                              size: 80,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No favourite workers yet',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.all(16),
                        child: StaggeredGrid.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          children: _favouriteWorkers.map((worker) {
                            return _buildWorkerCard(worker);
                          }).toList(),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkerCard(Worker worker) {
    final bookingProvider = Provider.of<BookingProvider>(context, listen: true);
    final isBooked = bookingProvider.bookings.any((booking) =>
        booking.workerName == worker.name &&
        (booking.status == 'pending' || booking.status == 'confirmed'));

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
                specialization: worker.specialization ?? '',
                experience: worker.experience ?? 0,
              ),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.asset(
                    worker.imageUrl,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: Icon(
                      Icons.favorite,
                      color: Colors.red,
                    ),
                    onPressed: () async {
                      await _workerService.toggleFavourite(worker.id);
                      _loadFavouriteWorkers();
                    },
                  ),
                ),
                if (isBooked)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Booked',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    worker.name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    worker.category,
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      SizedBox(width: 4),
                      Text(
                        worker.rating.toString(),
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      Spacer(),
                      Text(
                        '₹${worker.pricePerDay}/day',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
