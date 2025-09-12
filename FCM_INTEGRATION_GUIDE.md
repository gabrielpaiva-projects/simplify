# Firebase Cloud Messaging (FCM) - Guia de Integração

## 📱 Visão Geral

Este documento descreve a integração completa do Firebase Cloud Messaging (FCM) no app Simplify. A implementação permite:

- ✅ Salvamento automático de tokens FCM na collection `tokens` do Firestore
- ✅ Atualização de tokens sempre que o usuário abre o app
- ✅ Invalidação de tokens no logout
- ✅ Limpeza automática de tokens antigos
- ✅ Suporte a notificações em foreground, background e quando o app está fechado
- ✅ Subscrição/desinscrição de tópicos

## 🏗️ Arquitetura

### Serviço Principal
- **`FirebaseMessagingService`**: Singleton que gerencia toda a funcionalidade do FCM
- **Localização**: `lib/services/firebase_messaging_service.dart`

### Integração com Autenticação
- Tokens são automaticamente salvos/invalidados conforme o estado de autenticação
- Integração no `AuthProvider` para gerenciar ciclo de vida dos tokens

## 🔧 Configuração Implementada

### Dependencies (pubspec.yaml)
```yaml
firebase_messaging: ^15.1.5
```

### Android Configuration

#### AndroidManifest.xml
```xml
<!-- Permissões FCM -->
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="com.google.android.c2dm.permission.RECEIVE" />

<!-- Configurações FCM -->
<service android:name="io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingService" />
<meta-data android:name="com.google.firebase.messaging.default_notification_icon" 
           android:resource="@drawable/ic_stat_ic_notification" />
<meta-data android:name="com.google.firebase.messaging.default_notification_color" 
           android:resource="@color/colorAccent" />
<meta-data android:name="com.google.firebase.messaging.default_notification_channel_id" 
           android:value="high_importance_channel" />
```

#### Recursos Criados
- `res/drawable/ic_stat_ic_notification.xml` - Ícone de notificação
- `res/values/colors.xml` - Cor padrão para notificações (`colorAccent`)

## 💾 Estrutura no Firestore

### Collection: `tokens`
```javascript
{
  "token": "fA1B2c3D...", // Token FCM único
  "userId": "user123",    // UID do usuário autenticado
  "userEmail": "user@example.com",
  "platform": "android",  // ou "ios"
  "createdAt": Timestamp,
  "updatedAt": Timestamp,
  "isActive": true,       // false quando invalidado
  "invalidatedAt": Timestamp // presente quando invalidado
}
```

**Observações:**
- Cada documento usa o próprio token como ID para evitar duplicatas
- Tokens são marcados como `isActive: false` no logout
- Tokens antigos (>30 dias) são automaticamente removidos

## 🚀 Como Usar

### 1. Inicialização Automática
O serviço é inicializado automaticamente no `main.dart`:

```dart
// Initialize Firebase Messaging Service
final messagingService = di.sl<FirebaseMessagingService>();
await messagingService.initialize();
```

### 2. Obtendo o Token Atual
```dart
final messagingService = di.sl<FirebaseMessagingService>();
String? token = messagingService.currentToken;
```

### 3. Subscrição a Tópicos
```dart
await messagingService.subscribeToTopic('promotions');
await messagingService.unsubscribeFromTopic('promotions');
```

### 4. Limpeza de Tokens Antigos
```dart
await messagingService.cleanupOldTokens();
```

## 🧪 Testando a Integração

### Tela de Teste
Use a tela `TestFCMScreen` (`lib/test_fcm_integration.dart`) para:
- Visualizar o token atual
- Testar subscrição/desinscrição de tópicos
- Limpar tokens antigos
- Atualizar token manualmente

### Adicionando a Tela de Teste às Rotas
```dart
// Em app_routes.dart ou equivalente
case '/test-fcm':
  return MaterialPageRoute(builder: (_) => const TestFCMScreen());
```

## 📤 Enviando Notificações

### 1. Via Firebase Console
1. Acesse o Firebase Console
2. Vá em "Cloud Messaging"
3. Clique em "Send your first message"
4. Configure título, texto e público-alvo
5. Envie a notificação

### 2. Via API REST
```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "TOKEN_DO_DISPOSITIVO",
    "notification": {
      "title": "Título da Notificação",
      "body": "Conteúdo da notificação"
    },
    "data": {
      "custom_key": "custom_value"
    }
  }'
```

### 3. Para Tópicos
```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "/topics/general",
    "notification": {
      "title": "Notificação para Todos",
      "body": "Esta mensagem vai para todos os inscritos no tópico general"
    }
  }'
```

## 🔄 Fluxo de Funcionamento

### Login do Usuário
1. Usuário faz login
2. `AuthProvider` detecta mudança de estado
3. FCM Service é reinicializado
4. Novo token é gerado/obtido
5. Token é salvo no Firestore com dados do usuário

### Logout do Usuário
1. Usuário faz logout
2. `AuthProvider` chama `messagingService.invalidateToken()`
3. Token atual é marcado como `isActive: false`
4. Token local é limpo

### Abertura do App
1. App é iniciado
2. FCM Service é inicializado no `main.dart`
3. Token é obtido/atualizado
4. Token é salvo no Firestore (se usuário autenticado)

## 🛠️ Personalização

### Modificando o Handler de Mensagens
Edite o método `_handleMessage` em `FirebaseMessagingService`:

```dart
void _handleMessage(RemoteMessage message) {
  // Sua lógica personalizada aqui
  if (message.data['type'] == 'appointment_reminder') {
    // Navegar para tela de agendamentos
  } else if (message.data['type'] == 'payment_confirmation') {
    // Navegar para tela de pagamentos
  }
}
```

### Adicionando Novos Tópicos
```dart
// Para diferentes tipos de usuário
if (userType == 'professional') {
  await messagingService.subscribeToTopic('professional_updates');
} else if (userType == 'client') {
  await messagingService.subscribeToTopic('client_promotions');
}
```

## 🐛 Troubleshooting

### Token não está sendo salvo
- Verifique se o usuário está autenticado
- Confirme se as permissões foram concedidas
- Verifique os logs no console

### Notificações não aparecem
- Confirme se as permissões estão corretas
- Verifique se o token está ativo no Firestore
- Teste com o Firebase Console primeiro

### Problemas no Android
- Confirme se o `google-services.json` está atualizado
- Verifique se todas as permissões estão no AndroidManifest.xml
- Teste em dispositivo físico (emulador pode ter limitações)

### Problemas no iOS
- Confirme se o `GoogleService-Info.plist` está correto
- Verifique se as capabilities estão habilitadas no Xcode
- Teste em dispositivo físico com certificado de desenvolvimento

## 📋 Checklist de Implementação

- [x] ✅ Dependência `firebase_messaging` adicionada
- [x] ✅ Serviço `FirebaseMessagingService` criado
- [x] ✅ Integração com sistema de DI (GetIt)
- [x] ✅ Inicialização no `main.dart`
- [x] ✅ Integração com `AuthProvider`
- [x] ✅ Configuração Android (permissões + recursos)
- [x] ✅ Handler para mensagens em background
- [x] ✅ Salvamento automático na collection `tokens`
- [x] ✅ Invalidação no logout
- [x] ✅ Limpeza de tokens antigos
- [x] ✅ Tela de teste criada
- [x] ✅ Documentação completa

## 🚀 Próximos Passos Sugeridos

1. **Notificações Locais**: Integrar com `flutter_local_notifications` para notificações mais ricas
2. **Segmentação**: Criar tópicos específicos por região/tipo de serviço
3. **Analytics**: Rastrear abertura de notificações
4. **Rich Notifications**: Adicionar imagens e botões de ação
5. **Scheduled Notifications**: Notificações agendadas para lembretes

## 📞 Suporte

Para dúvidas sobre a implementação, consulte:
- [Documentação oficial do Firebase Messaging](https://firebase.google.com/docs/cloud-messaging)
- [Flutter Fire Documentation](https://firebase.flutter.dev/docs/messaging/overview)
- Logs do aplicativo para debugging


