import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductCard extends StatefulWidget {
  final String imageUrl;
  final String name;
  final String description;
  final String? category;
  final double price;
  final String material;
  final String? department;
  final String? adjective;
  final String? discountValue;
  final String userName;
  final String userEmail;

  ProductCard({
    required this.imageUrl,
    required this.name,
    required this.description,
    required this.price,
    required this.material,
    this.category,
    this.department,
    this.adjective,
    this.discountValue,
    required this.userName,
    required this.userEmail,
  });

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int _quantity = 1;

  Future<void> _addToCart() async {
    print(
        'Enviando imagem URL: ${widget.imageUrl}'); // Verifique a URL da imagem

    final response = await http.post(
      Uri.parse('http://localhost:3000/add-to-cart'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'userName': widget.userName,
        'userEmail': widget.userEmail,
        'productName': widget.name,
        'productPrice': widget.price,
        'quantity': _quantity,
        'imageUrl': widget.imageUrl, // Adiciona a URL da imagem
      }),
    );

    if (response.statusCode == 200) {
      print('Item adicionado ao carrinho com sucesso!');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item adicionado ao carrinho com sucesso!'),
          backgroundColor: Colors.green, duration: Duration(seconds: 1),
        ),
      );
    } else {
      print('Falha ao adicionar item ao carrinho.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              widget.imageUrl,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.error,
                    color: Colors.red,
                    size: 50,
                  ),
                );
              },
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                if (widget.category != null)
                  Text(
                    'Categoria: ${widget.category}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                SizedBox(height: 5),
                Text(
                  'Descrição:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  widget.description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                SizedBox(height: 5),
                if (widget.discountValue != null)
                  Text(
                    'Desconto: ${widget.discountValue}%',
                    style: TextStyle(fontSize: 14, color: Colors.red[600]),
                  ),
                SizedBox(height: 5),
                Text(
                  'Preço: \$${widget.price.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  'Material: ${widget.material}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                SizedBox(height: 5),
                if (widget.department != null)
                  Text(
                    'Departamento: ${widget.department}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                SizedBox(height: 5),
                if (widget.adjective != null)
                  Text(
                    'Adjetivo: ${widget.adjective}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                SizedBox(height: 10),
                Center(
                  child: ElevatedButton(
                    onPressed: _addToCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Adicionar ao carrinho',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
