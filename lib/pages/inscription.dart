import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Classe pour la page d'inscription
class inscription extends StatefulWidget {
  @override
  _InscriptionPageState createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<inscription> {
  // Contrôleurs de texte pour récupérer les valeurs des champs de formulaire
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();

  // Instances de Firebase Auth et Firestore
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Rôle sélectionné, par défaut 'apprenant'
  String _selectedRole = 'apprenant';
  // Liste des rôles disponibles
  final List<String> _roles = ['apprenant', 'formateur', 'admin'];

  // Fonction d'inscription
  Future<void> _signUp() async {
    // Récupération des valeurs des champs de formulaire
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final nom = _nomController.text.trim();
    final prenom = _prenomController.text.trim();

    // Validation des champs de formulaire
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty || nom.isEmpty || prenom.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tous les champs doivent être remplis')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le mot de passe doit comporter au moins 6 caractères')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les mots de passe ne correspondent pas')),
      );
      return;
    }

    // Vérifier si l'utilisateur est connecté
    User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous devez être connecté pour ajouter des utilisateurs')),
      );
      return;
    }

    // Vérifier le rôle de l'utilisateur actuel (doit être un administrateur)
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
    Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

    if (userData == null || userData['role'] != 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous devez être un administrateur pour ajouter des utilisateurs')),
      );
      return;
    }

    // Création d'un nouvel utilisateur avec Firebase Auth
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        // Ajout des informations de l'utilisateur à Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'nom': nom,
          'prenom': prenom,
          'role': _selectedRole,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Afficher un message de succès et rediriger vers la page de connexion
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inscription réussie')),
        );

        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      // Gestion des erreurs
      String errorMessage = 'Erreur inconnue';
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'weak-password':
            errorMessage = 'Le mot de passe est trop faible';
            break;
          case 'email-already-in-use':
            errorMessage = 'Cet email est déjà utilisé';
            break;
          case 'invalid-email':
            errorMessage = 'Adresse email invalide';
            break;
          default:
            errorMessage = 'Erreur : ${e.message}';
            break;
        }
      } else {
        errorMessage = e.toString();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Inscription'),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
        
            width: double.infinity,
            height: 300,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/reset2.png'),
              ),
            ),
          ),
          // Champ pour l'email
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            textInputAction: TextInputAction.next,
          ),
          // Champ pour le nom
          TextField(
            controller: _nomController,
            decoration: const InputDecoration(labelText: 'Nom'),
            textInputAction: TextInputAction.next,
          ),
          // Champ pour le prénom
          TextField(
            controller: _prenomController,
            decoration: const InputDecoration(labelText: 'Prénom'),
            textInputAction: TextInputAction.next,
          ),
          // Champ pour le mot de passe
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Mot de passe'),
            obscureText: true,
            textInputAction: TextInputAction.next,
          ),
          // Champ pour la confirmation du mot de passe
          TextField(
            controller: _confirmPasswordController,
            decoration: const InputDecoration(labelText: 'Confirmer le mot de passe'),
            obscureText: true,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 20),
          // Menu déroulant pour sélectionner le rôle
          DropdownButton<String>(
            value: _selectedRole,
            onChanged: (String? newValue) {
              setState(() {
                _selectedRole = newValue!;
              });
            },
            items: _roles.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          // Bouton pour s'inscrire
          ElevatedButton(
            onPressed: _signUp,
            child: const Text('S\'inscrire'),
          ),
        ],
      ),
    ),
  );
}
}