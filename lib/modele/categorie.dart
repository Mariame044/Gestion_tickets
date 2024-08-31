// categorie.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Categorie {
  String id;
  String libelle;

  Categorie({required this.id, required this.libelle});

  // Convertir un document Firestore en objet Categorie
  factory Categorie.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Categorie(
      id: doc.id,
      libelle: data['libelle'] ?? '',
    );
  }

  // Convertir un objet Categorie en Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'libelle': libelle,
    };
  }
}
