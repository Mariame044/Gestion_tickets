import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    try {
      // Connexion avec Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Récupération des informations de l'utilisateur depuis Firestore
      User? user = userCredential.user;
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

        if (userData != null) {
          String role = userData['role'] ?? 'apprenant'; // Valeur par défaut 'apprenant'

          // Redirection en fonction du rôle
          if (role == 'admin') {
            // Navigator.of(context).pushReplacementNamed('/listeusers');
             Navigator.of(context).pushReplacementNamed('/dashbord');
          } else if (role == 'formateur') {
            Navigator.of(context).pushReplacementNamed('/formateur');
          } else if (role == 'apprenant') {
            Navigator.of(context).pushReplacementNamed('/home');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Rôle inconnu')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aucune donnée utilisateur trouvée')),
          );
        }
      }
    } catch (e) {
      String errorMessage = 'Erreur inconnue';
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'Aucun utilisateur trouvé pour cet email';
            break;
          case 'wrong-password':
            errorMessage = 'Mot de passe incorrect';
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
        title: const Text('Connexion'),
      ),
      body: Container(
        color: Colors.white, // Couleur de fond du corps de l'écran

       
      
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image en couverture
                  Container(
        
            width: double.infinity,
            height: 300,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/reset2.png'),
              ),
            ),
          ),
                const SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Votre email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                   borderSide: BorderSide(color: Colors.black.withOpacity(0.5)),
                    ),
                    contentPadding: const EdgeInsets.all(12.0),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Votre mot de passe',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: Color(0xFF365FA4)),
                    ),
                    contentPadding: const EdgeInsets.all(12.0),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _login,
                  child: const Text('Se connecter'),
                  style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor:Color(0xFF365FA4), // foreground
                    
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/signup');
                  },
                  child: const Text('Pas de compte? Inscrivez-vous'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}