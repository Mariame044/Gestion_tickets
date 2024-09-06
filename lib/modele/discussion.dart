import 'package:cloud_firestore/cloud_firestore.dart';

class Discussion {
  final String discussionId;
  final List<String> participants;
  final String lastMessage;
  final Timestamp timestamp;

  Discussion({
    required this.discussionId,
    required this.participants,
    required this.lastMessage,
    required this.timestamp,
  });

  // Convertir un DocumentSnapshot en objet Discussion
  factory Discussion.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Discussion(
      discussionId: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      lastMessage: data['lastMessage'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  // Convertir l'objet Discussion en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'timestamp': timestamp,
    };
  }
}
