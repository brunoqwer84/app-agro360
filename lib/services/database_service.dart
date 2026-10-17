// ignore_for_file: depend_on_referenced_packages

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../config/app_config.dart';
import '../models/usuario.dart';
import '../models/pessoa.dart';
import '../models/animal.dart';

/// Service para gerenciamento do banco de dados SQLite local
class DatabaseService {
  static Database? _database;

  /// Obtém instância do banco de dados
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Inicializa o banco de dados
  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, AppConfig.databaseName);

    return await openDatabase(
      path,
      version: AppConfig.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Cria as tabelas do banco de dados
  Future<void> _onCreate(Database db, int version) async {
    // Tabela de token de autenticação
    await db.execute('''
      CREATE TABLE auth_token (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        token TEXT NOT NULL,
        type TEXT DEFAULT 'Bearer',
        username TEXT NOT NULL,
        created_at TEXT NOT NULL,
        expires_at TEXT NOT NULL
      )
    ''');

    // Tabela de usuários
    await db.execute('''
      CREATE TABLE usuario (
        id_usuario INTEGER PRIMARY KEY,
        nome_usuario TEXT NOT NULL,
        ativo INTEGER NOT NULL,
        id_pessoa INTEGER NOT NULL,
        nome_pessoa TEXT NOT NULL,
        id_grupo INTEGER,
        nome_grupo TEXT,
        synced INTEGER DEFAULT 0,
        updated_at TEXT
      )
    ''');

    // Tabela de roles de usuários
    await db.execute('''
      CREATE TABLE usuario_roles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_usuario INTEGER NOT NULL,
        role TEXT NOT NULL,
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE
      )
    ''');

    // Tabela de pessoas
    await db.execute('''
      CREATE TABLE pessoa (
        id_pessoa INTEGER PRIMARY KEY,
        nome TEXT NOT NULL,
        cpf_cnpj TEXT NOT NULL,
        fone TEXT,
        email TEXT,
        ativo INTEGER NOT NULL,
        synced INTEGER DEFAULT 0,
        updated_at TEXT
      )
    ''');

    // Tabela de propriedades
    await db.execute('''
      CREATE TABLE propriedade (
        id_propriedade INTEGER PRIMARY KEY,
        nome TEXT NOT NULL,
        ativo INTEGER NOT NULL,
        id_pessoa INTEGER NOT NULL,
        synced INTEGER DEFAULT 0,
        updated_at TEXT,
        FOREIGN KEY (id_pessoa) REFERENCES pessoa(id_pessoa)
      )
    ''');

    // Tabela de raças
    await db.execute('''
      CREATE TABLE raca (
        id_raca INTEGER PRIMARY KEY,
        descricao TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        updated_at TEXT
      )
    ''');

    // Tabela de animais
    await db.execute('''
      CREATE TABLE animal (
        id_animal INTEGER PRIMARY KEY,
        identificacao TEXT NOT NULL,
        sexo TEXT NOT NULL,
        data_nascimento TEXT,
        tipo_producao TEXT,
        status TEXT,
        criado_em TEXT,
        atualizado_em TEXT,
        id_propriedade INTEGER NOT NULL,
        id_raca INTEGER NOT NULL,
        synced INTEGER DEFAULT 0,
        updated_at TEXT,
        FOREIGN KEY (id_propriedade) REFERENCES propriedade(id_propriedade),
        FOREIGN KEY (id_raca) REFERENCES raca(id_raca)
      )
    ''');

    // Tabela de manejos (evento generico: propriedade + data + observacao)
    await db.execute('''
      CREATE TABLE manejo (
        id_manejo INTEGER PRIMARY KEY,
        id_propriedade INTEGER NOT NULL,
        data TEXT NOT NULL,
        observacao TEXT,
        criado_em TEXT,
        synced INTEGER DEFAULT 0,
        updated_at TEXT,
        FOREIGN KEY (id_propriedade) REFERENCES propriedade(id_propriedade)
      )
    ''');

    // Tabela de pesagens
    await db.execute('''
      CREATE TABLE pesagem (
        id_pesagem INTEGER PRIMARY KEY,
        id_manejo INTEGER NOT NULL,
        id_animal INTEGER NOT NULL,
        peso_kg REAL NOT NULL,
        synced INTEGER DEFAULT 0,
        updated_at TEXT,
        FOREIGN KEY (id_manejo) REFERENCES manejo(id_manejo),
        FOREIGN KEY (id_animal) REFERENCES animal(id_animal)
      )
    ''');

    // Tabela de vacinações
    await db.execute('''
      CREATE TABLE vacinacao (
        id_vacinacao INTEGER PRIMARY KEY,
        id_manejo INTEGER NOT NULL,
        id_animal INTEGER NOT NULL,
        nome TEXT NOT NULL,
        proxima_dose TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        updated_at TEXT,
        FOREIGN KEY (id_manejo) REFERENCES manejo(id_manejo),
        FOREIGN KEY (id_animal) REFERENCES animal(id_animal)
      )
    ''');
  }

  /// Atualiza o banco de dados para nova versão
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // v2: manejo passou a ser generico (sem animal/tipo); animal migrou para
    // pesagem/vacinacao. Cache local - dropa e recria as tabelas afetadas
    // (os dados sao re-obtidos do servidor na proxima sincizacao).
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS vacinacao');
      await db.execute('DROP TABLE IF EXISTS pesagem');
      await db.execute('DROP TABLE IF EXISTS manejo');

      await db.execute('''
        CREATE TABLE manejo (
          id_manejo INTEGER PRIMARY KEY,
          id_propriedade INTEGER NOT NULL,
          data TEXT NOT NULL,
          observacao TEXT,
          criado_em TEXT,
          synced INTEGER DEFAULT 0,
          updated_at TEXT,
          FOREIGN KEY (id_propriedade) REFERENCES propriedade(id_propriedade)
        )
      ''');
      await db.execute('''
        CREATE TABLE pesagem (
          id_pesagem INTEGER PRIMARY KEY,
          id_manejo INTEGER NOT NULL,
          id_animal INTEGER NOT NULL,
          peso_kg REAL NOT NULL,
          synced INTEGER DEFAULT 0,
          updated_at TEXT,
          FOREIGN KEY (id_manejo) REFERENCES manejo(id_manejo),
          FOREIGN KEY (id_animal) REFERENCES animal(id_animal)
        )
      ''');
      await db.execute('''
        CREATE TABLE vacinacao (
          id_vacinacao INTEGER PRIMARY KEY,
          id_manejo INTEGER NOT NULL,
          id_animal INTEGER NOT NULL,
          nome TEXT NOT NULL,
          proxima_dose TEXT NOT NULL,
          synced INTEGER DEFAULT 0,
          updated_at TEXT,
          FOREIGN KEY (id_manejo) REFERENCES manejo(id_manejo),
          FOREIGN KEY (id_animal) REFERENCES animal(id_animal)
        )
      ''');
    }

    // v3: cache do usuário passa a guardar o grupo (id + nome),
    // para exibir mesmo offline.
    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE usuario ADD COLUMN id_grupo INTEGER');
      } catch (_) {
        // coluna já existente
      }
      try {
        await db.execute('ALTER TABLE usuario ADD COLUMN nome_grupo TEXT');
      } catch (_) {
        // coluna já existente
      }
    }
  }

  // ========== USUÁRIOS ==========

  /// Salva usuário no banco local
  Future<void> saveUsuario(Usuario usuario) async {
    final db = await database;

    await db.insert(
      'usuario',
      usuario.toDatabase(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Salvar roles
    await db.delete('usuario_roles',
        where: 'id_usuario = ?', whereArgs: [usuario.idUsuario]);
    for (final role in usuario.roles) {
      await db.insert('usuario_roles', {
        'id_usuario': usuario.idUsuario,
        'role': role,
      });
    }
  }

  /// Busca usuário por ID
  Future<Usuario?> getUsuario(int id) async {
    final db = await database;
    final maps = await db.query(
      'usuario',
      where: 'id_usuario = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    final usuario = Usuario.fromDatabase(maps.first);

    // Carregar roles
    final roles = await db.query(
      'usuario_roles',
      where: 'id_usuario = ?',
      whereArgs: [id],
    );
    usuario.roles.addAll(roles.map((r) => r['role'] as String));

    return usuario;
  }

  /// Lista todos os usuários
  Future<List<Usuario>> getAllUsuarios() async {
    final db = await database;
    final maps = await db.query('usuario');

    final usuarios = <Usuario>[];
    for (final map in maps) {
      final usuario = Usuario.fromDatabase(map);

      // Carregar roles
      final roles = await db.query(
        'usuario_roles',
        where: 'id_usuario = ?',
        whereArgs: [usuario.idUsuario],
      );
      usuario.roles.addAll(roles.map((r) => r['role'] as String));

      usuarios.add(usuario);
    }

    return usuarios;
  }

  /// Lista usuários não sincronizados
  Future<List<Usuario>> getUnsyncedUsuarios() async {
    final db = await database;
    final maps = await db.query(
      'usuario',
      where: 'synced = ?',
      whereArgs: [0],
    );

    return maps.map((map) => Usuario.fromDatabase(map)).toList();
  }

  // ========== PESSOAS ==========

  /// Salva pessoa no banco local
  Future<void> savePessoa(Pessoa pessoa) async {
    final db = await database;
    await db.insert(
      'pessoa',
      pessoa.toDatabase(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Busca pessoa por ID
  Future<Pessoa?> getPessoa(int id) async {
    final db = await database;
    final maps = await db.query(
      'pessoa',
      where: 'id_pessoa = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Pessoa.fromDatabase(maps.first);
  }

  // ========== ANIMAIS ==========

  /// Salva animal no banco local
  Future<void> saveAnimal(Animal animal) async {
    final db = await database;
    await db.insert(
      'animal',
      animal.toDatabase(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Lista todos os animais
  Future<List<Animal>> getAllAnimais() async {
    final db = await database;
    final maps = await db.query('animal');
    return maps.map((map) => Animal.fromDatabase(map)).toList();
  }

  // ========== LIMPEZA ==========

  /// Limpa todos os dados do banco
  Future<void> clearAll() async {
    final db = await database;
    await db.delete('vacinacao');
    await db.delete('pesagem');
    await db.delete('manejo');
    await db.delete('animal');
    await db.delete('raca');
    await db.delete('propriedade');
    await db.delete('pessoa');
    await db.delete('usuario_roles');
    await db.delete('usuario');
    await db.delete('auth_token');
  }

  /// Fecha a conexão com o banco de dados
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
