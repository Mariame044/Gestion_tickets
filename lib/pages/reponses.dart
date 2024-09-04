import 'package:flutter/material.dart';
import 'package:gestion_des_tickets/modele/tickets.dart';
import 'package:gestion_des_tickets/services/ticketsService.dart'; // Assurez-vous que ce chemin est correct
import 'package:firebase_auth/firebase_auth.dart';

class TicketResponsePage extends StatefulWidget {
  final String ticketId;

  TicketResponsePage({required this.ticketId});

  @override
  _TicketResponsePageState createState() => _TicketResponsePageState();
}

class _TicketResponsePageState extends State<TicketResponsePage> {
  final TextEditingController _responseController = TextEditingController();
  final TicketService _ticketService = TicketService();
  late Future<Ticket?> _ticketFuture;
  bool _hasResponded = false; // Pour suivre si le formateur a déjà répondu

  @override
  void initState() {
    super.initState();
    _ticketFuture = _ticketService.getTicketById(widget.ticketId);
    _checkIfFormateurHasResponded();
  }

  // Vérifier si le formateur a déjà répondu au ticket
  Future<void> _checkIfFormateurHasResponded() async {
    try {
      final ticket = await _ticketFuture;
      if (ticket != null) {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null && ticket.responses.containsKey(userId)) {
          setState(() {
            _hasResponded = true;
            _responseController.text = ticket.responses[userId] ?? ''; // Charger la réponse existante
          });
        }
      }
    } catch (e) {
      print('Erreur lors de la vérification de la réponse du formateur: $e');
    }
  }

  // Méthode pour soumettre la réponse
  Future<void> _submitResponse() async {
    final response = _responseController.text.trim();
    if (response.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez entrer une réponse')),
      );
      return;
    }

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('Utilisateur non authentifié');
      }
      final ticket = await _ticketFuture;

      if (ticket == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ticket non trouvé')),
        );
        return;
      }

      if (ticket.assignedTo != userId) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vous ne pouvez pas répondre à ce ticket')),
        );
        return;
      }

      if (ticket.status == 'Résolu') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Le ticket est déjà résolu. Vous ne pouvez plus répondre.')),
        );
        return;
      }

      // Appeler la méthode pour ajouter ou mettre à jour la réponse au ticket
      await _ticketService.handleTicket(widget.ticketId, userId, response: response);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Réponse ajoutée/modifiée avec succès')),
      );
      Navigator.of(context).pop(); // Retourner à la page précédente
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'ajout de la réponse: $e')),
      );
    }
  }

  @override
  void dispose() {
    _responseController.dispose(); // Libération des ressources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Répondre au Ticket'),
      ),
      body: FutureBuilder<Ticket?>(
        future: _ticketFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null) {
            return Center(child: Text('Erreur: Ticket non disponible ou problème de connexion'));
          } else {
            final ticket = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Ajouter une réponse',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  if (ticket.status == 'Résolu')
                    Text(
                      'Ce ticket est déjà résolu. Vous ne pouvez plus ajouter de réponse.',
                      style: TextStyle(color: Colors.red),
                    )
                  else
                    TextField(
                      controller: _responseController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Entrez votre réponse ici',
                      ),
                    ),
                  SizedBox(height: 16),
                  if (ticket.status != 'Résolu')
                    ElevatedButton(
                      onPressed: _submitResponse,
                      child: Text(_hasResponded ? 'Modifier la réponse' : 'Envoyer la réponse'),
                    ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
