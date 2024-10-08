import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gestion_des_tickets/pages/DAS.dart';
import 'package:gestion_des_tickets/pages/connexion.dart';
import 'package:gestion_des_tickets/pages/cover.dart';
import 'package:gestion_des_tickets/pages/createcategorie.dart';
import 'package:gestion_des_tickets/pages/dashbord.dart';
import 'package:gestion_des_tickets/pages/discussion.dart';
import 'package:gestion_des_tickets/pages/homepage.dart';
import 'package:gestion_des_tickets/pages/inscription.dart';
import 'package:gestion_des_tickets/pages/formateur.dart'; // Importez les pages
import 'package:gestion_des_tickets/pages/listeusers.dart';

import 'package:gestion_des_tickets/pages/chat.dart';
import 'package:gestion_des_tickets/pages/profile.dart';
import 'package:gestion_des_tickets/pages/settings.dart';
import 'package:gestion_des_tickets/pages/tickets.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const Cover(),
//     );
//   }
// }
      @override
        Widget build(BuildContext context) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            initialRoute: '/',
            routes: {
              '/': (context) => const Cover(),
              '/login': (context) => LoginPage(),
               '/inscription': (context) => inscription(), // Route vers la page de connexion
              '/home': (context) => HomePage(), // Route vers la page d'accueil
               '/formateur': (context) => Formateur(), // Route vers la page d'accueil
                '/listeusers': (context) => UserListPage(),
                  '/createcategorie': (context) => CategoriePage(),
                  '/dashbord': (context) => AdminDashboard(),
                   '/DAS': (context) =>  Dashboard(),
                 
                 
                    '/discussion': (context) => DiscussionsScreen(),
                  '/settings': (context) => const SettingsPage(),
                  '/profile': (context) => const UserProfilePage(),// Route vers la page d'accueil
                  // '/tickets': (context) => TicketCreationScreen() // Route vers la page d'accueil
             
              
            },
            
          );
        }
      }
      

// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:gestion_des_tickets/pages/cover.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: Cover(),
//     );
//   }
// }
