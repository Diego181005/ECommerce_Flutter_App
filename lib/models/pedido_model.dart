// Modelo para un item individual dentro de un pedido
class PedidoItem {
  final int productoId;
  final String nombreProducto;
  final int cantidad;
  final double precioUnitario;

  PedidoItem({
    required this.productoId,
    required this.nombreProducto,
    required this.cantidad,
    required this.precioUnitario,
  });

  factory PedidoItem.fromJson(Map<String, dynamic> json) {
    return PedidoItem(
      productoId: json['productoId'] ?? 0,
      nombreProducto: json['nombreProducto'] ?? 'Producto no disponible',
      cantidad: json['cantidad'] ?? 0,
      precioUnitario: (json['precioUnitario'] as num? ?? 0.0).toDouble(),
    );
  }
}

// Modelo para el pedido completo
class Pedido {
  final int id;
  final String fechaPedido;
  final double total;
  final List<PedidoItem> items;

  Pedido({
    required this.id,
    required this.fechaPedido,
    required this.total,
    required this.items,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List? ?? [];
    List<PedidoItem> pedidoItems = itemsList.map((i) => PedidoItem.fromJson(i)).toList();

    return Pedido(
      id: json['id'] ?? 0,
      fechaPedido: json['fechaPedido'] ?? 'Fecha desconocida',
      total: (json['total'] as num? ?? 0.0).toDouble(),
      items: pedidoItems,
    );
  }
}