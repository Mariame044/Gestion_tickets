import 'package:flutter/material.dart';
import 'package:gestion_des_tickets/modele/users.dart'; // Importer le modèle User
import 'package:gestion_des_tickets/services/usersService.dart';  // Importer le service UserService

class UserListPage extends StatelessWidget {
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Utilisateurs'),
      ),
      body: StreamBuilder<List<User>>(
        stream: _userService.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucun utilisateur trouvé.'));
          }

          final users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text('${user.firstName} ${user.name}'),
                subtitle: Text('Email : ${user.email}'),
                trailing: Text('Rôle(s) : ${user.roles}'), // Affichage des rôles
                onTap: () {
                  // Action à effectuer lors du clic sur un utilisateur
                },
              );
            },
          );
        },
      ),
    );
  }
}
