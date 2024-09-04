import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:gestion_des_tickets/services/usersService.dart';
import 'package:gestion_des_tickets/modele/users.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final UserService _userService = UserService();
  User? _user;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final firebase_auth.User? firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      User? user = await _userService.getUserById(firebaseUser.uid);
      if (user != null) {
        setState(() {
          _user = user;
          _nameController.text = user.name;
          _emailController.text = user.firstName;
        });
      }
    }
  }

  Future<void> _updateUser() async {
    if (_formKey.currentState?.validate() ?? false) {
      User updatedUser = User(
        id: _user!.id,
        name: _nameController.text,
        email: _emailController.text,
        roles: _user!.roles,
        firstName: _user!.firstName,
      );

      try {
        await _userService.updateUser(updatedUser);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Informations mises à jour')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la mise à jour des informations : $e')),
        );
      }
    }
  }

  Future<void> _changePassword() async {
    if (_currentPasswordController.text.isNotEmpty &&
        _newPasswordController.text.isNotEmpty &&
        _newPasswordController.text == _confirmPasswordController.text) {
      try {
        await _userService.updatePassword(
          _currentPasswordController.text,
          _newPasswordController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mot de passe mis à jour')),
        );
      } catch (e) {
        String errorMessage;
        if (e is firebase_auth.FirebaseAuthException) {
          switch (e.code) {
            case 'wrong-password':
              errorMessage = 'L\'ancien mot de passe est incorrect';
              break;
            case 'user-not-found':
              errorMessage = 'Aucun utilisateur trouvé';
              break;
            case 'invalid-credential':
              errorMessage = 'Informations d\'identification invalides';
              break;
            default:
              errorMessage = 'Erreur lors de la mise à jour du mot de passe : ${e.message}';
              break;
          }
        } else {
          errorMessage = 'Erreur lors de la mise à jour du mot de passe : $e';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez vérifier les champs de mot de passe')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Modifier Profil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[ // Section pour l'avatar
            Center(
              child: CircleAvatar(
                radius: 50.0, // Taille de l'avatar
                backgroundColor: Colors.grey[200],
                child: Icon(
                  Icons.person,
                  size: 50.0,
                  color: Colors.grey[800],
                ),
              ),
            ),

            // Section pour la mise à jour des informations utilisateur
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nom'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le nom est requis';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Prenom'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'L\'email est requis';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'L\'email n\'est pas valide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _updateUser,
                    child: const Text('Sauvegarder'),
                  ),
                  const SizedBox(height: 32.0),

                  // Section pour la modification du mot de passe
                  TextFormField(
                    controller: _currentPasswordController,
                    decoration: const InputDecoration(labelText: 'Mot de passe actuel'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le mot de passe actuel est requis';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _newPasswordController,
                    decoration: const InputDecoration(labelText: 'Nouveau mot de passe'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le nouveau mot de passe est requis';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(labelText: 'Confirmer le nouveau mot de passe'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez confirmer le nouveau mot de passe';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Les mots de passe ne correspondent pas';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _changePassword,
                    child: const Text('Modifier le mot de passe'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
