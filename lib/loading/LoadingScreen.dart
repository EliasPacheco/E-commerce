import 'dart:async';

import 'package:e_commerce/loading/welcome.dart';
import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    
    // Configura um temporizador de 5 segundos
    Timer(Duration(seconds: 3), () {
      // Navega para a tela de login após 5 segundos
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Imagem no centro
            Image.asset(
              'assets/logo.png', // Substitua pelo caminho da sua imagem
              width: 350,
              height: 350,
            ),
            SizedBox(height: 40),
            // Indicador de carregamento
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // Cor do indicador
            ),
          ],
        ),
      ),
    );
  }
}
