import 'package:flutter/material.dart';
const dGreen = Color(0xFF2ac0a6);
const dWhite = Color(0xFFe8f4f2);
const dBlack = Color(0xFF34322f);

class MessagesPage extends StatelessWidget {
  const MessagesPage ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       
      ),
       body: Column(
        
        children: <Widget>[
          // Image en couverture
          Container(
        
            width: double.infinity,
            height: 300,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/reset.png'),
              ),
            ),
          ),
          // const CircleAvatar(
          //   radius: 72.0,
          //   backgroundImage: AssetImage('assets/images/reset.png'),
          // ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Ceci est un exemple d\'image en couverture avec deux boutons.',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          // Les deux boutons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
               onPressed: () {
                  // Naviguer vers la page de connexion
                  Navigator.pushNamed(context, '/login');
                },
                style: const ButtonStyle(
              
                  
  ),
              
                child: const Text('Connexion'),
              ),
             
            ],
          ),
        ],
      ),
    );
  }
}
