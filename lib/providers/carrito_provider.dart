import 'package:flutter/material.dart';
import '../models/carrito_model.dart';
import '../services/api_service.dart';
import 'auth_provider.dart'; // Importante para obtener el token

class CarritoProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  AuthProvider? _authProvider; // Para guardar la referencia de Auth

  Carrito? _carrito;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Carrito? get carrito => _carrito;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get itemCount => _carrito?.items.length ?? 0;

  // Constructor
  CarritoProvider(this._authProvider) {
    // Si ya estamos logueados al iniciar, busca el carrito
    if (_authProvider != null && _authProvider!.isAuthenticated) {
      fetchCarrito();
    }
  }

  // Método especial para actualizar la referencia de AuthProvider
  // (Lo usaremos en main.dart)
  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
    if (_authProvider!.isAuthenticated) {
      fetchCarrito(); // Carga el carrito automáticamente al hacer login
    } else {
      _carrito = null; // Limpia el carrito al hacer logout
      notifyListeners();
    }
  }

  // Helper para obtener el token de forma segura
  String? get _token {
    return _authProvider?.token;
  }

  // --- MÉTODOS PRINCIPALES ---

  Future<void> fetchCarrito() async {
    if (_token == null) return; // No hay token, no podemos buscar

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _carrito = await _apiService.getCarrito(_token!);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> agregarProducto(int productoId) async {
    if (_token == null) {
      _errorMessage = "Debes iniciar sesión";
      notifyListeners();
      return false;
    }

    try {
      // Llama a la API para añadir
      await _apiService.addAlCarrito(_token!, productoId, 1);
      
      // Si tiene éxito, vuelve a cargar el carrito para mostrar el cambio
      await fetchCarrito(); 
      return true;

    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
      notifyListeners();
      return false;
    }
  }

  Future<void> eliminarItem(int itemId) async {
    if (_token == null) return;

    try {
      // Llama a la API para eliminar
      await _apiService.removeDelCarrito(_token!, itemId);
      
      // Si tiene éxito, vuelve a cargar el carrito
      await fetchCarrito(); 
      
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
      notifyListeners();
    }
  }
}