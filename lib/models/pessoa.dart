import 'endereco_pessoa.dart';
import 'grupo.dart';

/// Model de Pessoa (Clientes, Fornecedores e Contatos)
/// Corresponde à entidade Pessoa do backend no módulo financeiro/cadastros
class Pessoa {
  final int idPessoa;
  final String nome;
  final String cpfCnpj;
  final String? fone;
  final String? email;
  final bool ativo;
  final String tipo; // 'C' (Cliente), 'F' (Fornecedor), 'A' (Ambos)
  final Grupo? grupo;
  final EnderecoPessoa? endereco;
  bool synced;
  DateTime? updatedAt;

  Pessoa({
    required this.idPessoa,
    required this.nome,
    required this.cpfCnpj,
    this.fone,
    this.email,
    required this.ativo,
    this.tipo = 'A',
    this.grupo,
    this.endereco,
    this.synced = false,
    this.updatedAt,
  });

  /// Verifica se é cliente (ou ambos)
  bool get isCliente => tipo == 'C' || tipo == 'A';

  /// Verifica se é fornecedor (ou ambos)
  bool get isFornecedor => tipo == 'F' || tipo == 'A';

  /// Verifica se atua em ambos os papéis
  bool get isAmbos => tipo == 'A';

  /// Descrição amigável do papel/tipo
  String get tipoDescricao {
    switch (tipo.toUpperCase()) {
      case 'C':
        return 'Cliente';
      case 'F':
        return 'Fornecedor';
      case 'A':
      default:
        return 'Cliente e Fornecedor';
    }
  }

  /// Cria instância a partir de JSON da API
  factory Pessoa.fromJson(Map<String, dynamic> json) {
    return Pessoa(
      idPessoa: (json['idPessoa'] as num).toInt(),
      nome: json['nome'] as String? ?? '',
      cpfCnpj: json['cpfCnpj'] as String? ?? '',
      fone: json['fone'] as String?,
      email: json['email'] as String?,
      ativo: json['ativo'] as bool? ?? true,
      tipo: (json['tipo'] as String?)?.toUpperCase() ?? 'A',
      grupo: json['grupo'] != null
          ? Grupo.fromJson(json['grupo'] as Map<String, dynamic>)
          : null,
      endereco: json['endereco'] != null
          ? EnderecoPessoa.fromJson(json['endereco'] as Map<String, dynamic>)
          : null,
      synced: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Cria instância a partir de banco de dados local (SQLite)
  factory Pessoa.fromDatabase(Map<String, dynamic> map) {
    return Pessoa(
      idPessoa: map['id_pessoa'] as int,
      nome: map['nome'] as String,
      cpfCnpj: map['cpf_cnpj'] as String,
      fone: map['fone'] as String?,
      email: map['email'] as String?,
      ativo: (map['ativo'] as int) == 1,
      tipo: (map['tipo'] as String?)?.toUpperCase() ?? 'A',
      grupo: map['id_grupo'] != null
          ? Grupo(idGrupo: map['id_grupo'] as int, nome: '', ativo: true)
          : null,
      synced: (map['synced'] as int?) == 1,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  /// Converte para JSON para envio na API
  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'cpfCnpj': cpfCnpj,
      if (fone != null && fone!.trim().isNotEmpty) 'fone': fone!.trim(),
      if (email != null && email!.trim().isNotEmpty) 'email': email!.trim(),
      'ativo': ativo,
      'tipo': tipo,
      if (endereco != null && endereco!.hasEndereco)
        'endereco': endereco!.toJson(),
    };
  }

  /// Converte para Map para salvar no SQLite
  Map<String, dynamic> toDatabase() {
    return {
      'id_pessoa': idPessoa,
      'nome': nome,
      'cpf_cnpj': cpfCnpj,
      'fone': fone,
      'email': email,
      'ativo': ativo ? 1 : 0,
      'tipo': tipo,
      'id_grupo': grupo?.idGrupo,
      'synced': synced ? 1 : 0,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Cria cópia alterando campos específicos
  Pessoa copyWith({
    int? idPessoa,
    String? nome,
    String? cpfCnpj,
    String? fone,
    String? email,
    bool? ativo,
    String? tipo,
    Grupo? grupo,
    EnderecoPessoa? endereco,
    bool? synced,
    DateTime? updatedAt,
  }) {
    return Pessoa(
      idPessoa: idPessoa ?? this.idPessoa,
      nome: nome ?? this.nome,
      cpfCnpj: cpfCnpj ?? this.cpfCnpj,
      fone: fone ?? this.fone,
      email: email ?? this.email,
      ativo: ativo ?? this.ativo,
      tipo: tipo ?? this.tipo,
      grupo: grupo ?? this.grupo,
      endereco: endereco ?? this.endereco,
      synced: synced ?? this.synced,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
