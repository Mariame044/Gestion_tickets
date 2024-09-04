import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Rediriger vers la page de connexion ou afficher un message
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      // Gérer les erreurs de déconnexion
      print('Error signing out: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Dashboard'),
        leading: MediaQuery.of(context).size.width <= 800
            ? IconButton(
                icon: Icon(Icons.menu),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              )
            : null,
        actions: [
          if (MediaQuery.of(context).size.width > 800)
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                // Ajouter une action de recherche ici
              },
            ),
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              // Ajouter une navigation vers la page de profil ici
              Navigator.of(context).pushNamed('/profile');
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      drawer: MediaQuery.of(context).size.width <= 800 ? _buildDrawer() : null,
      body: Row(
        children: [
          if (MediaQuery.of(context).size.width > 800) _buildSidebar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatisticsSection(),
                  SizedBox(height: 20),
                  Expanded(child: _buildSummaryCards(context)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 200.0,
      color: Colors.grey[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSidebarItem('Catégories', Icons.category, '/createcategorie'),
          _buildSidebarItem('Utilisateurs', Icons.people, '/listeusers'),
          _buildSidebarItem('Rapports', Icons.report, '/reports'),
          _buildSidebarItem('Revenus', Icons.attach_money, '/revenues'),
          _buildSidebarItem('Dépenses', Icons.money_off, '/expenses'),
          _buildSidebarItem('Profil', Icons.person, '/inscription'),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Container(
            color: Colors.grey[200],
            child: ListTile(
              title: Text('Close Menu', textAlign: TextAlign.center),
              trailing: IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem('Catégories', Icons.category, '/createcategorie'),
                _buildDrawerItem('Utilisateurs', Icons.people, '/listeusers'),
                _buildDrawerItem('Rapports', Icons.report, '/reports'),
                _buildDrawerItem('Revenus', Icons.attach_money, '/revenues'),
                _buildDrawerItem('Dépenses', Icons.money_off, '/expenses'),
                _buildDrawerItem('Profil', Icons.person, '/inscription'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(String title, IconData icon, String route) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title, style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500)),
      onTap: () {
        Navigator.of(context).pushNamed(route);
      },
    );
  }

  Widget _buildSidebarItem(String title, IconData icon, String route) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title, style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500)),
      onTap: () {
        Navigator.of(context).pushNamed(route);
      },
    );
  }

  Widget _buildStatisticsSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatCard('Tickets Résolus', '30%', Colors.green),
          _buildStatCard('Tickets En cours', '30%', Colors.orange),
          _buildStatCard('Tickets En attente', '30%', Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String percentage, Color color) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              percentage,
              style: TextStyle(
                fontSize: 24.0,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    return GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width > 800 ? 2 : 1,
      padding: const EdgeInsets.all(16.0),
      crossAxisSpacing: 10.0,
      mainAxisSpacing: 10.0,
      children: [
        _buildSummaryCard(context, 'Revenus', Icons.attach_money),
        _buildSummaryCard(context, 'Dépenses', Icons.money_off),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, IconData icon) {
    return GestureDetector(
      onTap: () {
        // Ajouter une navigation si nécessaire
      },
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 50.0,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(height: 10.0),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
