// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:gestion_des_tickets/modele/users.dart';
// import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

// class UserService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // Fonction pour créer un utilisateur
//   Future<void> createUser(User user) async {
//     await _firestore.collection('users').doc(user.id).set(user.toMap());
//   }

//   // Fonction pour obtenir un utilisateur par son ID
//   Future<User?> getUserById(String userId) async {
//     DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
//     if (doc.exists) {
//       return User.fromFirestore(doc);
//     }
//     return null;
//   }

//   // Fonction pour obtenir tous les utilisateurs
//   Stream<List<User>> getAllUsers() {
//     return _firestore.collection('users').snapshots().map((snapshot) {
//       return snapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
//     });
//   }
//     // Fonction pour mettre à jour les informations d'un utilisateur
//   Future<void> updateUser(User user) async {
//     try {
//       await _firestore.collection('users').doc(user.id).update(user.toMap());
//     } catch (e) {
//       // Gérer les erreurs potentielles
//       print('Erreur lors de la mise à jour de l\'utilisateur : $e');
//     }
//   }

  
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:gestion_des_tickets/modele/users.dart' as model;

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  // Fonction pour créer un utilisateur
  Future<void> createUser(model.User user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  // Fonction pour obtenir un utilisateur par son ID
  Future<model.User?> getUserById(String userId) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return model.User.fromFirestore(doc);
    }
    return null;
  }

  // Fonction pour obtenir tous les utilisateurs
  Stream<List<model.User>> getAllUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => model.User.fromFirestore(doc)).toList();
    });
  }

  // Fonction pour mettre à jour les informations d'un utilisateur
  Future<void> updateUser(model.User user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toMap());
    } catch (e) {
      // Gérer les erreurs potentielles
      print('Erreur lors de la mise à jour de l\'utilisateur : $e');
    }
  }

  // Fonction pour mettre à jour le mot de passe de l'utilisateur
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    firebase_auth.User? user = _auth.currentUser;

    if (user != null) {
      try {
        // Ré-authentifier l'utilisateur avec le mot de passe actuel
        firebase_auth.AuthCredential credential = firebase_auth.EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );

        await user.reauthenticateWithCredential(credential);

        // Mettre à jour le mot de passe
        await user.updatePassword(newPassword);
      } catch (e) {
        // Gérer les erreurs potentielles
        throw Exception('Erreur lors de la mise à jour du mot de passe : $e');
      }
    } else {
      throw Exception('Aucun utilisateur connecté');
    }
  }
}
