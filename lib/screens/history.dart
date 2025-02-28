import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:majdoor/services/bottumnavbar.dart';
import 'package:provider/provider.dart';
import 'package:majdoor/providers/booking_provider.dart';
import 'package:majdoor/services/booking.dart';
import 'package:majdoor/providers/wallet_provider.dart'; // Import WalletProvider
import 'package:majdoor/screens/dashboard.dart'; //Import Dashboard Screen

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access the BookingProvider
    final bookingProvider = Provider.of<BookingProvider>(context);
    final bookings = bookingProvider.bookings;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'Booking History',
          style: GoogleFonts.poppins(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),),
      body: bookings.isEmpty
          ? Center(
              child: Text(
                'No bookings yet.',
                style: GoogleFonts.poppins(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                return _buildBookingCard(context, bookings[index]);
              },
            ),
    
    
      bottomNavigationBar: BottomNavBarFb2(currentIndex: 2),
      );
  }

  Widget _buildBookingCard(BuildContext context, Booking booking) {
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Icon(
                            Icons.person,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.workerName,
                              style: GoogleFonts.poppins(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              booking.workerType,
                              style: GoogleFonts.poppins(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7E57C2).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '₹${booking.price.toStringAsFixed(0)}/day',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF7E57C2),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Last booked: ${DateFormat('dd MMM yyyy').format(booking.bookingDate)}',
                          style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    /*Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFFFC107),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '4.8',
                          style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),*/
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Color(0xFF3D3D3D),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      _rebookLabourer(context, booking);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF7E57C2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 20,
                    ),
                    label: Text(
                      'Book Again',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8), // Add some space between buttons
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      // Show a confirmation dialog before removing
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Remove Booking'),
                          content: const Text(
                              'Are you sure you want to remove this booking?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Remove the booking
                                bookingProvider.removeBooking(booking.id);
                                Navigator.pop(context); // Close the dialog
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Booking removed.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              },
                              child: const Text('Remove'),
                            ),
                          ],
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 20,
                    ),
                    label: Text(
                      'Remove',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _rebookLabourer(BuildContext context, Booking booking) {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    final labourerPrice = booking.price; // Get the price from the booking

    if (walletProvider.canAfford(labourerPrice)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text(
            'Confirm Rebooking',
            style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color),
          ),
          content: Text(
            'Do you want to rebook ${booking.workerName} for ₹$labourerPrice?',
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await walletProvider.deductBalance(labourerPrice);
                if (success) {
                  Navigator.pop(context);

                  // Create a new Booking object
                  final newBooking = Booking(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    workerName: booking.workerName,
                    workerType: booking.workerType,
                    price: labourerPrice,
                    bookingDate: DateTime.now(),
                    status: 'confirmed',
                  );

                  // Add the booking to the provider
                  bookingProvider.addBooking(newBooking);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Rebooking confirmed! ₹$labourerPrice deducted from wallet'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                   Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Insufficient Balance!'),
                      backgroundColor: Colors.red,
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
       Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Insufficient balance. Please add funds to your wallet.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
