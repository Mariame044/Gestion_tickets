import 'package:flutter/material.dart';
import 'package:gestion_des_tickets/modele/categorie.dart';
import 'package:gestion_des_tickets/services/categorieService.dart';

class CategoriePage extends StatefulWidget {
  @override
  _CategoriePageState createState() => _CategoriePageState();
}

class _CategoriePageState extends State<CategoriePage> {
  final CategorieService _categorieService = CategorieService();
  final _libelleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des catégories'),
        backgroundColor: Color(0xFF365FA4), // Couleur de fond de l'AppBar
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => _showAddCategorieDialog(),
              child: const Text('+ Ajouter Catégorie'),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Categorie>>(
              future: _categorieService.getCategories(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final categories = snapshot.data!;
                return DataTable(
                  columns: const [
                    DataColumn(label: Text('Numéro')),
                    DataColumn(label: Text('Catégorie')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: List.generate(
                    categories.length,
                    (index) {
                      final categorie = categories[index];
                      return DataRow(
                        cells: [
                          DataCell(Text((index + 1).toString())),
                          DataCell(Text(categorie.libelle)),
                          DataCell(
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _deleteCategorie(categorie.id);
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCategorieDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajouter une catégorie'),
          content: TextField(
            controller: _libelleController,
            decoration: const InputDecoration(labelText: 'Libellé'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                _addCategorie();
                Navigator.of(context).pop();
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  void _addCategorie() async {
    final libelle = _libelleController.text.trim();
    if (libelle.isNotEmpty) {
      final categorie = Categorie(id: '', libelle: libelle);
      try {
        await _categorieService.addCategorie(categorie);
        setState(() {
          _libelleController.clear();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le libellé ne peut pas être vide')),
      );
    }
  }

  void _deleteCategorie(String id) async {
    try {
      await _categorieService.deleteCategorie(id);
      setState(() {}); // Met à jour l'état pour rafraîchir la liste
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}
