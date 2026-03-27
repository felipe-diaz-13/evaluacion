import 'dart:convert';
import 'package:http/http.dart' as http;

/// Servicio singleton para comunicarse con la API Node.js (crud_mysql)
/// Base URL: http://localhost:3000/api_v1 (ejecución local en Windows/Web)
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // ─── CONFIGURACIÓN ───────────────────────────────────────────────────
  static const String baseUrl = 'http://localhost:3000/api_v1';

  // Credenciales del usuario API (api_users) para token JWT
  static const String _apiUserCredential = 'user@email.com';
  static const String _apiPasswordCredential = '12345678';

  String? _token;                       // JWT del api_user
  Map<String, dynamic>? _loggedUser;    // Datos del usuario logueado (tabla users)

  // ─── TOKEN ───────────────────────────────────────────────────────────
  bool get isAuthenticated => _token != null;
  Map<String, dynamic>? get loggedUser => _loggedUser;

  void clearSession() {
    _token = null;
    _loggedUser = null;
  }

  Map<String, String> get _authHeaders => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      };

  /// Obtiene token JWT del api_user para llamadas protegidas con verifyToken
  Future<void> _fetchApiToken() async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/apiUserLogin'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'api_user': _apiUserCredential,
              'api_password': _apiPasswordCredential,
            }),
          )
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(response.body);
      if (response.statusCode == 200) _token = body['token'];
    } catch (_) {}
  }

  // ─── LOGIN (tabla users) ──────────────────────────────────────────────
  /// Login con usuario o email + contraseña contra la tabla `users`.
  /// Retorna null si fue exitoso, o un mensaje de error si falló.
  Future<String?> login(String userOrEmail, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/userLogin'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'user': userOrEmail,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _loggedUser = body['data'] as Map<String, dynamic>?;
        // Obtener token para llamadas protegidas
        await _fetchApiToken();
        return null;
      } else {
        return body['error'] ?? 'Error al iniciar sesión';
      }
    } catch (e) {
      return 'No se pudo conectar al servidor: $e';
    }
  }

  // ─── REGISTRO (tabla users) ───────────────────────────────────────────
  /// Registra un nuevo usuario en la tabla `users`.
  /// Retorna null si fue exitoso, o un mensaje de error si falló.
  Future<String?> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      // Obtener token si no está disponible
      if (_token == null) await _fetchApiToken();

      final response = await http
          .post(
            Uri.parse('$baseUrl/user'),
            headers: _authHeaders,
            body: jsonEncode({
              'user': username,
              'email': email,
              'password': password,
              'status': 1, // Active
              'role': 2,   // Client
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        return null;
      } else {
        final body = jsonDecode(response.body);
        return body['error'] ?? 'Error al registrar usuario';
      }
    } catch (e) {
      return 'No se pudo conectar al servidor: $e';
    }
  }

  // ─── USER STATUS (tabla user_status) ─────────────────────────────────
  /// Obtiene todos los estados de usuario disponibles en la BD.
  Future<List<Map<String, dynamic>>> getUserStatus() async {
    try {
      if (_token == null) await _fetchApiToken();

      final response = await http
          .get(
            Uri.parse('$baseUrl/userStatus'),
            headers: _authHeaders,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // ─── LIST ALL USERS (tabla users) ────────────────────────────────────
  /// Retorna la lista de todos los usuarios con sus datos.
  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      if (_token == null) await _fetchApiToken();

      final response = await http
          .get(Uri.parse('$baseUrl/user'), headers: _authHeaders)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // ─── UPDATE USER STATUS ───────────────────────────────────────────────
  /// Actualiza el estado (status) de un usuario por su ID.
  /// El endpoint PUT /user/:id requiere { user, status, role }
  Future<String?> updateUserStatus({
    required int userId,
    required String username,
    required int statusId,
    required int roleId,
  }) async {
    try {
      if (_token == null) await _fetchApiToken();

      final response = await http
          .put(
            Uri.parse('$baseUrl/user/$userId'),
            headers: _authHeaders,
            body: jsonEncode({
              'user': username,
              'status': statusId,
              'role': roleId,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) return null;
      final body = jsonDecode(response.body);
      return body['error'] ?? 'Error al actualizar estado';
    } catch (e) {
      return 'No se pudo conectar al servidor: $e';
    }
  }
  // ─── ADD USER STATUS ─────────────────────────────────────────────────────
  /// Registra un nuevo tipo de estado de usuario.
  /// Retorna null si fue exitoso, o un mensaje de error si falló.
  Future<String?> addUserStatus({
    required String name,
    required String description,
  }) async {
    try {
      if (_token == null) await _fetchApiToken();

      final response = await http
          .post(
            Uri.parse('$baseUrl/userStatus'),
            headers: _authHeaders,
            body: jsonEncode({'name': name, 'description': description}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) return null;
      final body = jsonDecode(response.body);
      return body['error'] ?? 'Error al registrar estado';
    } catch (e) {
      return 'No se pudo conectar al servidor: $e';
    }
  }

  // ─── ROLES ─────────────────────────────────────────────────────────────
  /// Obtiene todos los roles disponibles (endpoint público, sin token).
  Future<List<Map<String, dynamic>>> getRoles() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/role'),
              headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Registra un nuevo rol (endpoint público, sin token).
  /// Retorna null si fue exitoso, o un mensaje de error si falló.
  Future<String?> addRole({
    required String name,
    required String description,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/role'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'name': name, 'description': description}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) return null;
      final body = jsonDecode(response.body);
      return body['error'] ?? 'Error al registrar rol';
    } catch (e) {
      return 'No se pudo conectar al servidor: $e';
    }
  }
}
