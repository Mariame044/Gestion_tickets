// ticket_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestion_des_tickets/modele/tickets.dart';
import 'package:gestion_des_tickets/modele/users.dart' as local_users;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // Ajoutez cette ligne

class TicketService {
  final CollectionReference _ticketCollection =
      FirebaseFirestore.instance.collection('tickets');

  // Ajouter un ticket
  Future<void> createTicket(Ticket ticket) async {
    try {
      await _ticketCollection.add(ticket.toFirestore());
    } catch (e) {
      print('Erreur lors de la création du ticket: $e');
    }
  }
 
 


  // Récupérer un ticket par ID
  Future<Ticket?> getTicketById(String id) async {
    try {
      DocumentSnapshot doc = await _ticketCollection.doc(id).get();
      if (doc.exists) {
        return Ticket.fromFirestore(doc);
      }
    } catch (e) {
      print('Erreur lors de la récupération du ticket: $e');
    }
    return null;
  }

  // Mettre à jour le statut du ticket
  Future<void> updateTicketStatus(String id, String status) async {
    try {
      await _ticketCollection.doc(id).update({'status': status});
    } catch (e) {
      print('Erreur lors de la mise à jour du statut: $e');
    }
  }

  
Future<List<Ticket>> getTicketsByUser(String userId) async {
  try {
    QuerySnapshot querySnapshot = await _ticketCollection
        .where('createdBy', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();
    return querySnapshot.docs
        .map((doc) => Ticket.fromFirestore(doc))
        .toList();
  } catch (e) {
    print('Erreur lors de la récupération des tickets: $e');
    return [];
  }
}



  // Supprimer un ticket
  Future<void> deleteTicket(String id) async {
    try {
      await _ticketCollection.doc(id).delete();
    } catch (e) {
      print('Erreur lors de la suppression du ticket: $e');
    }
  }
   
  
// Récupérer tous les tickets
  Stream<List<Ticket>> getAllTicketsAsStream() {
    return _ticketCollection.snapshots().map((snapshot) {
      try {
        return snapshot.docs.map((doc) => Ticket.fromFirestore(doc)).toList();
      } catch (e) {
        print('Erreur lors du stream des tickets: $e');
        return [];
      }
    });
  }
 // Prendre en charge un ticket
  Future<void> takeChargeTicket(String ticketId, String formateurId) async {
    try {
      final ticketDocRef = _ticketCollection.doc(ticketId);
      final doc = await ticketDocRef.get();
      final ticket = Ticket.fromFirestore(doc);

      if (ticket.status == 'En cours') {
        throw Exception('Le ticket est déjà en cours et ne peut pas être pris en charge par un autre formateur.');
      }

      await ticketDocRef.update({
        'status': 'En cours',
        'assignedTo': formateurId,
      });
    } catch (e) {
      print('Erreur lors de la prise en charge du ticket: $e');
    }
  }

  // Gérer un ticket (réponse ou résolution)
  Future<void> handleTicket(String ticketId, String currentUserId, {String? response, bool resolve = false}) async {
    try {
      final ticketDocRef = _ticketCollection.doc(ticketId);
      final doc = await ticketDocRef.get();
      final ticket = Ticket.fromFirestore(doc);

      if (resolve) {
        if (ticket.status != 'En cours' || ticket.assignedTo != currentUserId) {
          throw Exception('Erreur: Vous n\'êtes pas autorisé à résoudre ce ticket');
        }
        await ticketDocRef.update({'status': 'Résolu'});
      } else if (response != null) {
        if (ticket.status != 'En cours' || ticket.assignedTo != currentUserId) {
          throw Exception('Erreur: Vous n\'êtes pas autorisé à répondre à ce ticket');
        }

        final responses = ticket.responses ?? {};
        if (responses.containsKey(currentUserId)) {
          // Si le formateur a déjà répondu, mettre à jour la réponse existante
          responses[currentUserId] = response;
        } else {
          // Ajouter une nouvelle réponse
          responses[currentUserId] = response;
        }

        await ticketDocRef.update({
          'responses': responses,
          'status': 'Résolu', // Met à jour le statut après la réponse
        });
      }
    } catch (e) {
      print('Erreur lors de la gestion du ticket: $e');
    }
  }
// Modifier un ticket par son créateur avant la prise en charge
  Future<void> updateTicket(String ticketId, String currentUserId, Map<String, dynamic> updates) async {
    try {
      final ticketDocRef = _ticketCollection.doc(ticketId);
      final doc = await ticketDocRef.get();
      final ticket = Ticket.fromFirestore(doc);

      if (ticket.createdBy != currentUserId || ['Résolu', 'En cours'].contains(ticket.status)) {
        throw Exception('Erreur: Vous n\'êtes pas autorisé à modifier ce ticket');
      }

      await ticketDocRef.update(updates);
    } catch (e) {
      print('Erreur lors de la modification du ticket: $e');
    }
  }
}