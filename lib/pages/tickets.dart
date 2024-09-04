import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestion_des_tickets/services/ticketsService.dart';
import 'package:gestion_des_tickets/services/categorieService.dart';
import 'package:gestion_des_tickets/modele/tickets.dart';
import 'package:gestion_des_tickets/modele/categorie.dart';

class TicketCreationDialog extends StatefulWidget {
  final List<Categorie> categories;
  final TicketService ticketService;
  final Function onTicketCreated; // Fonction callback pour notifier la création

  const TicketCreationDialog({
    required this.categories,
    required this.ticketService,
    required this.onTicketCreated, // Initialiser le callback
    super.key,
  });

  @override
  _TicketCreationDialogState createState() => _TicketCreationDialogState();
}

class _TicketCreationDialogState extends State<TicketCreationDialog> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _titreController = TextEditingController();
  String _selectedCategory = '';

  @override
  void initState() {
    super.initState();
    if (widget.categories.isNotEmpty) {
      _selectedCategory = widget.categories.first.libelle;
    }
  }

  Future<void> _createTicket() async {
    if (_titreController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final newTicket = Ticket(
        id: '',
        description: _descriptionController.text,
        titre: _titreController.text,
        status: 'Attente',
        category: _selectedCategory,
        createdBy: user.uid,
        assignedTo: null,
        responses: {},
        timestamp: Timestamp.now(),
      );

      try {
        await widget.ticketService.createTicket(newTicket);
        widget.onTicketCreated(); // Appel du callback pour actualiser les tickets
        Navigator.pop(context); // Fermer le dialog après la création du ticket
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket créé avec succès !')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la création du ticket')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilisateur non connecté')),
      );
    }
  }

 @override
Widget build(BuildContext context) {
  return Dialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image en haut du formulaire
            Container(
              height: 200, // Hauteur de l'image
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/reset.png'), // Changez le chemin de l'image
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _titreController,
              decoration: const InputDecoration(
                labelText: 'Titre du Ticket',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16.0),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: DropdownButton<String>(
                value: _selectedCategory,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
                isExpanded: true,
                items: widget.categories
                    .map<DropdownMenuItem<String>>((Categorie category) {
                  return DropdownMenuItem<String>(
                    value: category.libelle,
                    child: Text(category.libelle),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _createTicket,
              child: const Text('Créer Ticket'),
            ),
          ],
        ),
      ),
    ),
  );
}
}