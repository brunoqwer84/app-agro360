/// Model de Endereço de Pessoa (opcional)
/// Corresponde à tabela endereco_pessoa vinculada ao cadastro de Pessoa
class EnderecoPessoa {
  final int? idEnderecoPessoa;
  final String? cep;
  final String? logradouro;
  final String? numero;
  final String? complemento;
  final String? bairro;
  final String? cidade;
  final String? uf;
  final String? enderecoCompleto;

  EnderecoPessoa({
    this.idEnderecoPessoa,
    this.cep,
    this.logradouro,
    this.numero,
    this.complemento,
    this.bairro,
    this.cidade,
    this.uf,
    this.enderecoCompleto,
  });

  /// Verifica se possui ao menos um campo de endereço preenchido
  bool get hasEndereco {
    return (cep != null && cep!.trim().isNotEmpty) ||
        (logradouro != null && logradouro!.trim().isNotEmpty) ||
        (numero != null && numero!.trim().isNotEmpty) ||
        (complemento != null && complemento!.trim().isNotEmpty) ||
        (bairro != null && bairro!.trim().isNotEmpty) ||
        (cidade != null && cidade!.trim().isNotEmpty) ||
        (uf != null && uf!.trim().isNotEmpty);
  }

  /// Retorna uma descrição curta resumida do endereço (ex: "Goiânia - GO" ou "Rua das Flores, 100 - Goiânia/GO")
  String get resumo {
    final partes = <String>[];
    if (logradouro != null && logradouro!.trim().isNotEmpty) {
      if (numero != null && numero!.trim().isNotEmpty) {
        partes.add('${logradouro!.trim()}, ${numero!.trim()}');
      } else {
        partes.add(logradouro!.trim());
      }
    }
    if (bairro != null && bairro!.trim().isNotEmpty) {
      partes.add(bairro!.trim());
    }
    if (cidade != null && cidade!.trim().isNotEmpty) {
      if (uf != null && uf!.trim().isNotEmpty) {
        partes.add('${cidade!.trim()}/${uf!.trim().toUpperCase()}');
      } else {
        partes.add(cidade!.trim());
      }
    } else if (uf != null && uf!.trim().isNotEmpty) {
      partes.add(uf!.trim().toUpperCase());
    }

    if (partes.isEmpty) {
      return cep != null && cep!.trim().isNotEmpty ? 'CEP ${cep!.trim()}' : '';
    }
    return partes.join(' - ');
  }

  factory EnderecoPessoa.fromJson(Map<String, dynamic> json) {
    return EnderecoPessoa(
      idEnderecoPessoa: (json['idEnderecoPessoa'] as num?)?.toInt(),
      cep: json['cep'] as String?,
      logradouro: json['logradouro'] as String?,
      numero: json['numero'] as String?,
      complemento: json['complemento'] as String?,
      bairro: json['bairro'] as String?,
      cidade: json['cidade'] as String?,
      uf: json['uf'] as String?,
      enderecoCompleto: json['enderecoCompleto'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idEnderecoPessoa != null) 'idEnderecoPessoa': idEnderecoPessoa,
      'cep': cep?.trim(),
      'logradouro': logradouro?.trim(),
      'numero': numero?.trim(),
      'complemento': complemento?.trim(),
      'bairro': bairro?.trim(),
      'cidade': cidade?.trim(),
      'uf': uf?.trim().toUpperCase(),
    };
  }

  EnderecoPessoa copyWith({
    int? idEnderecoPessoa,
    String? cep,
    String? logradouro,
    String? numero,
    String? complemento,
    String? bairro,
    String? cidade,
    String? uf,
    String? enderecoCompleto,
  }) {
    return EnderecoPessoa(
      idEnderecoPessoa: idEnderecoPessoa ?? this.idEnderecoPessoa,
      cep: cep ?? this.cep,
      logradouro: logradouro ?? this.logradouro,
      numero: numero ?? this.numero,
      complemento: complemento ?? this.complemento,
      bairro: bairro ?? this.bairro,
      cidade: cidade ?? this.cidade,
      uf: uf ?? this.uf,
      enderecoCompleto: enderecoCompleto ?? this.enderecoCompleto,
    );
  }
}
