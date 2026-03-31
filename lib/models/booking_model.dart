import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String userId;
  final String patientName;
  final String patientAge;
  final String patientPhone;
  final String doctorSpecialization;
  final String title;
  final String productId;
  final double amount;
  final int bookingNumber;
  final String status;
  final String paymentMethod;
  final String date; // ⚠️ String because your DB uses string

  BookingModel({
    required this.id,
    required this.userId,
    required this.patientName,
    required this.patientAge,
    required this.patientPhone,
    required this.doctorSpecialization,
    required this.title,
    required this.productId,
    required this.amount,
    required this.bookingNumber,
    required this.status,
    required this.paymentMethod,
    required this.date,
  });

  /// 🔥 FROM FIRESTORE (FIXED)
  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return BookingModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      patientName: data['patientName'] ?? '',
      patientAge: data['patientAge'] ?? '',
      patientPhone: data['patientPhone'] ?? '',
      doctorSpecialization: data['doctorSpecialization'] ?? '',
      title: data['title'] ?? '',
      productId: data['productId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      bookingNumber: data['bookingNumber'] ?? 1,
      status: data['status'] ?? 'Pending',
      paymentMethod: data['paymentMethod'] ?? '',
      date: data['date'] ?? '',
    );
  }

  /// 🔥 TO MAP (SAVE TO FIRESTORE)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'patientName': patientName,
      'patientAge': patientAge,
      'patientPhone': patientPhone,
      'doctorSpecialization': doctorSpecialization,
      'title': title,
      'productId': productId,
      'amount': amount,
      'bookingNumber': bookingNumber,
      'status': status,
      'paymentMethod': paymentMethod,
      'date': date, // ⚠️ still string
    };
  }

  /// 🔥 COPY WITH (OPTIONAL)
  BookingModel copyWith({
    String? status,
    String? paymentMethod,
  }) {
    return BookingModel(
      id: id,
      userId: userId,
      patientName: patientName,
      patientAge: patientAge,
      patientPhone: patientPhone,
      doctorSpecialization: doctorSpecialization,
      title: title,
      productId: productId,
      amount: amount,
      bookingNumber: bookingNumber,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      date: date,
    );
  }
}