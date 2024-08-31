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
        title: const Text('Catégories'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _libelleController,
              decoration: const InputDecoration(labelText: 'Libellé'),
            ),
          ),
          ElevatedButton(
            onPressed: _addCategorie,
            child: const Text('Ajouter Catégorie'),
          ),
          Expanded(
            child: FutureBuilder<List<Categorie>>(
              future: _categorieService.getCategories(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final categories = snapshot.data!;
                return ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final categorie = categories[index];
                    return ListTile(
                      title: Text(categorie.libelle),
                      onTap: () {
                        // Action lors du clic sur une catégorie
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
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
}
