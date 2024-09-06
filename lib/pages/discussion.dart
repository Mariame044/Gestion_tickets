import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gestion_des_tickets/modele/tickets.dart';
import 'package:gestion_des_tickets/pages/chat.dart'; // Importez la page de chat

class DiscussionsScreen extends StatefulWidget {
  @override
  _DiscussionsScreenState createState() => _DiscussionsScreenState();
}

class _DiscussionsScreenState extends State<DiscussionsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Discussions'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getDiscussionsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final discussions = snapshot.data!.docs;
          List<Widget> discussionWidgets = discussions.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final discussionId = doc.id;
            final lastMessage = data['lastMessage'] ?? 'Pas de message';
            final timestamp = data['timestamp']?.toDate() ?? DateTime.now();

            return ListTile(
              title: Text('Discussion ID: $discussionId'),
              subtitle: Text(lastMessage),
              trailing: Text(timestamp.toLocal().toString()),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      discussionId: discussionId,
                      ticket: Ticket.fromFirestore(doc), // Assurez-vous que le modèle Ticket a une méthode fromFirestore
                    ),
                  ),
                );
              },
            );
          }).toList();

          return ListView(
            children: discussionWidgets,
          );
        },
      ),
    );
  }

  Stream<QuerySnapshot> _getDiscussionsStream() {
    // Vérifiez si l'utilisateur est un formateur
    final isFormateur = _user.uid.startsWith('formateur'); // Adaptez cette condition si nécessaire

    if (isFormateur) {
      // Les formateurs voient toutes les discussions auxquelles ils sont participants
      return _firestore.collection('discussions')
        .where('participants', arrayContains: _user.uid)
        .snapshots();
    } else {
      // Les autres utilisateurs voient uniquement les discussions où ils sont participants
      return _firestore.collection('discussions')
        .where('participants', arrayContains: _user.uid)
        .snapshots();
    }
  }
}
