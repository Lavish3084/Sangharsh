import 'package:flutter/material.dart';
import 'package:majdoor/services/booking.dart'; // Assuming you have a Booking model

class BookingProvider extends ChangeNotifier {
  List<Booking> _bookings = [];

  List<Booking> get bookings => _bookings;

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
  void removeBooking(String bookingId) {
    _bookings.removeWhere((booking) => booking.id == bookingId);
    notifyListeners();
  }
}
