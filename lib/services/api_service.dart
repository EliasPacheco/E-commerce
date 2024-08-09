import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  final String baseUrl1 =
      "http://616d6bdb6dacbb001794ca17.mockapi.io/devnology/brazilian_provider";
  final String baseUrl2 =
      "http://616d6bdb6dacbb001794ca17.mockapi.io/devnology/european_provider";

  Future<List<dynamic>> fetchProducts(int fornecedor) async {
    final String url = (fornecedor == 1) ? baseUrl1 : baseUrl2;
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> productsJson = jsonDecode(response.body);
      if (fornecedor == 1) {
        return productsJson.map((json) => Product1.fromJson(json)).toList();
      } else {
        return productsJson.map((json) => Product2.fromJson(json)).toList();
      }
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<int> getCartItemCount(String userEmail) async {
    final response = await http.get(
      Uri.parse(
          'http://localhost:3000/get-cart-item-count?userEmail=$userEmail'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        // Converte para inteiro se for necessário
        return int.tryParse(data['count'].toString()) ?? 0;
      } catch (e) {
        print('Erro ao processar dados da resposta: $e');
        return 0;
      }
    } else {
      print('Falha ao buscar quantidade de itens no carrinho.');
      return 0;
    }
  }
}
