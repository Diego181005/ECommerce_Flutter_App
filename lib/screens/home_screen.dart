import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/producto_provider.dart';
import '../providers/carrito_provider.dart'; // <-- 1. IMPORTAR
import '../models/producto_model.dart';
import 'cart_screen.dart'; // <-- 1. AÑADE ESTE IMPORT
import 'pedidos_screen.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        actions: [
          // --- ¡NUEVO BOTÓN DE PEDIDOS! ---
      IconButton(
        icon: const Icon(Icons.history),
        tooltip: 'Mis Pedidos',
        onPressed: () {
          Navigator.of(context).pushNamed(PedidosScreen.routeName);
        },
      ),
      // --- FIN DEL BOTÓN ---
          // --- ¡NUEVO WIDGET DE CARRITO! ---
          Consumer<CarritoProvider>(
            builder: (ctx, carrito, child) => Badge(
              label: Text(carrito.itemCount.toString()),
              isLabelVisible: carrito.itemCount > 0,
              child: child,
            ),
            // 'child' es el IconButton, no se reconstruye
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                // TODO: Navegar a CartScreen
                // Navigator.of(context).pushNamed(CartScreen.routeName);
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
          // --- FIN DEL WIDGET ---

          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
            },
          ),
        ],
      ),
      body: Consumer<ProductoProvider>(
        builder: (context, productoProvider, child) {
          
          if (productoProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (productoProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${productoProvider.errorMessage}'),
                  ElevatedButton(
                    onPressed: () => productoProvider.fetchProductos(),
                    child: const Text('Reintentar'),
                  )
                ],
              ),
            );
          }
          
          if (productoProvider.productos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No hay productos disponibles.'),
                  ElevatedButton(
                    onPressed: () => productoProvider.fetchProductos(),
                    child: const Text('Volver a cargar'),
                  )
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: productoProvider.productos.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (ctx, i) {
              final producto = productoProvider.productos[i];
              // Pasamos el producto al widget de item
              return ProductGridItem(producto: producto);
            },
          );
        },
      ),
    );
  }
}

// --- WIDGET DE TARJETA DE PRODUCTO (ACTUALIZADO) ---
class ProductGridItem extends StatelessWidget {
  const ProductGridItem({
    Key? key,
    required this.producto,
  }) : super(key: key);

  final Producto producto;

  @override
  Widget build(BuildContext context) {
    // Escuchamos al CarritoProvider
    final carritoProvider = Provider.of<CarritoProvider>(context, listen: false);
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            // TODO: Navegar a la pantalla de detalle del producto
            print('Tocado producto: ${producto.nombre}');
          },
          child: Image.network(
            producto.imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (ctx, child, progress) {
              if (progress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (ctx, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
              );
            },
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          title: Text(
            producto.nombre,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
          subtitle: Text(
            '\$${producto.precio.toStringAsFixed(2)}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.add_shopping_cart),
            
            // --- ¡AQUÍ ESTÁ LA NUEVA LÓGICA! ---
            onPressed: () async {
              // Llama al provider para añadir al carrito
              bool success = await carritoProvider.agregarProducto(producto.id);
              
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${producto.nombre} añadido al carrito!'),
                    duration: const Duration(seconds: 2),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (!success && context.mounted) {
                // Muestra el error de la API (ej. "Stock insuficiente")
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${carritoProvider.errorMessage}'),
                    duration: const Duration(seconds: 2),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
  }
}