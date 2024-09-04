import 'package:flutter/material.dart';
import 'package:gestion_des_tickets/modele/tickets.dart';

class TicketDetailsScreen extends StatelessWidget {
  final Ticket ticket;

  TicketDetailsScreen({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ticket.titre),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Affichage du titre du ticket
            Text(
              ticket.titre,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8.0),
            
            // Affichage de la description du ticket
            Text(
              ticket.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 8.0),
            
            // Affichage de la date du ticket
            Text(
              'Date: ${ticket.timestamp.toDate().toLocal()}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 8.0),

            // Affichage du statut du ticket
            Text(
              'Statut: ${ticket.status}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 16.0),

            // Affichage des réponses
            Text(
              'Réponses:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            SizedBox(height: 8.0),
            ticket.responses.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: ticket.responses.entries.map((entry) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 8.0),
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text('${entry.value}'),
                      );
                    }).toList(),
                  )
                : Text(
                    'Réponses non disponibles',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
          ],
        ),
      ),
    );
  }
}
