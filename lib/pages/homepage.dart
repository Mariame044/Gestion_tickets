import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gestion_des_tickets/composants/barre.dart';
import 'package:gestion_des_tickets/modele/discussion.dart';
import 'package:gestion_des_tickets/pages/detailTickets.dart';
import 'package:gestion_des_tickets/pages/discussion.dart';
import 'package:gestion_des_tickets/pages/tickets.dart';

import 'package:gestion_des_tickets/services/ticketsService.dart';
import 'package:gestion_des_tickets/services/categorieService.dart';
import 'package:gestion_des_tickets/modele/tickets.dart';
import 'package:gestion_des_tickets/modele/categorie.dart';
 // Assurez-vous que le chemin d'importation est correct

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TicketService _ticketService = TicketService();
  final CategorieService _categorieService = CategorieService();

  List<Categorie> _categories = [];
  List<Ticket> _tickets = [];
   List<Ticket> _filteredTickets = []; // Liste filtrée des tickets
   User? _user;
  String _name = '';
    String _searchQuery = ''; // Query de recherche
   int _selectedIndex = 0; // Index sélectionné pour la barre de navigation  String _searchQuery = ''; // Query de recherche
  Categorie? _selectedCategory; // Catégorie sélectionnée
    bool _isSearching = false; // Indicateur si l'utilisateur est en train de rechercher

  TextEditingController _searchController = TextEditingController();



  // @override
  // void initState() {
  //   super.initState();
  //   _loadData();
  //   _searchController.addListener(_filterTickets);
  // }

    @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text; // Mise à jour de _searchQuery
        _filterTickets(); // Appliquer le filtre à chaque changement de texte
      });
    });
  }
   Future<void> _loadData() async {
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      List<Categorie> categories = await _categorieService.getCategories();
      List<Ticket> tickets = await _ticketService.getTicketsByUser(_user!.uid);

      // Récupérer le nom d'utilisateur (ou email si le nom n'est pas disponible)
      String userName = _user!.displayName ?? _user!.email!.split('@')[0];

      setState(() {
        _categories = categories;
        _tickets = tickets;
       _filteredTickets = tickets; // Initialiser les tickets filtrés
        _name = userName;  // Mettre à jour le nom de l'utilisateur
      });
    }
  }
   void _filterTickets() {
    setState(() {
      _filteredTickets = _tickets.where((ticket) {
        final matchesSearch = ticket.titre.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesCategory = _selectedCategory == null || ticket.category == _selectedCategory!.libelle;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }
    void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear(); // Efface le champ de recherche lorsque la recherche est annulée
      }
    });
  }

  void _onCategorySelected(Categorie? category) {
    setState(() {
      _selectedCategory = category;
      _filterTickets();
    });
  }

  void _showTicketCreationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TicketCreationDialog(
          categories: _categories,
          ticketService: _ticketService,
          onTicketCreated: _loadData, // Passer la fonction de rappel
        );
      },
    );
  }

  void _deleteTicket(String id) async {
    try {
      await _ticketService.deleteTicket(id);
      setState(() {
        _tickets.removeWhere((ticket) => ticket.id == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket supprimé avec succès !')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la suppression du ticket')),
      );
    }
  }
   void _showEditTicketDialog(Ticket ticket) async {
  // Assurez-vous que l'utilisateur est authentifié
  if (_user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Utilisateur non authentifié')),
    );
    return;
  }

  TextEditingController titleController = TextEditingController(text: ticket.titre);
  TextEditingController descriptionController = TextEditingController(text: ticket.description);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Modifier le ticket'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Titre'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fermer le dialog sans modifier
            },
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              try {
                // Vérifier que l'utilisateur est le créateur du ticket
                if (ticket.createdBy != _user!.uid) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erreur: Vous n\'êtes pas autorisé à modifier ce ticket')),
                  );
                  Navigator.of(context).pop();
                  return;
                }

                // Vérifier le statut du ticket
                if (['Résolu', 'En cours'].contains(ticket.status)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Desolé: Ce ticket ne peut plus être modifié')),
                  );
                  Navigator.of(context).pop();
                  return;
                }

                // Mettre à jour le ticket
                await _ticketService.updateTicket(
                  ticket.id,
                  _user!.uid,
                  {
                    'titre': titleController.text,
                    'description': descriptionController.text,
                  },
                );
                await _loadData(); // Recharger les données après modification
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ticket modifié avec succès !')),
                );
                Navigator.of(context).pop(); // Fermer le dialog après modification
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Erreur lors de la modification du ticket')),
                );
              }
            },
            child: const Text('Modifier'),
          ),
        ],
      );
    },
  );
}


Future<List<Discussion>> _getDiscussions() async {
  final discussionSnapshots = await FirebaseFirestore.instance.collection('discussions').get();
  
  return discussionSnapshots.docs.map((doc) => Discussion.fromFirestore(doc)).toList();
}

 Future<void> _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });
    //Ajoutez la logique pour chaque élément de la barre de navigation, par exemple :
    if (index == 0) { // Home
      Navigator.pushNamed(context, '/home');
    } else if (index == 1) {
      Navigator.pushNamed(context, '/discussion');
     
    } else if (index == 2) { // Paramètres
      Navigator.pushNamed(context, '/settings');
    }
  }
  Color _getTextColor(String status) {
    switch (status) {
      case 'En cours':
        return Colors.blue; // Couleur du texte pour "En cours"
      case 'En attente':
        return Colors.green; // Couleur du texte pour "En attente"
      case 'Résolu':
        return Colors.red; // Couleur du texte pour "Résolu"
      default:
        return Colors.green; // Couleur par défaut
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
  title: Row(
    children: [
      CircleAvatar(
        backgroundColor: Colors.grey,
        child: Icon(Icons.person, color: Colors.white),
      ),
      const SizedBox(width: 8.0),
      Flexible( // Utilisation de Flexible pour éviter le débordement
        child: Text(
          'Bonjour $_name',
          style: const TextStyle(color: Colors.white),
          overflow: TextOverflow.ellipsis, // Coupe le texte s'il est trop long
        ),
      ),
    ],
  ),
  backgroundColor: const Color(0xFF414780),
  iconTheme: const IconThemeData(color: Colors.white),
  actions: [
    if (_isSearching)
      Container(
        width: 200.0,
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Rechercher...',
            border: OutlineInputBorder(),
            fillColor: Colors.white,
            filled: true,
          ),
        ),
      )
    else
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: _toggleSearch,
      ),
    if (_isSearching)
      IconButton(
        icon: const Icon(Icons.close),
        onPressed: _toggleSearch,
      ),
  ],
),


      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text('Les différentes catégories', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: 8.0),
            Container(
              height: 60.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length + 1, // +1 pour l'option "toutes catégories"
                itemBuilder: (context, index) {
                  final isAllCategoriesOption = index == 0;
                  final Categorie? category = isAllCategoriesOption ? null : _categories[index - 1];
                  final isSelected = category == _selectedCategory;
                  return GestureDetector(
                    onTap: () => _onCategorySelected(category),
                    child: Container(
                      margin: const EdgeInsets.only(right: 20.0),
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF2F3676) : const Color(0xFF414780),
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.white,
                            blurRadius: 4.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          isAllCategoriesOption ? 'Toutes' : category!.libelle,
                          style: const TextStyle(fontSize: 16.0, color: Colors.white),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0),
            Center(
              child: Text('La liste de vos tickets', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  child: _filteredTickets.isEmpty
                      ? Center(
                          child: Text(
                            'Aucun ticket disponible',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: const Color(0xFF414780),
                                  fontSize: 18.0,
                                ),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: _filteredTickets.length,
                          itemBuilder: (context, index) {
                            Ticket ticket = _filteredTickets[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8.0),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  child: Icon(Icons.person, color: Colors.white),
                                ),
                                title: Text(
                                  ticket.status,
                                  style: TextStyle(color: _getTextColor(ticket.status)),
                                ),
                                // subtitle: Text('${ticket.titre}\n${ticket.category}\n${ticket.timestamp.toDate().toLocal()}'),
                                  subtitle: Text('${ticket.titre}\n${ticket.timestamp.toDate().toLocal()}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () {
                                        _showEditTicketDialog(ticket);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Supprimer le ticket'),
                                              content: const Text('Êtes-vous sûr de vouloir supprimer ce ticket ?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('Annuler'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    _deleteTicket(ticket.id);
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('Supprimer'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                isThreeLine: true,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TicketDetailsScreen(ticket: ticket),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF414780), // Couleur d'arrière-plan bleue
                  shape: BoxShape.circle, // Assure que le container est circulaire
                ),
                child: IconButton(
                  icon: const Icon(Icons.add),
                  color: Colors.white, // Couleur de l'icône en blanc
                  onPressed: _showTicketCreationDialog, // Afficher le pop-up ici
                ),
              ),
            ),
          ],
        ),
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
