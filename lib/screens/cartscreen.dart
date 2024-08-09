import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product {
  final String name;
  final double price;
  final String imageUrl;
  int quantity;

  Product({
    required this.name,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });
}

class CartScreen extends StatefulWidget {
  final String userName;
  final String userEmail;

  CartScreen({
    required this.userName,
    required this.userEmail,
  });

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Product> cartItems = [];

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  Future<void> _fetchCartItems() async {
    final response = await http.get(
      Uri.parse(
          'http://localhost:3000/get-cart-items?userEmail=${widget.userEmail}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          cartItems = data
              .map((item) => Product(
                    name: item['product_name'],
                    price: double.tryParse(item['product_price'].toString()) ??
                        0.0,
                    imageUrl:
                        item['image_url'] ?? 'https://via.placeholder.com/150',
                    quantity: item['quantity'],
                  ))
              .toList();
        });
      } catch (e) {
        print('Erro ao processar dados da resposta: $e');
      }
    } else {
      print('Falha ao buscar itens do carrinho.');
    }
  }

  Future<void> _updateQuantity(int index, int newQuantity) async {
    final response = await http.put(
      Uri.parse('http://localhost:3000/update-cart-item'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'userEmail': widget.userEmail,
        'productName': cartItems[index].name,
        'quantity': newQuantity,
      }),
    );

    if (response.statusCode == 200) {
      print('Quantidade atualizada com sucesso!');
    } else {
      print('Falha ao atualizar quantidade.');
    }
  }

  Future<void> _finalizePurchase() async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/finalize-purchase'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'userEmail': widget.userEmail,
        'userName': widget.userName,
        'cartItems': cartItems
            .map((item) => {
                  'name': item.name,
                  'price': item.price,
                  'quantity': item.quantity,
                  'imageUrl': item.imageUrl, // Adiciona o campo imageUrl aqui
                })
            .toList(),
      }),
    );

    if (response.statusCode == 200) {
      print('Compra finalizada com sucesso!');
      setState(() {
        cartItems.clear(); // Limpar o carrinho após finalizar a compra
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Compra Finalizada',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(
              'Obrigado por sua compra!\n\nCarrinho limpo com sucesso!',
              style: TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Compra finalizada com sucesso!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Voltar para a tela anterior
              },
              child: Text('OK',
                  style: TextStyle(fontSize: 16, color: Colors.blue)),
            ),
          ],
        ),
      );
    } else {
      print('Falha ao finalizar compra.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao finalizar compra.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void increaseQuantity(int index) {
    setState(() {
      cartItems[index].quantity++;
      _updateQuantity(index, cartItems[index].quantity);
    });
  }

  void decreaseQuantity(int index) async {
    setState(() {
      if (cartItems[index].quantity > 1) {
        cartItems[index].quantity--;
        _updateQuantity(index, cartItems[index].quantity);
      } else if (cartItems[index].quantity == 1) {
        _removeItem(index);
      }
    });
  }

  Future<void> _removeItem(int index) async {
    final response = await http.delete(
      Uri.parse('http://localhost:3000/remove-from-cart'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'userEmail': widget.userEmail,
        'productName': cartItems[index].name,
      }),
    );

    if (response.statusCode == 200) {
      print('Item removido com sucesso!');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item removido com sucesso!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ),
      );
      setState(() {
        cartItems.removeAt(index);
      });
    } else {
      print('Falha ao remover item.');
    }
  }

  double get cartTotal {
    return cartItems.fold(
        0.0, (total, current) => total + current.price * current.quantity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carrinho de ${widget.userName}',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Text(
                'O carrinho está vazio.',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        elevation: 5,
                        child: ListTile(
                          contentPadding: EdgeInsets.all(10),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              cartItems[index].imageUrl,
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
                          title: Text(cartItems[index].name,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              'R\$ ${cartItems[index].price.toStringAsFixed(2)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove_circle,
                                    color: Colors.red),
                                onPressed: () => decreaseQuantity(index),
                              ),
                              Text('${cartItems[index].quantity}',
                                  style: TextStyle(fontSize: 16)),
                              IconButton(
                                icon:
                                    Icon(Icons.add_circle, color: Colors.green),
                                onPressed: () => increaseQuantity(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total:',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('R\$ ${cartTotal.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 20.0),
                    child: ElevatedButton(
                      onPressed: _finalizePurchase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        textStyle: TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Finalizar Compra',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
