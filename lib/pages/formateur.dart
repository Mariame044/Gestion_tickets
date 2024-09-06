import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gestion_des_tickets/composants/barre.dart';
import 'package:gestion_des_tickets/modele/tickets.dart';
import 'package:gestion_des_tickets/services/ticketsService.dart';
import 'package:gestion_des_tickets/pages/reponses.dart';

class Formateur extends StatefulWidget {
  @override
  _FormateurState createState() => _FormateurState();
}

class _FormateurState extends State<Formateur> {
  final TicketService _ticketService = TicketService();
  String? _currentUserId;
   User? _user;
   String _name = '';
  int _selectedIndex = 0; // Index sélectionné pour la barre de navigation
@override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
   _loadData();; // Récupérer le nom de l'utilisateur au démarrage
  }

  Future<void> _loadData() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    // Récupérer le nom d'utilisateur (ou email si le nom n'est pas disponible)
    String name = user.displayName ?? user.email?.split('@')[0] ?? 'Utilisateur';

    setState(() {
      _name = name;  // Mettre à jour le nom de l'utilisateur
    });
  }
}
  // @override
  // void initState() {
  //   super.initState();
  //   _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  // }
 

  // Méthode pour prendre en charge un ticket
  void _takeCharge(String ticketId) async {
    if (_currentUserId == null) return;

    try {
      await _ticketService.takeChargeTicket(ticketId, _currentUserId!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ticket pris en charge')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la prise en charge du ticket')),
      );
    }
  }

  // Méthode pour vérifier si un ticket est pris en charge par l'utilisateur actuel
  Future<bool> _isTicketAssignedToUser(String ticketId) async {
    try {
      final ticket = await _ticketService.getTicketById(ticketId);
      return ticket?.assignedTo == _currentUserId;
    } catch (e) {
      print('Erreur lors de la vérification de l\'assignation du ticket: $e');
      return false;
    }
  }
  
   void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    //Ajoutez la logique pour chaque élément de la barre de navigation, par exemple :
    if (index == 0) { // Home
      Navigator.pushNamed(context, '/formateur');
    } else if (index == 1) { // Messages
      Navigator.pushNamed(context, '/discussion');
    } else if (index == 2) { // Paramètres
      Navigator.pushNamed(context, '/settings');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Tous les Tickets'),
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.logout),
      //       onPressed: () async {
      //         await FirebaseAuth.instance.signOut();
      //         Navigator.of(context).pushReplacementNamed('/login');
      //       },
      //     ),
      //   ],
      // ),
       appBar: AppBar(
  title: Row(
    children: [
      CircleAvatar(
        backgroundColor: Colors.grey,
        child: Icon(
          Icons.person, // Icône de profil par défaut
          color: Colors.white,
        ),
      ),
      const SizedBox(width: 8.0),
      Text(
        'Bonjour $_name',
        style: const TextStyle(color: Colors.white),
      ),
    ],
  ),
        backgroundColor: const Color(0xFF414780),  // Couleur bleue pour l'AppBar
        iconTheme: const IconThemeData(color: Colors.white),  // Icônes en blanc
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            color: Colors.white,  // Icône de recherche en blanc
            onPressed: () {
              // Ajouter des actions pour la recherche si nécessaire
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
        
      ),
      body: StreamBuilder<List<Ticket>>(
        stream: _ticketService.getAllTicketsAsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur lors de la récupération des tickets'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucun ticket disponible'));
          } else {
            // Inclure tous les tickets, sans exclure les résolus ou fermés
            final tickets = snapshot.data!;
            return ListView.builder(
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                return FutureBuilder<bool>(
                  future: _isTicketAssignedToUser(ticket.id),
                  builder: (context, assignedSnapshot) {
                    if (assignedSnapshot.connectionState == ConnectionState.waiting) {
                      
                      return ListTile(
                        title: Text('Ticket ID: ${ticket.id}'),
                        subtitle: Text('Chargement des informations...'),
                      );
                    } else if (assignedSnapshot.hasError || !assignedSnapshot.hasData) {
                      return ListTile(
                        title: Text('Ticket ID: ${ticket.id}'),
                        subtitle: Text('Erreur lors de la vérification de l\'assignation'),
                      );
                    } else {
                      final isAssigned = assignedSnapshot.data!;
                      return ListTile(
                        title: Text('Ticket ID: ${ticket.id}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Statut: ${ticket.status}'),
                            Text('Catégorie: ${ticket.category}'),
                            Text('Créé par: ${ticket.createdBy}'),
                            
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Bouton pour prendre en charge le ticket
                           
                            if (ticket.status != 'En cours' && ticket.status != 'Résolu' && !isAssigned)
                              IconButton(
                                icon: Icon(Icons.check_circle, color: Colors.green),
                                onPressed: () {
                                  _takeCharge(ticket.id);
                                },
                              ),
                            // Icône grise pour les tickets en cours ou résolus
                            if (ticket.status == 'En cours' || ticket.status == 'Résolu')
                             
                              Text(
                                'Déjà pris en charge',
                                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                              ),
                              IconButton(
                                
                                icon: Icon(Icons.check_circle, color: Colors.grey),
                                onPressed: () {
                                  
                                },
                              ),
                            // Bouton pour répondre au ticket
                            if (ticket.status == 'En cours' && isAssigned)
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => TicketResponsePage(ticketId: ticket.id),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
           BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Paramètres'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
