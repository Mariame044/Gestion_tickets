import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestion_des_tickets/modele/users.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fonction pour créer un utilisateur
  Future<void> createUser(User user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  // Fonction pour obtenir un utilisateur par son ID
  Future<User?> getUserById(String userId) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return User.fromFirestore(doc);
    }
    return null;
  }

  // Fonction pour obtenir tous les utilisateurs
  Stream<List<User>> getAllUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
    });
  }
}
