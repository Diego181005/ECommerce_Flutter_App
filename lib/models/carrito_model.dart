// Modelo para un item individual dentro del carrito
class CarritoItem {
  final int id;
  final int productoId;
  final String productoNombre;
  final double precio;
  final int cantidad;
  final String imageUrl;

  CarritoItem({
    required this.id,
    required this.productoId,
    required this.productoNombre,
    required this.precio,
    required this.cantidad,
    required this.imageUrl,
  });

  // --- FÁBRICA CORREGIDA (CON camelCase) ---
  factory CarritoItem.fromJson(Map<String, dynamic> json) {
    return CarritoItem(
      // Busca 'id' (minúscula) y usa '?? 0' por si es nulo
      id: json['id'] ?? 0, 
      productoId: json['productoId'] ?? 0,
      productoNombre: json['productoNombre'] ?? 'Producto sin nombre',
      precio: (json['precio'] as num? ?? 0.0).toDouble(),
      cantidad: json['cantidad'] ?? 0,
      imageUrl: json['imageUrl'] ?? 'https://placehold.co/600x400/EEE/B9B9B9?text=Sin+Imagen',
    );
  }
}

// Modelo para el carrito completo
class Carrito {
  final int id;
  final String userId;
  final double total;
  final List<CarritoItem> items;

  Carrito({
    required this.id,
    required this.userId,
    required this.total,
    required this.items,
  });

  // --- FÁBRICA CORREGIDA (CON camelCase) ---
  factory Carrito.fromJson(Map<String, dynamic> json) {
    // Busca 'items' (minúscula) y protege de nulos
    var itemsList = json['items'] as List? ?? []; 
    List<CarritoItem> carritoItems = itemsList.map((i) => CarritoItem.fromJson(i)).toList();

    return Carrito(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? '',
      total: (json['total'] as num? ?? 0.0).toDouble(),
      items: carritoItems,
    );
  }
}