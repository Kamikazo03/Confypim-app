class ApiConfig {
  ApiConfig._();

  // Dirección del servidor remoto de producción en Railway.
  static const String baseUrl = 'https://confypim.up.railway.app/';

  // Endpoints existentes del proyecto PHP.
  static const String auth = 'ajax/auth.php';
  static const String ventas = 'ajax/venta.php';
  static const String productos = 'ajax/producto.php';

  // Tiempo máximo de espera de las solicitudes.
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration sendTimeout = Duration(seconds: 15);
}