import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/producto_provider.dart';
import 'providers/carrito_provider.dart';
import 'providers/pedido_provider.dart'; // <-- AÑADE ESTA LÍNEA

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/pedidos_screen.dart';
import 'screens/splash_screen.dart'; // <-- 1. IMPORTAR SPLASH

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider independiente
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // Provider independiente
        ChangeNotifierProvider(create: (_) => ProductoProvider()),

        // Provider dependiente
        ChangeNotifierProxyProvider<AuthProvider, CarritoProvider>(
          create: (ctx) => CarritoProvider(null),
          update: (ctx, auth, previousCarrito) {
            previousCarrito!.updateAuth(auth);
            return previousCarrito;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, PedidoProvider>(
      create: (ctx) => PedidoProvider(null),
      update: (ctx, auth, previous) => previous!..updateAuth(auth),
    ),
      ],
      child: MaterialApp(
        title: 'E-Commerce App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.purple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          colorScheme: ThemeData().colorScheme.copyWith(
                secondary: Colors.deepOrange,
              ),
        ),

        // --- ¡AQUÍ ESTÁ LA NUEVA LÓGICA DE INICIO! ---
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            // Si ya estamos autenticados (por un reinicio en caliente)
            if (auth.isAuthenticated) {
              return const HomeScreen();
            }
            
            // Si no, intentamos el auto-login
            return FutureBuilder(
              future: auth.tryAutoLogin(),
              builder: (ctx, authResultSnapshot) {
                // Mientras está revisando (mostramos la pantalla de carga)
                if (authResultSnapshot.connectionState == ConnectionState.waiting) {
                  return const SplashScreen();
                }

                // Cuando termina:
                // Si el auto-login funcionó (snapshot.data == true)
                if (authResultSnapshot.data == true) {
                  return const HomeScreen();
                }
                
                // Si el auto-login falló (snapshot.data == false)
                return const LoginScreen();
              },
            );
          },
        ),
        // --- FIN DE LA LÓGICA DE INICIO ---

        // Rutas para navegar
        routes: {
          LoginScreen.routeName: (ctx) => const LoginScreen(),
          RegisterScreen.routeName: (ctx) => const RegisterScreen(),
          HomeScreen.routeName: (ctx) => const HomeScreen(),
          CartScreen.routeName: (ctx) => const CartScreen(),
          PedidosScreen.routeName: (ctx) => const PedidosScreen(),
        },
      ),
    );
  }
}