import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/carrito_provider.dart';
import '../providers/pedido_provider.dart'; // <-- Importar PedidoProvider
import '../models/carrito_model.dart';
import 'pedidos_screen.dart'; // <-- Importar Pantalla de Pedidos

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Carrito'),
      ),
      body: Consumer<CarritoProvider>(
        builder: (context, carritoProvider, child) {
          
          // --- Caso 1: Estamos Cargando ---
          if (carritoProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // --- Caso 2: Hubo un Error ---
          if (carritoProvider.errorMessage != null) {
            return Center(
              child: Text('Error: ${carritoProvider.errorMessage}'),
            );
          }

          // --- Caso 3: Éxito, pero está vacío (o nulo) ---
          final carrito = carritoProvider.carrito;
          if (carrito == null || carrito.items.isEmpty) {
            return const Center(
              child: Text(
                'Tu carrito está vacío.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // --- Caso 4: Éxito, tenemos items ---
          return Column(
            children: [
              // --- Resumen de la Compra (arriba) ---
              Card(
                margin: const EdgeInsets.all(15),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(), // Ocupa el espacio
                      Chip(
                        label: Text(
                          '\$${carrito.total.toStringAsFixed(2)}',
                          style: TextStyle(
                            // --- ¡CORRECCIÓN MATERIAL 3! ---
                            color: Theme.of(context).primaryTextTheme.titleMedium?.color,
                          ),
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      TextButton(
                        // --- LÓGICA DE PAGO (Paso 13) ---
                        onPressed: (carrito.items.isEmpty)
                          ? null // Deshabilita el botón si el carrito está vacío
                          : () async {
                              // Mostrar un diálogo de confirmación
                              final bool? confirmar = await showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Confirmar Pedido'),
                                  content: Text('¿Deseas confirmar tu pedido por un total de \$${carrito.total.toStringAsFixed(2)}?'),
                                  actions: [
                                    TextButton(
                                      child: const Text('Cancelar'),
                                      onPressed: () => Navigator.of(ctx).pop(false),
                                    ),
                                    TextButton(
                                      child: const Text('Confirmar'),
                                      onPressed: () => Navigator.of(ctx).pop(true),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmar != true) {
                                return; // El usuario canceló
                              }
                              
                              // El usuario confirmó, llamamos a los providers
                              if (!context.mounted) return;
                              final pedidoProvider = Provider.of<PedidoProvider>(context, listen: false);
                              final carritoProvider = Provider.of<CarritoProvider>(context, listen: false);

                              try {
                                bool success = await pedidoProvider.crearPedido();
                                
                                if (success && context.mounted) {
                                  // 1. Limpiamos el carrito (actualizándolo)
                                  await carritoProvider.fetchCarrito();
                                  
                                  // 2. Mostramos éxito
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('¡Pedido realizado con éxito!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  
                                  // 3. Navegamos a la pantalla de pedidos
                                  Navigator.of(context).pushReplacementNamed(PedidosScreen.routeName);
                                } else if (!success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: ${pedidoProvider.errorMessage}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } catch (e) {
                                 ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                              }
                          },
                        child: const Text('PAGAR AHORA'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // --- Lista de Items (expandida) ---
              Expanded(
                child: ListView.builder(
                  itemCount: carrito.items.length,
                  itemBuilder: (ctx, i) {
                    // Pasamos cada item al widget auxiliar
                    return CartItemWidget(item: carrito.items[i]);
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }
}


// --- WIDGET AUXILIAR ---
class CartItemWidget extends StatelessWidget {
  final CarritoItem item;
  
  const CartItemWidget({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final carritoProvider = Provider.of<CarritoProvider>(context, listen: false);

    return Dismissible(
      key: ValueKey(item.id), // Clave única
      direction: DismissDirection.endToStart, 
      background: Container(
        // --- ¡CORRECCIÓN MATERIAL 3! ---
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
      ),
      // --- Lógica al deslizar ---
      onDismissed: (direction) {
        carritoProvider.eliminarItem(item.id);
        
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.productoNombre} eliminado del carrito.'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      // --- Confirmación antes de borrar ---
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('¿Estás seguro?'),
            content: Text('¿Quieres eliminar "${item.productoNombre}" del carrito?'),
            actions: [
              TextButton(
                child: const Text('No'),
                onPressed: () {
                  Navigator.of(ctx).pop(false); // No confirmar
                },
              ),
              TextButton(
                child: const Text('Sí'),
                onPressed: () {
                  Navigator.of(ctx).pop(true); // Sí, confirmar
                },
              ),
            ],
          ),
        );
      },

      // --- El contenido visual del item ---
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(item.imageUrl),
              onBackgroundImageError: (exception, stackTrace) {},
              child: ClipOval(
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  width: 50,
                  height: 50,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[200],
                      child: const Icon(Icons.shopping_bag, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
            title: Text(item.productoNombre),
            subtitle: Text('Total: \$${(item.precio * item.cantidad).toStringAsFixed(2)}'),
            trailing: Text('${item.cantidad} x \$${item.precio.toStringAsFixed(2)}'),
          ),
        ),
      ),
    );
  }
}