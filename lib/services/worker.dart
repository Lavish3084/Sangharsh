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
  bool isFavourite;

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
    this.isFavourite = false,
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
    bool? isFavourite,
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
      isFavourite: isFavourite ?? this.isFavourite,
    );
  }

  // Factory constructor to create a Worker from a JSON object
  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['_id'] ?? '', // Ensure this matches your API's ID field
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      pricePerDay: json['pricePerDay'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? '',
      specialization: json['specialization'],
      experience: json['experience'],
      isBookmarked: json['isBookmarked'] ?? false,
      lastMessage: json['lastMessage'],
      lastMessageTime: json['lastMessageTime'],
      unreadCount: json['unreadCount'] ?? 0,
      isOnline: json['isOnline'] ?? false,
      isFavourite: json['isFavourite'] ?? false,
    );
  }

  // Alias for fromJson to handle Map data
  factory Worker.fromMap(Map<String, dynamic> map) {
    return Worker.fromJson(map);
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
      'isFavourite': isFavourite,
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'rating': rating,
      'pricePerDay': pricePerDay,
      'imageUrl': imageUrl,
      'location': location,
      'specialization': specialization,
      'experience': experience,
      'isFavourite': isFavourite,
    };
  }
}
