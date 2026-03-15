# ⚡ Guia Rápido de Configuração

## 1️⃣ Configurar URL do Backend

Edite `lib/config/app_config.dart`:

### Para Emulador Android
```dart
static const String baseUrl = 'http://10.0.2.2:8080/api';
```

### Para iOS Simulator
```dart
static const String baseUrl = 'http://localhost:8080/api';
```

### Para Dispositivo Físico
```dart
static const String baseUrl = 'http://192.168.X.X:8080/api'; // Seu IP local
```

**Como descobrir seu IP:**
- **Windows**: `ipconfig` no CMD
- **Mac/Linux**: `ifconfig` no Terminal
- Procure por `IPv4` ou `inet`

## 2️⃣ Configurar Backend

Certifique-se que o backend Spring Boot está rodando:

```bash
cd /caminho/para/api_agro360
./mvnw spring-boot:run
```

O backend deve estar acessível em `http://localhost:8080`

## 3️⃣ Instalar Dependências

```bash
cd /home/ubuntu/agro360_flutter
flutter pub get
```

## 4️⃣ Executar o App

```bash
flutter run
```

## 5️⃣ Testar Login

### Criar Usuário no Backend

Primeiro, crie um usuário de teste no backend usando Postman ou curl:

```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "nomeUsuario": "admin",
    "senha": "admin123",
    "email": "admin@agro360.com",
    "idPessoa": "1"
  }'
```

**Nota**: Você precisa ter uma pessoa cadastrada com ID 1 no banco de dados.

### Fazer Login no App

1. Abra o app
2. Na tela de login, digite:
   - **Usuário**: `admin`
   - **Senha**: `admin123`
3. Clique em "Entrar"

## 🐞 Troubleshooting

### Erro: "Erro de conexão"

**Solução**:
1. Verifique se o backend está rodando
2. Verifique a URL no `app_config.dart`
3. Teste a URL no navegador: `http://SEU_IP:8080/api`

### Erro: "Token inválido"

**Solução**:
1. Faça logout no app
2. Faça login novamente

### App não conecta ao backend no dispositivo físico

**Solução**:
1. Certifique-se que o dispositivo e o computador estão na mesma rede Wi-Fi
2. Use o IP local do computador (não localhost)
3. Desative firewall temporariamente para testar

### Hot Reload não funciona

**Solução**:
```bash
# Pare o app (Ctrl+C) e execute novamente
flutter run
```

## 📝 Checklist de Configuração

- [ ] Backend Spring Boot rodando
- [ ] URL configurada corretamente em `app_config.dart`
- [ ] Dependências instaladas (`flutter pub get`)
- [ ] Emulador/dispositivo conectado
- [ ] Usuário de teste criado no backend
- [ ] Permissões de internet configuradas
- [ ] App executando sem erros

## 🚀 Próximos Passos

Após configurar e executar:

1. Teste o login
2. Explore a tela Home
3. Teste a sincronização
4. Verifique o modo offline
5. Implemente novas funcionalidades

---

**Precisa de ajuda?** Consulte o README.md para documentação completa.
