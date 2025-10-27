import 'package:flutter/material.dart';
import '../models/producto_model.dart';
import '../services/api_service.dart';

class ProductoProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Producto> _productos = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters para que la UI pueda leer el estado
  List<Producto> get productos => _productos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Constructor: Carga los productos apenas se crea el provider
  ProductoProvider() {
    fetchProductos();
  }

  // Método para cargar los productos desde la API
  Future<void> fetchProductos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Notifica a la UI que "estamos cargando"

    try {
      _productos = await _apiService.getProductos();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
    }

    _isLoading = false;
    notifyListeners(); // Notifica que terminamos (con datos o con error)
  }
}
