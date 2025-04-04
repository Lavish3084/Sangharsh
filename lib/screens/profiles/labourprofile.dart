import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:majdoor/services/labourmodel.dart';
import 'package:majdoor/screens/chat/chatscreen.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:majdoor/providers/booking_provider.dart';
import 'package:majdoor/services/booking.dart';
import 'package:majdoor/screens/bookings.dart';
import 'package:majdoor/services/worker_service.dart';
import 'package:majdoor/providers/wallet_provider.dart';
import 'package:majdoor/screens/wallet.dart';

class ProfileScreen extends StatefulWidget {
  final Labourer labourer;

  const ProfileScreen({Key? key, required this.labourer}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isFavourite = false;
  final WorkerService _workerService = WorkerService();

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final status = await _workerService.isFavourite(widget.labourer.id);
    setState(() {
      _isFavourite = status;
    });
  }

  Future<void> _toggleFavourite() async {
    await _workerService.toggleFavourite(widget.labourer.id);
    setState(() {
      _isFavourite = !_isFavourite;
    });
  }

  void _startCall(BuildContext context) {
    // Show calling dialog with animation
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 50,
                child: widget.labourer.imageUrl.isNotEmpty
                    ? Image.network(
                        widget.labourer.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.error, size: 50);
                        },
                      )
                    : Icon(Icons.person, size: 50),
              ),
              SizedBox(height: 16),
              Text(
                'Calling ${widget.labourer.name}...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCallButton(
                    icon: Icons.volume_up,
                    color: Colors.blue,
                    onTap: () {
                      // Toggle speaker
                      HapticFeedback.mediumImpact();
                    },
                  ),
                  _buildCallButton(
                    icon: Icons.mic_off,
                    color: Colors.blue,
                    onTap: () {
                      // Toggle mute
                      HapticFeedback.mediumImpact();
                    },
                  ),
                  _buildCallButton(
                    icon: Icons.call_end,
                    color: Colors.red,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCallButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.2),
        ),
        child: Icon(
          icon,
          color: color,
          size: 28,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background Image with specific height
          Container(
            height: MediaQuery.of(context).size.height * 0.75,
            child: widget.labourer.imageUrl.isNotEmpty
                ? Image.network(
                    widget.labourer.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Center(
                          child: Icon(Icons.error, size: 100),
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
                          theme.primaryColor.withOpacity(0.7),
                          theme.primaryColor.withOpacity(0.3),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.person,
                        size: 100,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),
          // Back Button and Favorite Button
          Positioned(
            top: 40,
            left: 16,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          // Add favorite button to top right
          Positioned(
            top: 40,
            right: 16,
            child: IconButton(
              icon: Icon(
                _isFavourite ? Icons.favorite : Icons.favorite_border,
                color: _isFavourite ? Colors.red : Colors.white,
                size: 28,
              ),
              onPressed: _toggleFavourite,
            ),
          ),
          // Scrollable Details
          DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            widget.labourer.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: theme.primaryColor,
                              ),
                              SizedBox(width: 4),
                              Text(
                                widget.labourer.location,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 16,
                                  color: theme.textTheme.bodyMedium?.color
                                      ?.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Online now',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 14,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                        _buildInfoCard(context,
                            title: 'Location', value: widget.labourer.location),
                        _buildInfoCard(context,
                            title: 'Reviews',
                            value: '${widget.labourer.rating} ★'),
                        _buildInfoCard(context,
                            title: 'Rate', value: '₹${widget.labourer.Rs}/day'),
                        SizedBox(height: 20),
                        _buildExperienceCard(context, widget.labourer),
                        SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButton(
                              context,
                              icon: Icons.call,
                              label: 'Call',
                              color: Colors.green,
                              onPressed: () => _startCall(context),
                            ),
                            _buildActionButton(
                              context,
                              icon: Icons.chat,
                              label: 'Chat',
                              color: theme.primaryColor,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                      laborerName: widget.labourer.name,
                                      laborerJob: widget.labourer.category,
                                      laborerImageUrl: widget.labourer.imageUrl,
                                      pricePerDay: widget.labourer.Rs,
                                      laborerRating: widget.labourer.rating,
                                    ),
                                  ),
                                );
                              },
                            ),
                            _buildActionButton(
                              context,
                              icon: Icons.calendar_today,
                              label: 'Book',
                              color: Colors.blue,
                              onPressed: () {
                                _processBooking();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onPressed();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceCard(BuildContext context, Labourer labourer) {
    final theme = Theme.of(context);

    return Card(
      color: theme.cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Experience & Skills',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            _buildSkillRow(
                context, 'Experience', '${labourer.experience ?? 3} Years'),
            _buildSkillRow(context, 'Languages', 'Hindi, English'),
            _buildSkillRow(context, 'Availability', 'Weekdays, Weekends'),
            _buildSkillRow(context, 'Specialization',
                labourer.specialization ?? 'General Labor'),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillRow(BuildContext context, String skill, String detail) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text(
            '$skill: ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
          Text(
            detail,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context,
      {required String title, required String value}) {
    final theme = Theme.of(context);

    return Card(
      color: theme.cardColor,
      margin: EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Row(
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                title == 'Location'
                    ? Icons.location_on
                    : title == 'Reviews'
                        ? Icons.star
                        : Icons.monetization_on,
                color: theme.primaryColor,
                size: 18,
              ),
            ),
            SizedBox(width: 12),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processBooking() async {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final bookingPrice = widget.labourer.Rs.toDouble();

    // Check balance first
    if (!walletProvider.hasSufficientBalance(bookingPrice)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Insufficient balance. Please add money to your wallet.'),
          backgroundColor: Colors.red,
        ),
      );
      // Navigate to wallet screen to add money
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => WalletScreen()),
      );
      return;
    }

    // If balance is sufficient, proceed with booking
    final success = await walletProvider.deductBalance(bookingPrice);

    if (success) {
      // Create booking
      final bookingProvider =
          Provider.of<BookingProvider>(context, listen: false);
      await bookingProvider.createBooking(
        workerId: widget.labourer.id,
        workerName: widget.labourer.name,
        price: widget.labourer.Rs,
        // Add other booking details here
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking successful!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to bookings screen or other appropriate screen
    } else {
      // This should not happen if we checked balance first, but just in case
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}