import 'package:flutter/material.dart';
import 'package:gestion_des_tickets/modele/tickets.dart';
import 'package:gestion_des_tickets/pages/chat.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class TicketDetailsScreen extends StatelessWidget {
  final Ticket ticket;

  TicketDetailsScreen({required this.ticket});

  Future<void> _openChat(BuildContext context, Ticket ticket) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {
      // Vérifiez si une discussion existe déjà pour ce ticket
      QuerySnapshot query = await _firestore
          .collection('discussions')
          .where('ticketId', isEqualTo: ticket.id)
          .limit(1)
          .get();

      String discussionId;
      
      if (query.docs.isNotEmpty) {
        // Si une discussion existe, récupérez son ID
        discussionId = query.docs.first.id;
      } else {
        // Sinon, créez une nouvelle discussion
        DocumentReference newDiscussion = await _firestore.collection('discussions').add({
          'ticketId': ticket.id,
          'lastMessage': '', // Mettre à jour avec le dernier message le cas échéant
          'timestamp': FieldValue.serverTimestamp(),
        });

        discussionId = newDiscussion.id; // Récupérez l'ID généré par Firestore
      }

      // Naviguez vers l'écran de chat avec l'ID de la discussion et le ticket
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            discussionId: discussionId, // Passez l'ID de la discussion
            ticket: ticket, // Passez le ticket
          ),
        ),
      );
    } catch (e) {
      print('Erreur lors de l\'ouverture du chat: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'ouverture du chat.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ticket.titre),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ticket.titre,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8.0),
            Text(
              ticket.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 8.0),
            Text(
              'Date: ${ticket.timestamp.toDate().toLocal()}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 8.0),
            Text(
              'Statut: ${ticket.status}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 16.0),
            SizedBox(height: 8.0),
            ticket.responses.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: ticket.responses.entries.map((entry) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 8.0),
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text('${entry.value}'),
                      );
                    }).toList(),
                  )
                : Text(
                    'Réponses non disponibles',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
            ElevatedButton(
              onPressed: () => _openChat(context, ticket), // Ouvrir le chat
              child: Text('Ouvrir le chat'),
            ),
          ],
        ),
      ),
    );
  }
}
