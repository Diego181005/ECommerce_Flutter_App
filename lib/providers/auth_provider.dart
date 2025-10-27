import 'dart:async'; // Para el Timer
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- IMPORTAR
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  String? _token;
  // Timer _authTimer; // (Lo usaremos si implementamos expiración)

  String _errorMessage = 'Ocurrió un error';
  
  // Getters
  bool get isAuthenticated {
    return _token != null;
  }

  String? get token {
    return _token;
  }

  String get errorMessage {
    return _errorMessage;
  }

  // --- MÉTODOS DE LOGIN / REGISTER ---

  Future<bool> login(String email, String password) async {
    try {
      final token = await _apiService.login(email, password);
      _token = token;
      
      // --- ¡NUEVO! Guardamos el token en el dispositivo ---
      await _saveTokenToPrefs(token);

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String nombre, String apellido, String email, String password) async {
    try {
      await _apiService.register(nombre, apellido, email, password);
      // No hacemos login automático, el usuario debe iniciar sesión
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
      notifyListeners();
      return false;
    }
  }

  // --- MÉTODOS DE LOGOUT Y AUTO-LOGIN ---

  Future<void> logout() async {
    _token = null;
    
    // --- ¡NUEVO! Borramos el token del dispositivo ---
    await _clearTokenFromPrefs();
    
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    // Busca en el almacenamiento del dispositivo
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userToken')) {
      return false; // No hay token guardado
    }

    final savedToken = prefs.getString('userToken');
    if (savedToken == null) {
      return false;
    }

    // (Aquí iría la lógica para validar si el token expiró)
    // Por ahora, si existe, confiamos en él.

    _token = savedToken;
    notifyListeners();
    return true;
  }

  // --- MÉTODOS PRIVADOS DE AYUDA ---

  Future<void> _saveTokenToPrefs(String token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('userToken', token);
  }

  Future<void> _clearTokenFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userToken');
  }
}