// import 'package:cloud_firestore/cloud_firestore.dart';

// class Ticket {
//   String id;
//   String titre;
//   String description;
//   String status;
//   String category;
//   String createdBy;
//   String? assignedTo;
//   List<String> responses;
//   Timestamp timestamp;

//   Ticket({
//     required this.id,
//     required this.titre,
//     required this.description,
//     required this.status,
//     required this.category,
//     required this.createdBy,
//     this.assignedTo,
//     required this.responses,
//     required this.timestamp,
//   });

//   // Convertir un document Firestore en objet Ticket
//   factory Ticket.fromFirestore(DocumentSnapshot doc) {
//     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//     return Ticket(
//       id: doc.id,
//       description: data['description'] ?? '',
//       titre: data['titre'] ?? '',
//       status: data['status'] ?? 'Attente',
//       category: data['category'] ?? '',
//       createdBy: data['createdBy'] ?? '',
//       assignedTo: data['assignedTo'],
//       responses: List<String>.from(data['responses'] ?? []),
//       timestamp: data['timestamp'] ?? Timestamp.now(),
//     );
//   }

//   // Convertir un objet Ticket en Map pour Firestore
//   Map<String, dynamic> toFirestore() {
//     return {
//       'description': description,
//       'titre': titre,
//       'status': status,
//       'category': category,
//       'createdBy': createdBy,
//       'assignedTo': assignedTo,
//       'responses': responses,
//       'timestamp': timestamp,
//     };
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';

class Ticket {
  String id;
  String titre;
  String description;
  String status;
  String category;
  String createdBy;
  String? assignedTo;
  Map<String, String> responses; // Changement ici pour Map
  Timestamp timestamp;

  Ticket({
    required this.id,
    required this.titre,
    required this.description,
    required this.status,
    required this.category,
    required this.createdBy,
    this.assignedTo,
    required this.responses,
    required this.timestamp,
  });

  // Convertir un document Firestore en objet Ticket
  factory Ticket.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Ticket(
      id: doc.id,
      description: data['description'] ?? '',
      titre: data['titre'] ?? '',
      status: data['status'] ?? 'Attente',
      category: data['category'] ?? '',
      createdBy: data['createdBy'] ?? '',
      assignedTo: data['assignedTo'],
      responses: Map<String, String>.from(data['responses'] ?? {}), // Changement ici
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  // Convertir un objet Ticket en Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'description': description,
      'titre': titre,
      'status': status,
      'category': category,
      'createdBy': createdBy,
      'assignedTo': assignedTo,
      'responses': responses, // Changement ici
      'timestamp': timestamp,
    };
  }
}
