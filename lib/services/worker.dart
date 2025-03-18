import 'package:majdoor/services/labourmodel.dart';

class Worker {
  final String id;
  final String name;
  final String location;
  final double rating;
  final int pricePerDay;
  final String imageUrl;
  final String category;
  final String? specialization;
  final int? experience;
  final bool isBookmarked;

  // Chat-related fields
  final String? lastMessage;
  final String? lastMessageTime;
  final int unreadCount;
  final bool isOnline;

  Worker({
    required this.id,
    required this.name,
    required this.location,
    required this.rating,
    required this.pricePerDay,
    required this.imageUrl,
    required this.category,
    this.specialization,
    this.experience,
    this.isBookmarked = false,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
  });

  // Create a copy of this Worker with some fields updated
  Worker copyWith({
    String? id,
    String? name,
    String? location,
    double? rating,
    int? pricePerDay,
    String? imageUrl,
    String? category,
    String? specialization,
    int? experience,
    bool? isBookmarked,
    String? lastMessage,
    String? lastMessageTime,
    int? unreadCount,
    bool? isOnline,
  }) {
    return Worker(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      specialization: specialization ?? this.specialization,
      experience: experience ?? this.experience,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  // Factory constructor to create a Worker from a Map (e.g., from JSON)
  factory Worker.fromMap(Map<String, dynamic> map) {
    return Worker(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      pricePerDay: map['pricePerDay'] ?? 0,
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      specialization: map['specialization'],
      experience: map['experience'],
      isBookmarked: map['isBookmarked'] ?? false,
      lastMessage: map['lastMessage'],
      lastMessageTime: map['lastMessageTime'],
      unreadCount: map['unreadCount'] ?? 0,
      isOnline: map['isOnline'] ?? false,
    );
  }

  // Convert Worker to a Map (e.g., for JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'rating': rating,
      'pricePerDay': pricePerDay,
      'imageUrl': imageUrl,
      'category': category,
      'specialization': specialization,
      'experience': experience,
      'isBookmarked': isBookmarked,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'unreadCount': unreadCount,
      'isOnline': isOnline,
    };
  }

  // Add this method to convert Worker to Labourer
  Labourer toLabourer() {
    return Labourer(
      id: id,
      name: name,
      location: location,
      rating: rating,
      pricePerDay: pricePerDay,
      imageUrl: imageUrl,
      category: category,
      specialization: specialization ?? '',
      experience: experience ?? 0,
      reviews: rating,
      Rs: pricePerDay,
      isBookmarked: isBookmarked,
    );
  }
}
