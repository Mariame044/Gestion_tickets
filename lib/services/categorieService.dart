import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestion_des_tickets/modele/categorie.dart';

// categorie_service.dart

import 'package:firebase_auth/firebase_auth.dart';


class CategorieService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _categorieCollection =
      FirebaseFirestore.instance.collection('categories');

  // Ajouter une nouvelle catégorie
  Future<void> addCategorie(Categorie categorie) async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      // L'utilisateur est authentifié
      await _categorieCollection.add(categorie.toFirestore());
    } else {
      throw FirebaseAuthException(
        code: 'unauthenticated',
        message: 'L\'utilisateur doit être authentifié pour ajouter une catégorie.',
      );
    }
  }

  // Obtenir une liste de catégories
  Future<List<Categorie>> getCategories() async {
    QuerySnapshot querySnapshot = await _categorieCollection.get();
    return querySnapshot.docs
        .map((doc) => Categorie.fromFirestore(doc))
        .toList();
  }
    // Supprimer une catégorie par ID
  Future<void> deleteCategorie(String id) async {
    try {
      await _categorieCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la catégorie : ${e.toString()}');
    }
  }
}


