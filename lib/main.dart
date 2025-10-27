import 'package:flutter/material.dart';

// Importaremos nuestras pantallas aquí
// import 'screens/login_screen.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Commerce App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Dejamos un 'home' temporal. Luego lo cambiaremos por el Login.
      home: const PlaceholderScreen(),
    );
  }
}

// Pantalla temporal solo para asegurarnos de que la app corre
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Commerce App'),
      ),
      body: const Center(
        child: Text('¡App de Flutter funcionando!'),
      ),
    );
  }
}