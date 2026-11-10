import 'package:flutter/material.dart';

import '../../../config/app_theme.dart';
import '../../../data/models/usuario_model.dart';
import '../controllers/auth_controller.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../ventas/screens/ventas_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController _controller = AuthController();

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _mostrarPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _controller.dispose();

    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final correcto = await _controller.iniciarSesion(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (correcto && _controller.usuario != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => InicioPruebaScreen(usuario: _controller.usuario!),
        ),
      );
    } else {
      _mostrarMensaje(
        _controller.error ?? 'No fue posible iniciar sesión.',
        esError: true,
      );
    }
  }

  void _mostrarMensaje(String mensaje, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 28),

                      // Identidad de la aplicación.
                      Container(
                        alignment: Alignment.center,
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(26),
                          ),
                          child: const Icon(
                            Icons.cake_outlined,
                            size: 48,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      const Text(
                        'Confypim',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Gestión de tu negocio, en un solo lugar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Formulario.
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.035),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Bienvenido',
                                style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.text,
                                ),
                              ),

                              const SizedBox(height: 7),

                              const Text(
                                'Ingresa tus credenciales para continuar.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),

                              const SizedBox(height: 26),

                              const Text(
                                'Correo electrónico',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text,
                                  fontSize: 13,
                                ),
                              ),

                              const SizedBox(height: 9),

                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autocorrect: false,
                                decoration: const InputDecoration(
                                  hintText: 'correo@ejemplo.com',
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: AppColors.secondary,
                                  ),
                                ),
                                validator: (value) {
                                  final email = value?.trim() ?? '';

                                  if (email.isEmpty) {
                                    return 'Ingresa tu correo electrónico.';
                                  }

                                  if (!RegExp(
                                    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                  ).hasMatch(email)) {
                                    return 'Ingresa un correo válido.';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 20),

                              const Text(
                                'Contraseña',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text,
                                  fontSize: 13,
                                ),
                              ),

                              const SizedBox(height: 9),

                              TextFormField(
                                controller: _passwordController,
                                obscureText: !_mostrarPassword,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) {
                                  if (!_controller.cargando) {
                                    _iniciarSesion();
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: 'Ingresa tu contraseña',
                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
                                    color: AppColors.secondary,
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _mostrarPassword = !_mostrarPassword;
                                      });
                                    },
                                    icon: Icon(
                                      _mostrarPassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingresa tu contraseña.';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 28),

                              ElevatedButton(
                                onPressed: _controller.cargando
                                    ? null
                                    : _iniciarSesion,
                                child: _controller.cargando
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Iniciar sesión'),
                              ),

                              if (_controller.error != null) ...[
                                const SizedBox(height: 16),
                                Text(
                                  _controller.error!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.error,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      const Text(
                        'Confypim · Aplicación móvil',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Pantalla provisional para comprobar que el login funciona.
// Más adelante será reemplazada por el módulo principal de Ventas.

class InicioPruebaScreen extends StatelessWidget {
  final UsuarioModel usuario;

  const InicioPruebaScreen({
    super.key,
    required this.usuario,
  });

  Future<void> _cerrarSesion(BuildContext context) async {
    try {
      await AuthRepository().cerrarSesion();
    } catch (_) {}

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  void _abrirVentas(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const VentasScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Confypim',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () => _cerrarSesion(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            '¡Bienvenida!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hola, ${usuario.nombreCompleto}.',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),

          // Acceso al módulo de ventas.
          Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _abrirVentas(context),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.point_of_sale_outlined,
                        color: AppColors.primaryDark,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ventas',
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Consultar ventas, revisar pedidos '
                            'y registrar nuevas ventas.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.primaryDark,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Información de la sesión.
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sesión actual',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    usuario.nombreCompleto,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    usuario.email,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}