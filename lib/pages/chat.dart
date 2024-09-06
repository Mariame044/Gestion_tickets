import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gestion_des_tickets/modele/message.dart';
import 'package:gestion_des_tickets/modele/tickets.dart';

class ChatScreen extends StatefulWidget {
  final String discussionId;
  final Ticket ticket;

  ChatScreen({required this.discussionId, required this.ticket});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User _user;
  late String _discussionId;
  late Ticket _ticket;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
    _discussionId = widget.discussionId;
    _ticket = widget.ticket;

    // Ajouter le formateur comme participant si le ticket est résolu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateParticipants();
    });
  }

  Future<void> _updateParticipants() async {
    if (_ticket.status == 'Résolu') {
      try {
        final discussionDoc = _firestore.collection('discussions').doc(_discussionId);
        final discussionSnapshot = await discussionDoc.get();

        if (discussionSnapshot.exists) {
          final data = discussionSnapshot.data() as Map<String, dynamic>;
          List<dynamic> participants = List.from(data['participants'] ?? []);

          // Ajouter le formateur qui a résolu le ticket
          final formateurId = _ticket.assignedTo;
          if (formateurId != null && formateurId.isNotEmpty && !participants.contains(formateurId)) {
            await discussionDoc.update({
              'participants': FieldValue.arrayUnion([formateurId]),
            });
          }

          // Ajouter l'apprenant comme participant si ce n'est pas déjà fait
          if (!_user.uid.startsWith('formateur') && !participants.contains(_user.uid)) {
            await discussionDoc.update({
              'participants': FieldValue.arrayUnion([_user.uid]),
            });
          }
        }
      } catch (e) {
        print('Erreur lors de la mise à jour des participants: $e');
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      try {
        final message = Message(
          id: '', // Firestore générera l'ID automatiquement
          senderId: _user.uid,
          content: _messageController.text,
          timestamp: Timestamp.now(),
        );

        // Ajouter le message à la sous-collection 'messages'
        await _firestore
            .collection('discussions')
            .doc(_discussionId)
            .collection('messages')
            .add(message.toMap());

        // Mettre à jour la discussion avec le dernier message
        await _firestore.collection('discussions').doc(_discussionId).update({
          'lastMessage': message.content,
          'timestamp': Timestamp.now(),
        });

        _messageController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'envoi du message: $e'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Le message ne peut pas être vide.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('discussions')
                  .doc(_discussionId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;
                List<Widget> messageWidgets = messages.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final message = Message.fromFirestore(data, doc.id);

                  // Déterminez si le message est du formateur ou de l'apprenant
                  final isFromFormateur = message.senderId == _ticket.assignedTo;

                  return Align(
                    alignment: isFromFormateur ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isFromFormateur ? Colors.blueAccent : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.senderId,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isFromFormateur ? Colors.white : Colors.black,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            message.content,
                            style: TextStyle(color: isFromFormateur ? Colors.white : Colors.black),
                          ),
                          SizedBox(height: 4),
                          Text(
                            message.timestamp.toDate().toLocal().toString(),
                            style: TextStyle(
                              fontSize: 10,
                              color: isFromFormateur ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList();

                // Assurez-vous que la vue défile vers le bas lorsque de nouveaux messages arrivent
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                  }
                });

                return ListView(
                  controller: _scrollController,
                  children: messageWidgets,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Entrez votre message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
