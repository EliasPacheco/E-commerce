import 'dart:async'; // Importar o Timer

import 'package:e_commerce/screens/cartscreen.dart';
import 'package:flutter/material.dart';
import 'package:e_commerce/models/product.dart';
import 'package:e_commerce/services/api_service.dart';
import 'package:e_commerce/card/productcard.dart';

class ProductListScreen extends StatefulWidget {
  final int fornecedor;
  final String title;
  final String name;
  final String email;

  ProductListScreen(
      {required this.fornecedor,
      required this.title,
      required this.name,
      required this.email});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ApiService apiService = ApiService();
  final TextEditingController searchController = TextEditingController();
  List<dynamic> allProducts = [];
  List<dynamic> filteredProducts = [];
  bool isLoading = true;
  int cartItemCount = 0;
  Timer? _timer; // Timer para atualização periódica

  @override
  void initState() {
    super.initState();
    fetchProducts();
    fetchCartItemCount(); // Buscar quantidade de itens no carrinho
    startCartItemCountTimer(); // Iniciar o Timer para atualização periódica

    searchController.addListener(() {
      filterProducts();
    });
  }

  void fetchProducts() async {
    final products = await apiService.fetchProducts(widget.fornecedor);
    setState(() {
      allProducts = products;
      filteredProducts = products;
      isLoading = false;
    });
  }

  void fetchCartItemCount() async {
    final count = await apiService.getCartItemCount(widget.email);
    setState(() {
      cartItemCount = count;
    });
  }

  void startCartItemCountTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      fetchCartItemCount(); // Atualizar a contagem de itens a cada 1 segundo
    });
  }

  void filterProducts() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredProducts = allProducts.where((product) {
        if (widget.fornecedor == 1) {
          return (product as Product1).name.toLowerCase().contains(query);
        } else {
          return (product as Product2).name.toLowerCase().contains(query);
        }
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Buscar produtos...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredProducts.isEmpty
                    ? Center(
                        child: Text(
                          'Nenhum produto disponível',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          if (widget.fornecedor == 1) {
                            final product = filteredProducts[index] as Product1;
                            return ProductCard(
                              imageUrl: product.imagem,
                              name: product.name,
                              description: product.descricao,
                              category: product.categoria,
                              price: product.preco,
                              material: product.material,
                              department: product.departamento,
                              userName: widget.name,
                              userEmail: widget.email,
                            );
                          } else {
                            final product = filteredProducts[index] as Product2;
                            return ProductCard(
                                imageUrl: product.gallery.isNotEmpty
                                    ? product.gallery[0]
                                    : 'https://via.placeholder.com/150',
                                name: product.name,
                                description: product.description,
                                price: double.tryParse(product.price) ?? 0.0,
                                material: product.details['material'] ?? '',
                                adjective: product.details['adjective'],
                                discountValue:
                                    (product.discountValue * 100).toString(),
                                userName: widget.name,
                                userEmail: widget.email);
                          }
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CartScreen(userName: widget.name, userEmail: widget.email,)),
                  );
                },
                backgroundColor: Colors.blue,
                child: const Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                ),
              ),
              if (cartItemCount > 0)
                Positioned(
                  right: 6.0,
                  top: 6.0,
                  child: CircleAvatar(
                    backgroundColor: Colors.red,
                    radius: 10.0,
                    child: Text(
                      "$cartItemCount",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    _timer?.cancel(); // Cancela o Timer ao descartar o widget
    super.dispose();
  }
}
