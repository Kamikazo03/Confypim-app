import 'package:flutter/material.dart';

import 'config/app_theme.dart';
import 'core/network/api_client.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ApiClient.instance.initialize();

  runApp(const ConfypimApp());
}

class ConfypimApp extends StatelessWidget {
  const ConfypimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Confypim',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SessionGate(),
    );
  }
}

/// Comprueba si existe una sesión activa antes de mostrar
/// la pantalla de inicio de sesión o la pantalla principal.
class SessionGate extends StatefulWidget {
  const SessionGate({super.key});

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  late final AuthController _authController;
  late Future<bool> _sessionFuture;

  @override
  void initState() {
    super.initState();

    _authController = AuthController();
    _sessionFuture = _authController.restaurarSesion();
  }

  /// Volver a consultar la sesión.
  void _reintentar() {
    setState(() {
      _sessionFuture = _authController.restaurarSesion();
    });
  }

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _sessionFuture,
      builder: (context, snapshot) {
        // Mientras se consulta la sesión, mostramos una
        // pantalla de carga para evitar mostrar el login
        // innecesariamente.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SessionLoadingScreen();
        }

        // Si la consulta terminó correctamente y existe
        // una sesión activa, mostramos la pantalla principal.
        if (snapshot.hasData && snapshot.data == true) {
          final usuario = _authController.usuario;

          if (usuario != null) {
            return InicioPruebaScreen(usuario: usuario);
          }
        }

        // Si no existe sesión, mostramos el login.
        if (snapshot.hasData && snapshot.data == false) {
          return const LoginScreen();
        }

        // Si hubo un problema de conexión u otro error,
        // permitimos reintentar sin borrar las cookies.
        if (snapshot.hasError) {
          return _SessionErrorScreen(
            mensaje: snapshot.error.toString().replaceFirst('Exception: ', ''),
            onReintentar: _reintentar,
          );
        }

        return const _SessionLoadingScreen();
      },
    );
  }
}

/// Pantalla temporal mientras se verifica la sesión.
class _SessionLoadingScreen extends StatelessWidget {
  const _SessionLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Comprobando sesión...', style: TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

/// Pantalla de error cuando no es posible comprobar
/// la sesión por problemas de comunicación.
class _SessionErrorScreen extends StatelessWidget {
  final String mensaje;
  final VoidCallback onReintentar;

  const _SessionErrorScreen({
    required this.mensaje,
    required this.onReintentar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 56,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'No pudimos comprobar tu sesión',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(mensaje, textAlign: TextAlign.center),
              const SizedBox(height: 22),
              ElevatedButton.icon(
                onPressed: onReintentar,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
