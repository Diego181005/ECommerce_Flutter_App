import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pedido_provider.dart';
import '../models/pedido_model.dart'; // Importar el modelo

class PedidosScreen extends StatelessWidget {
  static const routeName = '/pedidos';
  const PedidosScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Pedidos'),
      ),
      body: Consumer<PedidoProvider>(
        builder: (context, pedidoProvider, child) {
          
          if (pedidoProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (pedidoProvider.errorMessage != null) {
            return Center(child: Text('Error: ${pedidoProvider.errorMessage}'));
          }

          if (pedidoProvider.pedidos.isEmpty) {
            return const Center(
              child: Text(
                'No has realizado ningún pedido.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // Si tenemos pedidos, los mostramos
          return ListView.builder(
            itemCount: pedidoProvider.pedidos.length,
            itemBuilder: (ctx, i) => PedidoCardItem(pedido: pedidoProvider.pedidos[i]),
          );
        },
      ),
    );
  }
}

// --- Widget Auxiliar para mostrar cada Pedido ---
class PedidoCardItem extends StatefulWidget {
  final Pedido pedido;
  const PedidoCardItem({Key? key, required this.pedido}) : super(key: key);

  @override
  State<PedidoCardItem> createState() => _PedidoCardItemState();
}

class _PedidoCardItemState extends State<PedidoCardItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            title: Text(
              'Total: \$${widget.pedido.total.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Fecha: ${widget.pedido.fechaPedido}'),
            trailing: IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
            ),
          ),
          
          // --- Contenido expandible ---
          if (_expanded)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              height: widget.pedido.items.length * 40.0 + 10, // Altura dinámica
              child: ListView(
                children: widget.pedido.items.map((item) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.nombreProducto,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${item.cantidad} x \$${item.precioUnitario.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    )
                  ],
                )).toList(),
              ),
            )
        ],
      ),
    );
  }
}