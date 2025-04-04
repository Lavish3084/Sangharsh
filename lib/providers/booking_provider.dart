import 'package:flutter/material.dart';
import 'package:majdoor/services/booking.dart'; // Assuming you have a Booking model
import 'package:flutter/foundation.dart';

class BookingProvider with ChangeNotifier {
  List<Booking> _bookings = [];

  List<Booking> get bookings => [..._bookings];

  BookingProvider() {
    _bookings = []; // Initialize with an empty list
  }

  void addBooking(Booking booking) {
    _bookings.add(booking);
    notifyListeners(); // Important:  Notify listeners that the data has changed
  }

  //Optional functions to update or delete any booking
  void updateBooking(Booking updatedBooking) {
    final index =
        _bookings.indexWhere((booking) => booking.id == updatedBooking.id);
    if (index != -1) {
      _bookings[index] = updatedBooking =
          updatedBooking.copyWith(status: updatedBooking.status);
      notifyListeners();
    }
  }

  void deleteBooking(String bookingId) {
    _bookings.removeWhere((booking) => booking.id == bookingId);
    notifyListeners();
  }

  //Method to check is already booked.
  bool isLabourerBooked(String workerName) {
    return _bookings.any((booking) =>
        booking.workerName == workerName &&
        (booking.status == 'confirmed' || booking.status == 'ongoing'));
  }

  // Method to remove a booking
  void removeBooking(String id) {
    _bookings.removeWhere((booking) => booking.id == id);
    notifyListeners();
  }

  // Optional: Add method to update booking status
  void updateBookingStatus(String id, String newStatus) {
    final bookingIndex = _bookings.indexWhere((booking) => booking.id == id);
    if (bookingIndex >= 0) {
      final updatedBooking = Booking(
        id: _bookings[bookingIndex].id,
        workerName: _bookings[bookingIndex].workerName,
        workerType: _bookings[bookingIndex].workerType,
        bookingDate: _bookings[bookingIndex].bookingDate,
        price: _bookings[bookingIndex].price,
        status: newStatus,
      );
      _bookings[bookingIndex] = updatedBooking;
      notifyListeners();
    }
  }

  Future<bool> createBooking({
    required String workerId,
    required String workerName,
    required int price,
    // Other parameters
  }) async {
    try {
      // Create the booking in your database
      // ...

      // After successful creation, force refresh the bookings list
      await fetchBookings();

      // Notify listeners about the change
      notifyListeners();

      return true;
    } catch (e) {
      print('Error creating booking: $e');
      return false;
    }
  }

  // Add this method to fetch bookings
  Future<void> fetchBookings() async {
    try {
      // Here you would typically fetch bookings from your database
      // For now, we'll just leave the current bookings as is
      // If you have a database service, you can replace this with actual fetching logic

      // Example with a database service:
      // final bookingsData = await _bookingService.getBookings();
      // _bookings = bookingsData;

      notifyListeners();
    } catch (e) {
      print('Error fetching bookings: $e');
    }
  }
}
