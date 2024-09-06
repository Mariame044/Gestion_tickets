import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tickets'),
        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: () {}),
          IconButton(icon: Icon(Icons.account_circle), onPressed: () {}),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
              decoration: BoxDecoration(color: Colors.blue),
            ),
            ListTile(title: Text('Dashboard'), onTap: () {}),
            ListTile(title: Text('Catégorie'), onTap: () {}),
            ListTile(title: Text('Utilisateurs'), onTap: () {}),
            ListTile(title: Text('Profile'), onTap: () {}),
            ListTile(title: Text('Settings'), onTap: () {}),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                StatisticCard(title: 'Tickets résolu', percentage: '30%'),
                StatisticCard(title: 'Tickets en cours', percentage: '30%'),
                StatisticCard(title: 'Tickets en attente', percentage: '30%'),
              ],
            ),
            SizedBox(height: 20),
            Text('Rapports', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Expanded(child: ReportsChart()),
          ],
        ),
      ),
    );
  }
}

class StatisticCard extends StatelessWidget {
  final String title;
  final String percentage;

  StatisticCard({required this.title, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.grey, blurRadius: 5.0, spreadRadius: 2.0),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontSize: 16)),
          SizedBox(height: 8),
          Text(percentage, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class ReportsChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.grey, blurRadius: 5.0, spreadRadius: 2.0),
        ],
      ),
      child: Center(child: Text('Graphique des rapports ici')),
    );
  }
}