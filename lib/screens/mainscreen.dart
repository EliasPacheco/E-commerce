import 'package:e_commerce/sign/Login.dart';
import 'package:e_commerce/screens/pedidos.dart';
import 'package:flutter/material.dart';
import 'product_list_screen.dart';

class MainScreen extends StatelessWidget {
  final String name;
  final String email;

  MainScreen({required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            icon: Icon(Icons.logout),
            color: Colors.red,
          )
        ],
      ),
      body: Container(
        color: Colors.white, // Cor de fundo da tela
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Adicionando a imagem acima dos cards
              Image.asset(
                'assets/logo.png',
                width: 350,
                height: 350,
              ),
              SizedBox(height: 20),
              Text(
                "Bem-vindo, $name!",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              SizedBox(height: 20),
              _buildSupplierCard(
                context,
                title: 'Multicoisas',
                icon: Icons.museum_outlined,
                supplierId: 1,
              ),
              SizedBox(height: 20),
              _buildSupplierCard(
                context,
                title: 'Temos Tudo',
                icon: Icons.storefront,
                supplierId: 2,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrdersScreen(
                userName: name,
                userEmail: email,
              ),
            ),
          );
        },
        child: Icon(
          Icons.receipt ,
          color: Colors.white,
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildSupplierCard(BuildContext context,
      {required String title,
      required IconData icon,
      required int supplierId}) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white, // Cor do fundo do Card
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductListScreen(
                fornecedor: supplierId,
                title: title,
                name: name,
                email: email,
              ),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 40,
                color: Colors.blue,
              ),
              SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
