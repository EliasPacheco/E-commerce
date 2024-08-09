import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class Order {
  final String productName;
  final double price;
  final int quantity;
  final DateTime createdAt;
  final String imageUrl;

  Order({
    required this.productName,
    required this.price,
    required this.quantity,
    required this.createdAt,
    required this.imageUrl,
  });

  String get formattedDate {
    return DateFormat('dd/MM/yyyy').format(createdAt);
  }

  String get formattedTime {
    final adjustedTime = createdAt.subtract(Duration(hours: 3));
    return DateFormat('HH:mm').format(adjustedTime);
  }
}

class OrdersScreen extends StatefulWidget {
  final String userName;
  final String userEmail;

  OrdersScreen({
    required this.userName,
    required this.userEmail,
  });

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Order> orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final response = await http.get(
      Uri.parse(
          'http://localhost:3000/get-finalized-orders?userEmail=${widget.userEmail}&userName=${widget.userName}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          orders = data
              .map((item) => Order(
                    productName: item['product_name'],
                    price: double.tryParse(item['price'].toString()) ?? 0.0,
                    quantity: item['quantity'],
                    createdAt: DateTime.parse(item['created_at']),
                    imageUrl:
                        item['image_url'] ?? 'https://via.placeholder.com/150',
                  ))
              .toList();

          // Ordenar os pedidos pela data do último pedido
          orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        });
      } catch (e) {
        print('Erro ao processar dados da resposta: $e');
      }
    } else {
      print('Falha ao buscar pedidos.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meus Pedidos',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: orders.isEmpty
          ? Center(
              child: Text(
                'Nenhum pedido encontrado.',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            )
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  elevation: 5,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(10),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        order.imageUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 100,
                            height: 100,
                            child: Icon(
                              Icons.error,
                              color: Colors.red,
                              size: 50,
                            ),
                          );
                        },
                      ),
                    ),
                    title: Text(order.productName,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        'Preço: R\$ ${order.price.toStringAsFixed(2)}\nQuantidade: ${order.quantity}\nData: ${order.formattedDate}\nHora: ${order.formattedTime}'),
                  ),
                );
              },
            ),
    );
  }
}
