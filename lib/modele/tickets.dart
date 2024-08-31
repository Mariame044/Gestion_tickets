import 'package:cloud_firestore/cloud_firestore.dart';

// Classe Ticket pour représenter un ticket
class Ticket {
  final String id;
  final String description;
  final String status;
  final String category;
  final String createdBy;
  final List<dynamic> responses;

  Ticket({
    required this.id,
    required this.description,
    required this.status,
    required this.category,
    required this.createdBy,
    required this.responses,
  });

  // Convertir un document Firestore en objet Ticket
  factory Ticket.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Ticket(
      id: doc.id,
      description: data['description'] ?? '',
      status: data['status'] ?? 'Attente',
      category: data['category'] ?? '',
      createdBy: data['createdBy'] ?? '',
      responses: data['responses'] ?? [],
    );
  }

  // Convertir un objet Ticket en map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'status': status,
      'category': category,
      'createdBy': createdBy,
      'responses': responses,
    };
  }
}
