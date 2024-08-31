import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  final String firstName;
  final String name;
  final String roles; // Liste des rôles

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.name,
    required this.roles,
  });

  // Création d'une instance de User à partir d'un DocumentSnapshot
  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      email: data['email'] ?? '',
      firstName: data['prenom'] ?? '',
      name: data['nom'] ?? '',
      roles: data['role'] // Assurez-vous que `role` est une liste de chaînes
    );
  }

  // Conversion de User en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'prenom': firstName,
      'nom': name,
      'role': roles, // Assurez-vous que `roles` est une liste
    };
  }
}
