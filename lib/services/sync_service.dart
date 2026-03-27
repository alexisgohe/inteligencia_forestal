import 'dart:convert';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import '../models/registro_forestal.dart';
import 'database_service.dart'; // Tu clase de SQLite

class SyncService {
  // Implementación Singleton
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// URL del Backend
  /// [10.0.2.2] es el alias especial para acceder al localhost de la PC desde el emulador Android.
  /// Si pruebas en iOS Simulator, puedes usar 'localhost'.
  /// Si pruebas en dispositivo físico, usa la IP local de tu PC (ej. '192.168.1.15').
  final String apiUrl = "http://10.0.2.2:8080/api/v1/sync/batch";

  /// Inicializa el escucha de cambios de red para sincronización automática
  void initAutoSync() {
    // Cancelamos suscripción previa si existe para evitar duplicados
    _subscription?.cancel();
    
    _subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      // Si detectamos WiFi o Datos Móviles
      if (results.contains(ConnectivityResult.wifi) || results.contains(ConnectivityResult.mobile)) {
        print("Conexión detectada: Iniciando sincronización automática...");
        sincronizarConBackend();
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
  }

  Future<bool> sincronizarConBackend() async {
    try {
      // 1. Obtener datos locales
      List<RegistroForestal> locales = await DatabaseService.instance.obtenerNoSincronizados();
      
      if (locales.isEmpty) return true;

      // 2. Enviar al backend
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(locales.map((e) => e.toMap()).toList()),
      );

      if (response.statusCode == 200) {
        print("Sincronización exitosa: ${response.body}");
        
        // 3. Marcar registros como sincronizados localmente
        final ids = locales.map((e) => e.id).toList();
        await DatabaseService.instance.marcarComoSincronizados(ids);
        
        return true;
      } else {
        print("Error en el servidor: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error de conexión: $e");
      return false;
    }
  }
}
