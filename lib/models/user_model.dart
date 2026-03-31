import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String profilePicUrl;

  UserModel({
    required this.id,
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.profilePicUrl,
  });

  /// 🔥 FROM FIRESTORE (MATCHED)
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      id: doc.id,
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      profilePicUrl: data['profilePicUrl'] ?? '',
    );
  }

  /// 🔥 TO MAP
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'profilePicUrl': profilePicUrl,
    };
  }

  /// 🔥 COPY WITH
  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? profilePicUrl,
  }) {
    return UserModel(
      id: id,
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
    );
  }
}