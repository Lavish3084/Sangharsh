class Booking {
  final String id;
  final String workerName;
  final String workerType;
  final double price;
  final DateTime bookingDate;
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'

  Booking({
    required this.id,
    required this.workerName,
    required this.workerType,
    required this.price,
    required this.bookingDate,
    required this.status,
  });

   Booking copyWith({
    String? id,
    String? workerName,
    String? workerType,
    double? price,
    DateTime? bookingDate,
    String? status,
  }) {
    return Booking(
      id: id ?? this.id,
      workerName: workerName ?? this.workerName,
      workerType: workerType ?? this.workerType,
      price: price ?? this.price,
      bookingDate: bookingDate ?? this.bookingDate,
      status: status ?? this.status,
    );
  }

}
