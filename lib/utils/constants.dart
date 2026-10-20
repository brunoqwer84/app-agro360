/// Constantes do aplicativo
class AppConstants {
  // Sexo dos animais
  static const String sexoMacho = 'M';
  static const String sexoFemea = 'F';

  // Status dos animais
  static const String statusAtivo = 'ATIVO';
  static const String statusVendido = 'VENDIDO';
  static const String statusMorto = 'MORTO';

  // Tipos de produção
  static const String producaoLeite = 'LEITE';
  static const String producaoCorte = 'CORTE';
  static const String producaoMisto = 'MISTO';

  // Roles de usuários
  static const String roleUser = 'ROLE_USER';
  static const String roleAdmin = 'ROLE_ADMIN';

  // Mensagens
  static const String msgSemConexao = 'Sem conexão com a internet';
  static const String msgErroGenerico = 'Ocorreu um erro. Tente novamente.';
  static const String msgSucessoSalvar = 'Salvo com sucesso!';
  static const String msgSucessoAtualizar = 'Atualizado com sucesso!';
  static const String msgSucessoDeletar = 'Deletado com sucesso!';

  // Financeiro
  static const String tipoReceita = 'RECEITA';
  static const String tipoDespesa = 'DESPESA';

  static const String statusPendente = 'PENDENTE';
  static const String statusPago = 'PAGO';
  static const String statusCancelado = 'CANCELADO';

  static const List<String> categoriasDespesa = [
    'Alimentação & Ração',
    'Medicamentos & Vacinas',
    'Mão de Obra & Salários',
    'Manutenção & Equipamentos',
    'Combustível & Energia',
    'Pastagem & Adubos',
    'Veterinário & Consultoria',
    'Impostos & Taxas',
    'Outras Despesas',
  ];

  static const List<String> categoriasReceita = [
    'Venda de Animais',
    'Venda de Leite',
    'Venda de Grãos/Sementes',
    'Serviços Prestados',
    'Arrendamento',
    'Outras Receitas',
  ];

  static const List<String> formasPagamento = [
    'PIX',
    'Dinheiro',
    'Boleto Bancário',
    'Cartão de Crédito',
    'Cartão de Débito',
    'Transferência Bancária',
  ];

  static const List<String> ufs = [
    'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO',
    'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI',
    'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO',
  ];
}
