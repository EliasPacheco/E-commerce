class Product1 {
  final String id;
  final String name;
  final String descricao;
  final String categoria;
  final double preco;
  final String imagem;
  final String material;
  final String departamento;

  Product1({
    required this.id,
    required this.name,
    required this.descricao,
    required this.categoria,
    required this.preco,
    required this.imagem,
    required this.material,
    required this.departamento,
  });

  factory Product1.fromJson(Map<String, dynamic> json) {
    return Product1(
      id: json['id'] ?? '',
      name: json['nome'] ?? '',
      descricao: json['descricao'] ?? '',
      categoria: json['categoria'] ?? '',
      preco: (json['preco'] != null) ? double.tryParse(json['preco']) ?? 0.0 : 0.0,
      imagem: json['imagem'] ?? 'https://via.placeholder.com/150',
      material: json['material'] ?? '',
      departamento: json['departamento'] ?? '',
    );
  }
}

// Para o fornecedor 2
class Product2 {
  final String id;
  final String name;
  final String description;
  final List<String> gallery;
  final String price;
  final double discountValue;
  final Map<String, String> details;

  Product2({
    required this.id,
    required this.name,
    required this.description,
    required this.gallery,
    required this.price,
    required this.discountValue,
    required this.details,
  });

  factory Product2.fromJson(Map<String, dynamic> json) {
    return Product2(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      gallery: List<String>.from(json['gallery'] ?? []),
      price: json['price'] ?? '0.0',
      discountValue: double.tryParse(json['discountValue'] ?? '0.0') ?? 0.0,
      details: {
        'adjective': json['details']['adjective'] ?? '',
        'material': json['details']['material'] ?? '',
      },
    );
  }
}
