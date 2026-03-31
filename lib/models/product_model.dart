import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String categoryId;

  final List<String> imageUrls; // ✅ FIXED (array)
  final int patientCount;
  final int dailyPatientCount;
  final int experience;
  final double rating;
  final int reviewCount;
  final int bookedCount;

  final bool status; // ✅ instead of isActive

  final List<dynamic> attributes; // ✅ for Day/Time

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.imageUrls,
    required this.patientCount,
    required this.dailyPatientCount,
    required this.experience,
    required this.rating,
    required this.reviewCount,
    required this.bookedCount,
    required this.status,
    required this.attributes,
  });

  /// 🔥 FROM FIRESTORE
  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      categoryId: data['categoryId'] ?? '',

      imageUrls: List<String>.from(data['imageUrl'] ?? []), // ✅ FIX
      patientCount: data['patientCount'] ?? 0,
      dailyPatientCount: data['dailyPatientCount'] ?? 0,
      experience: data['experience'] ?? 0,
      rating: (data['rating'] ?? 0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      bookedCount: data['bookedCount'] ?? 0,

      status: data['status'] ?? false,

      attributes: data['attributes'] ?? [],
    );
  }

  /// 🔥 TO MAP
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'categoryId': categoryId,
      'imageUrl': imageUrls,
      'patientCount': patientCount,
      'dailyPatientCount': dailyPatientCount,
      'experience': experience,
      'rating': rating,
      'reviewCount': reviewCount,
      'bookedCount': bookedCount,
      'status': status,
      'attributes': attributes,
    };
  }
}