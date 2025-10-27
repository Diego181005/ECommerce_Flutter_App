import 'dart:async';
import 'dart:convert'; // <-- Arregla el error de 'utf8'
import 'package:http/http.dart' as http;

import '../models/producto_model.dart';
import '../models/carrito_model.dart';
import '../models/pedido_model.dart'; // <-- Arregla el error de 'Pedido'

class ApiService {
  // --- ¡IMPORTANTE! CAMBIA ESTA URL ---
  // Si usas Emulador Android, usa 10.0.2.2 para tu localhost
  // Si tu API corre en el puerto 5023, sería:
  // final String _baseUrl = 'http://10.0.2.2:5023';
  // Si usas Chrome (web), usa:
  final String _baseUrl = 'http://localhost:5023';
  // ---

  // Headers estándar para enviar JSON
  final Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  // --- Endpoint de Auth ---
  Future<String> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/api/Auth/login');

    final body = jsonEncode({
      'Email': email,
      'Password': password,
    });

    try {
      final response = await http.post(url, headers: _headers, body: body)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token'];
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Error al iniciar sesión');
      }
    } on TimeoutException {
      throw Exception('No se pudo conectar al servidor. Intenta de nuevo.');
    } catch (e) {
      throw Exception('Error: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  Future<bool> register(String nombre, String apellido, String email, String password) async {
    final url = Uri.parse('$_baseUrl/api/Auth/register');

    final body = jsonEncode({
      'Nombre': nombre,
      'Apellido': apellido,
      'Email': email,
      'Password': password
    });

    try {
      final response = await http.post(url, headers: _headers, body: body)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return true;
      } else {
        final data = jsonDecode(response.body);
        if (data['errors'] != null) {
            try {
              if (data['errors'] is List) {
                throw Exception(data['errors'][0]['description']);
              }
              if (data['errors']['Password'] != null) {
                throw Exception(data['errors']['Password'][0]);
              }
            } catch (_) {
              throw Exception(data['message'] ?? 'Error de validación desconocido.');
            }
        }
        throw Exception(data['message'] ?? 'Error al registrar usuario.');
      }
    } on TimeoutException {
      throw Exception('No se pudo conectar al servidor. Intenta de nuevo.');
    } catch (e) {
      throw Exception('Error: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }
  
  // --- Endpoint de Productos (Público) ---
  Future<List<Producto>> getProductos() async {
    final url = Uri.parse('$_baseUrl/api/Producto');

    try {
      final response = await http.get(url)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        List<Producto> productos = data
            .map((item) => Producto.fromJson(item))
            .toList();
        return productos;
      } else {
        throw Exception('Error al cargar productos (${response.statusCode})');
      }
    } on TimeoutException {
      throw Exception('No se pudo conectar al servidor.');
    } catch (e) {
      throw Exception('Error: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  // --- ¡ESTE ES EL MÉTODO QUE TE FALTABA! ---
  // Crea headers CON el token de autorización
  Map<String, String> _getAuthHeaders(String token) {
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token', // ¡Así enviamos el token!
    };
  }
  
  // --- Endpoint de Carrito (Protegido) ---

  // 1. OBTENER EL CARRITO
  Future<Carrito> getCarrito(String token) async {
    final url = Uri.parse('$_baseUrl/api/Carrito');
    
    try {
      final response = await http.get(
        url,
        headers: _getAuthHeaders(token), // Usa el método de ayuda
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return Carrito.fromJson(data);
      } else {
        throw Exception('Error al cargar el carrito (${response.statusCode})');
      }
    } on TimeoutException {
      throw Exception('No se pudo conectar al servidor.');
    } catch (e) {
      throw Exception('Error: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  // 2. AÑADIR AL CARRITO
  Future<void> addAlCarrito(String token, int productoId, int cantidad) async {
    final url = Uri.parse('$_baseUrl/api/Carrito/add');
    
    final body = jsonEncode({
      'productoId': productoId,
      'cantidad': cantidad,
    });

    try {
      final response = await http.post(
        url,
        headers: _getAuthHeaders(token), // Usa el método de ayuda
        body: body,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Error al añadir al carrito');
      }
    } on TimeoutException {
      throw Exception('No se pudo conectar al servidor.');
    } catch (e) {
      throw Exception('Error: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  // 3. QUITAR DEL CARRITO
  Future<void> removeDelCarrito(String token, int itemId) async {
    final url = Uri.parse('$_baseUrl/api/Carrito/remove/$itemId');
    
    try {
      final response = await http.delete(
        url,
        headers: _getAuthHeaders(token), // Usa el método de ayuda
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Error al eliminar del carrito');
      }
    } on TimeoutException {
      throw Exception('No se pudo conectar al servidor.');
    } catch (e) {
      throw Exception('Error: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  // --- Endpoint de Pedidos (Protegido) ---

  // 1. OBTENER PEDIDOS
  Future<List<Pedido>> getPedidos(String token) async {
    final url = Uri.parse('$_baseUrl/api/Pedido');
    
    try {
      final response = await http.get(
        url,
        headers: _getAuthHeaders(token), // Usa el método de ayuda
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((item) => Pedido.fromJson(item)).toList();
      } else {
        throw Exception('Error al cargar los pedidos (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  // 2. CREAR PEDIDO (Pagar)
  Future<bool> crearPedido(String token) async {
    final url = Uri.parse('$_baseUrl/api/Pedido');
    
    try {
      final response = await http.post(
        url,
        headers: _getAuthHeaders(token), // Usa el método de ayuda
      ).timeout(const Duration(seconds: 15)); 

      if (response.statusCode == 200) {
        return true;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Error al crear el pedido');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }
}