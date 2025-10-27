import 'package:flutter/material.dart';
import '../models/pedido_model.dart';
import '../services/api_service.dart';
import 'auth_provider.dart'; // Para obtener el token

class PedidoProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  AuthProvider? _authProvider;

  List<Pedido> _pedidos = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Pedido> get pedidos => _pedidos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Constructor
  PedidoProvider(this._authProvider) {
    if (_authProvider != null && _authProvider!.isAuthenticated) {
      fetchPedidos();
    }
  }

  // Método para actualizar la referencia de AuthProvider
  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
    if (_authProvider!.isAuthenticated) {
      fetchPedidos();
    } else {
      _pedidos = []; // Limpia los pedidos al hacer logout
      notifyListeners();
    }
  }

  String? get _token {
    return _authProvider?.token;
  }

  // --- MÉTODOS PRINCIPALES ---

  Future<void> fetchPedidos() async {
    if (_token == null) return; 

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _pedidos = await _apiService.getPedidos(_token!);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> crearPedido() async {
    if (_token == null) {
      _errorMessage = "Debes iniciar sesión";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.crearPedido(_token!);
      // Si tiene éxito, volvemos a cargar la lista de pedidos
      await fetchPedidos(); 
      
      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}