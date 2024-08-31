import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Row(
        children: [
          _buildSidebar(context),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildStatisticsSection(),
                  SizedBox(height: 20),
                  _buildSummaryCards(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 200.0,
      color: Colors.grey[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSidebarItem(context, 'Catégories', Icons.category, '/createcategorie'),
          _buildSidebarItem(context, 'Utilisateurs', Icons.people, '/listeusers'),
          _buildSidebarItem(context, 'Rapports', Icons.report, '/reports'),
          _buildSidebarItem(context, 'Revenus', Icons.attach_money, '/revenues'),
          _buildSidebarItem(context, 'Dépenses', Icons.money_off, '/expenses'),
          _buildSidebarItem(context, 'Profil', Icons.person, '/profile'),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(BuildContext context, String title, IconData icon, String route) {
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
          _buildStatCard('Tickets En_cours', '30%', Colors.orange),
          _buildStatCard('Tickets En_attente', '30%', Colors.red),
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
    return Expanded(
      child: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        children: [
          _buildSummaryCard(context, 'Revenus', Icons.attach_money),
          _buildSummaryCard(context, 'Dépenses', Icons.money_off),
        ],
      ),
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
