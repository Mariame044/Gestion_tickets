import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gestion_des_tickets/modele/message.dart';
import 'package:gestion_des_tickets/modele/discussion.dart';

class DiscussionService {
  static Future<void> creerDiscussion(
    Discussion discussion,
    Message message,
    BuildContext context,
  ) async {
    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final discussionRef = FirebaseFirestore.instance.collection('discussions').doc(discussion.discussionId);

      // Mettre à jour ou créer la discussion
      await discussionRef.set(
        discussion.toMap(),
        SetOptions(merge: true),
      );

      // Ajouter le message à la sous-collection "messages"
      await discussionRef.collection('messages').add(message.toMap());

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Message envoyé !"),
        ),
      );
    } catch (e) {
      // Gérer les erreurs
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur: ${e.toString()}"),
        ),
      );
    } finally {
      // Fermer le dialogue de chargement
      Navigator.of(context).pop();
    }
  }
}
