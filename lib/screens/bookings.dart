import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';
import 'package:majdoor/services/booking.dart';
import 'package:majdoor/services/bottumnavbar.dart';

class BookingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final bookings = bookingProvider.bookings;

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Bookings', style: GoogleFonts.montserrat()),
      ),
      body: bookings.isEmpty
          ? Center(
              child: Text('No bookings yet!',
                  style: GoogleFonts.montserrat(fontSize: 16)),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return Dismissible(
                  key: Key(booking.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.redAccent,
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    final removedBooking = bookings[index];
                    bookingProvider.removeBooking(booking.id);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Booking removed'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            bookingProvider.addBooking(removedBooking);
                          },
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 0,
                    color: Theme.of(context).cardColor,
                    margin: EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  booking.workerName,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(booking.status)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  booking.status.capitalize(),
                                  style: GoogleFonts.montserrat(
                                    color: _getStatusColor(booking.status),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            booking.workerType,
                            style: GoogleFonts.montserrat(fontSize: 14),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Booking Date',
                                      style: TextStyle(fontSize: 12)),
                                  SizedBox(height: 4),
                                  Text(
                                    DateFormat('MMM dd, yyyy')
                                        .format(booking.bookingDate),
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Amount Paid',
                                      style: TextStyle(fontSize: 12)),
                                  SizedBox(height: 4),
                                  Text(
                                    '₹${booking.price.toStringAsFixed(2)}',
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
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
         //   bottomNavigationBar: BottomNavBarFb2(currentIndex: 1),
    );
  }
}

Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'completed':
      return Colors.green;
    case 'pending':
      return Colors.orange;
    case 'canceled':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

extension StringExtension on String {
  String capitalize() {
    return this.isNotEmpty ? '${this[0].toUpperCase()}${this.substring(1)}' : '';
  }
}
