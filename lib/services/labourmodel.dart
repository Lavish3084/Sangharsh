class Labourer {
  final String id;
  final String name;
  final String location;
  final double rating;
  final int pricePerDay;
  final String imageUrl;
  final String category;
  final String specialization;
  final int experience;
  final bool isBookmarked;
  final double reviews;
  final int Rs;

  Labourer({
    required this.id,
    required this.name,
    required this.location,
    required this.rating,
    required this.pricePerDay,
    required this.imageUrl,
    required this.category,
    required this.specialization,
    required this.experience,
    required this.reviews,
    required this.Rs,
    this.isBookmarked = false,
  });
}
