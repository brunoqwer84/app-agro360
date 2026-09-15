import 'grupo.dart';

/// Model de Usuário
/// Corresponde à entidade Usuario do backend
class Usuario {
  final int idUsuario;
  final String nomeUsuario;
  final bool ativo;
  final List<String> roles;
  final int idPessoa;
  final String nomePessoa;
  final Grupo? grupo;
  bool synced; // Flag para controle de sincronização
  DateTime? updatedAt;

  Usuario({
    required this.idUsuario,
    required this.nomeUsuario,
    required this.ativo,
    required this.roles,
    required this.idPessoa,
    required this.nomePessoa,
    this.grupo,
    this.synced = false,
    this.updatedAt,
  });

  /// Cria instância a partir de JSON da API (UsuarioResponse)
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      idUsuario: (json['idUsuario'] as num?)?.toInt() ?? 0,
      nomeUsuario: json['nomeUsuario'] as String? ?? '',
      ativo: json['ativo'] as bool? ?? false,
      roles: (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      idPessoa: (json['idPessoa'] as num?)?.toInt() ?? 0,
      nomePessoa: json['nomePessoa'] as String? ?? '',
      grupo: json['grupo'] != null ? Grupo.fromJson(json['grupo']) : null,
      synced: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Cria instância a partir de banco de dados local (SQLite)
  factory Usuario.fromDatabase(Map<String, dynamic> map) {
    final idGrupo = (map['id_grupo'] as num?)?.toInt();
    return Usuario(
      idUsuario: map['id_usuario'] as int,
      nomeUsuario: map['nome_usuario'] as String,
      ativo: (map['ativo'] as int) == 1,
      roles: [], // Roles serão carregadas em query separada
      idPessoa: map['id_pessoa'] as int,
      nomePessoa: map['nome_pessoa'] as String,
      grupo: idGrupo != null ? Grupo(idGrupo: idGrupo, nome: '', ativo: true) : null,
      synced: (map['synced'] as int?) == 1,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'idUsuario': idUsuario,
      'nomeUsuario': nomeUsuario,
      'ativo': ativo,
      'roles': roles,
      'idPessoa': idPessoa,
      'nomePessoa': nomePessoa,
    };
  }

  /// Converte para Map para salvar no SQLite
  Map<String, dynamic> toDatabase() {
    return {
      'id_usuario': idUsuario,
      'nome_usuario': nomeUsuario,
      'ativo': ativo ? 1 : 0,
      'id_pessoa': idPessoa,
      'nome_pessoa': nomePessoa,
      'id_grupo': grupo?.idGrupo,
      'synced': synced ? 1 : 0,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Verifica se o usuário tem uma role específica
  bool hasRole(String role) {
    return roles.contains(role);
  }

  /// Verifica se o usuário é administrador
  bool get isAdmin => hasRole('ROLE_ADMIN');
}