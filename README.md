# 🌾 Agro360 - Sistema de Gerenciamento Agropecuário

Sistema mobile Flutter para gerenciamento agropecuário integrado com backend Spring Boot.

## 📋 Índice

- [Características](#características)
- [Arquitetura](#arquitetura)
- [Pré-requisitos](#pré-requisitos)
- [Instalação](#instalação)
- [Configuração](#configuração)
- [Execução](#execução)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Funcionalidades](#funcionalidades)
- [Tecnologias](#tecnologias)

## ✨ Características

- 🔐 **Autenticação JWT** - Login seguro com token
- 💾 **Armazenamento Offline** - SQLite para dados locais
- 🔄 **Sincronização Assíncrona** - Sincronização automática quando online
- 📱 **Interface Responsiva** - Design moderno e intuitivo
- 🎯 **GetX** - Gerenciamento de estado e navegação
- 🌐 **Modo Offline** - Funciona sem conexão com internet
- ✅ **Validação de Formulários** - Validação robusta de dados
- 🔔 **Feedback Visual** - Loading e mensagens informativas

## 🏗️ Arquitetura

O projeto segue a arquitetura **MVSC (Model-View-Service-Controller)**:

```
lib/
├── models/          # Models de dados (DTOs e Entidades)
├── views/           # Telas da interface
├── services/        # Serviços (API, Database, Sync)
├── controllers/     # Controllers com GetX
├── bindings/        # Injeção de dependências
├── routes/          # Configuração de rotas
├── config/          # Configurações do app
└── utils/           # Utilitários
```

### Fluxo de Dados

```
View → Controller → Service → API/Database
                ↓
              Model
```

## 📦 Pré-requisitos

- **Flutter SDK** >= 3.0.0
- **Dart SDK** >= 3.0.0
- **Android Studio** ou **VS Code** com extensões Flutter
- **Backend Agro360** rodando em `http://localhost:8080`

### Verificar Instalação

```bash
flutter --version
dart --version
```

## 🚀 Instalação

### 1. Clone o repositório (ou navegue até a pasta)

```bash
cd /home/ubuntu/agro360_flutter
```

### 2. Instale as dependências

```bash
flutter pub get
```

### 3. Verifique se não há problemas

```bash
flutter doctor
```

## ⚙️ Configuração

### Configurar URL do Backend

Edite o arquivo `lib/config/app_config.dart`:

```dart
static const String baseUrl = 'http://SEU_IP:8080/api';
```

**Importante:**
- Para **emulador Android**: use `http://10.0.2.2:8080/api`
- Para **iOS Simulator**: use `http://localhost:8080/api`
- Para **dispositivo físico**: use `http://SEU_IP_LOCAL:8080/api` (ex: `http://192.168.1.10:8080/api`)

### Configurar Permissões

#### Android

Edite `android/app/src/main/AndroidManifest.xml` e adicione:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

#### iOS

Edite `ios/Runner/Info.plist` e adicione:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## ▶️ Execução

### Modo Debug

```bash
# Executar no dispositivo/emulador conectado
flutter run

# Executar em dispositivo específico
flutter devices
flutter run -d DEVICE_ID

# Hot reload (durante execução)
# Pressione 'r' no terminal
```

### Modo Release

```bash
# Android
flutter build apk --release
# APK gerado em: build/app/outputs/flutter-apk/app-release.apk

# iOS
flutter build ios --release
```

### Executar Testes

```bash
flutter test
```

## 📁 Estrutura do Projeto

```
agro360_flutter/
├── lib/
│   ├── bindings/              # Injeção de dependências GetX
│   │   ├── initial_binding.dart
│   │   ├── auth_binding.dart
│   │   └── home_binding.dart
│   │
│   ├── config/                # Configurações
│   │   └── app_config.dart
│   │
│   ├── controllers/           # Controllers GetX
│   │   ├── auth_controller.dart
│   │   └── sync_controller.dart
│   │
│   ├── models/                # Models de dados
│   │   ├── login_request.dart
│   │   ├── auth_response.dart
│   │   ├── usuario.dart
│   │   ├── pessoa.dart
│   │   ├── animal.dart
│   │   ├── propriedade.dart
│   │   ├── raca.dart
│   │   ├── manejo.dart
│   │   ├── pesagem.dart
│   │   └── vacinacao.dart
│   │
│   ├── routes/                # Rotas
│   │   ├── app_routes.dart
│   │   └── app_pages.dart
│   │
│   ├── services/              # Serviços
│   │   ├── api_service.dart
│   │   ├── database_service.dart
│   │   └── sync_service.dart
│   │
│   ├── views/                 # Telas
│   │   ├── splash_view.dart
│   │   ├── login_view.dart
│   │   └── home_view.dart
│   │
│   └── main.dart              # Ponto de entrada
│
├── test/                      # Testes
├── assets/                    # Recursos (imagens, fontes)
├── android/                   # Configurações Android
├── ios/                       # Configurações iOS
├── pubspec.yaml              # Dependências
└── README.md                 # Este arquivo
```

## 🎯 Funcionalidades

### ✅ Implementadas

- [x] Tela de Splash
- [x] Login com JWT
- [x] Validação de token
- [x] Armazenamento de token local
- [x] Banco de dados SQLite
- [x] Sincronização assíncrona
- [x] Detecção de conectividade
- [x] Logout
- [x] Interface responsiva
- [x] Tratamento de erros

### 🚧 Em Desenvolvimento

- [ ] CRUD de Pessoas
- [ ] CRUD de Animais
- [ ] CRUD de Propriedades
- [ ] Gestão de Manejos
- [ ] Registro de Pesagens
- [ ] Controle de Vacinações
- [ ] Dashboard com estatísticas
- [ ] Exportação de relatórios

## 🛠️ Tecnologias

### Framework

- **Flutter** 3.0+ - Framework UI
- **Dart** 3.0+ - Linguagem

### Gerenciamento de Estado

- **GetX** 4.6+ - Estado, navegação e dependências

### Networking

- **Dio** 5.4+ - Cliente HTTP
- **Connectivity Plus** 5.0+ - Verificação de conectividade

### Armazenamento

- **SQLite** (sqflite 2.3+) - Banco de dados local
- **Shared Preferences** 2.2+ - Dados simples (token, preferências)
- **Path Provider** 2.1+ - Caminhos de diretórios

### UI/UX

- **Flutter Material** - Design Material
- **Flutter Spinkit** 5.2+ - Animações de loading
- **Intl** 0.18+ - Formatação de datas

### Validação

- **Validators** 3.0+ - Validação de formulários

## 🔐 Autenticação

### Fluxo de Login

1. Usuário insere credenciais
2. App envia POST para `/api/auth/login`
3. Backend valida e retorna JWT token
4. Token é salvo localmente (SharedPreferences)
5. Dados do usuário são carregados e salvos no SQLite
6. App navega para Home

### Segurança

- Token JWT armazenado localmente
- Headers de autorização automáticos
- Validação de token ao iniciar app
- Logout limpa todos os dados

## 💾 Sincronização

### Como Funciona

1. **Detecção de Conectividade** - Monitora mudanças na conexão
2. **Sincronização Automática** - Quando conectar, sincroniza automaticamente
3. **Sincronização Manual** - Botão de sincronização na Home
4. **Modo Offline** - Salva dados localmente quando offline
5. **Upload** - Envia dados pendentes quando online

### Estratégia

- Dados salvos localmente primeiro (SQLite)
- Marcados como não sincronizados (`synced = 0`)
- Enviados para API em background
- Marcados como sincronizados (`synced = 1`) após sucesso
- Em caso de erro, mantém `synced = 0` para tentar novamente

## 📱 Telas

### Splash
- Tela inicial de carregamento
- Verifica autenticação
- Redireciona para Login ou Home

### Login
- Campos: usuário e senha
- Validação de formulário
- Feedback visual de loading
- Mensagens de erro

### Home
- Informações do usuário
- Status de conectividade
- Menu de navegação
- Sincronização manual

## 🧪 Testes

### Executar Testes Unitários

```bash
flutter test
```

### Executar com Coverage

```bash
flutter test --coverage
```

## 🐛 Troubleshooting

### Erro de Conexão

**Problema**: "Erro de conexão. Verifique sua internet."

**Solução**:
1. Verifique se o backend está rodando
2. Verifique a URL no `app_config.dart`
3. Use o IP correto para seu ambiente (emulador/físico)
4. Verifique permissões de internet no AndroidManifest.xml

### Token Expirado

**Problema**: "Token inválido ou expirado"

**Solução**:
1. Faça logout
2. Faça login novamente
3. Verifique configuração de expiração no backend

### Erro no SQLite

**Problema**: Erro ao acessar banco de dados

**Solução**:
1. Limpe dados do app
2. Desinstale e reinstale
3. Verifique permissões de armazenamento

### Hot Reload não Funciona

**Solução**:
```bash
# Pare o app e execute novamente
flutter run
```

## 📝 Próximos Passos

1. **Implementar CRUDs completos** para todas as entidades
2. **Dashboard** com gráficos e estatísticas
3. **Relatórios** em PDF
4. **Notificações** para vacinações pendentes
5. **Busca e filtros** avançados
6. **Modo offline completo** com fila de sincronização
7. **Testes unitários** e de integração
8. **CI/CD** para builds automáticos

## 👥 Equipe

Desenvolvido para o sistema Agro360

## 📄 Licença

Este projeto é proprietário e confidencial.

---

**Versão**: 1.0.0  
**Última Atualização**: 13/03/2026  
**Flutter**: 3.0+  
**Backend**: Spring Boot 3.x
