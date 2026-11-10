class UsuarioModel {
  final int idUsuario;
  final String nombre;
  final String apellido;
  final String email;
  final String rol;
  final String? descripcion;
  final String? avatar;
  final String? fotoPerfil;
  final int fotoPosX;
  final int fotoPosY;
  final String? fechaRegistro;

  UsuarioModel({
    required this.idUsuario,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.rol,
    this.descripcion,
    this.avatar,
    this.fotoPerfil,
    this.fotoPosX = 50,
    this.fotoPosY = 50,
    this.fechaRegistro,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      idUsuario: int.parse(json['id_usuario'].toString()),
      nombre: json['nombre']?.toString() ?? '',
      apellido: json['apellido']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      rol: json['rol']?.toString() ?? '',
      descripcion: json['descripcion']?.toString(),
      avatar: json['avatar']?.toString(),
      fotoPerfil: json['foto_perfil']?.toString(),
      fotoPosX: int.tryParse(json['foto_pos_x']?.toString() ?? '') ?? 50,
      fotoPosY: int.tryParse(json['foto_pos_y']?.toString() ?? '') ?? 50,
      fechaRegistro: json['fecha_registro']?.toString(),
    );
  }

  String get nombreCompleto {
    return '$nombre $apellido'.trim();
  }

  bool get esAdministrador {
    return rol == 'administrador';
  }

  Map<String, dynamic> toJson() {
    return {
      'id_usuario': idUsuario,
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'rol': rol,
      'descripcion': descripcion,
      'avatar': avatar,
      'foto_perfil': fotoPerfil,
      'foto_pos_x': fotoPosX,
      'foto_pos_y': fotoPosY,
      'fecha_registro': fechaRegistro,
    };
  }
}
