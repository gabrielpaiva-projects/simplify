<p align="center">
  <img src="assets/app_logo.png" alt="Simplify" width="120" height="120">
</p>

<h1 align="center">Simplify</h1>

<p align="center">
  <strong>Plataforma de agendamento de serviços domésticos</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.8.1+-02569B?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase" alt="Firebase">
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green" alt="Platforms">
</p>

---

## � Sobre

O **Simplify** é um aplicativo que conecta clientes a profissionais para serviços domésticos como limpeza e instalação de câmeras. O app oferece uma experiência completa desde a escolha do serviço até o pagamento.

---

## ✨ Funcionalidades

### Para Clientes
- 📅 **Agendamento de serviços** — Escolha data, horário e tipo de limpeza
- 💳 **Pagamentos integrados** — PIX e cartão de crédito
- 🔔 **Notificações push** — Acompanhe seus agendamentos
- 👤 **Perfil completo** — Gerencie suas informações

### Para Profissionais
- � **Dashboard de agendamentos** — Visualize seus serviços
- ✅ **Verificação de documentos** — Sistema de aprovação
- 📍 **Cálculo de distância** — Google Maps integrado

### Segurança
- 🔐 **Autenticação Firebase** — Login seguro com e-mail
- 🔒 **Biometria** — Face ID e Touch ID
- 📸 **Verificação facial** — Google ML Kit

---

## 🛠️ Tecnologias

| Categoria | Tecnologias |
|-----------|-------------|
| **Framework** | Flutter 3.8+ |
| **Backend** | Firebase (Auth, Firestore, Storage, Cloud Messaging) |
| **Estado** | Provider |
| **DI** | GetIt |
| **Rede** | Dio |
| **Pagamentos** | PIX, integração com cartões |
| **Segurança** | Flutter Secure Storage, Biometria, ML Kit Face Detection |
| **Mapas** | Google Maps Distance API |

---

## 🚀 Instalação

### Pré-requisitos

- Flutter SDK 3.8.1+
- Conta Firebase configurada

### Setup

```bash
# Clone o repositório
git clone <url-do-repositorio>
cd simplify

# Instale as dependências
flutter pub get

# Adicione os arquivos do Firebase
# Android: android/app/google-services.json
# iOS: ios/Runner/GoogleService-Info.plist

# Execute
flutter run
```

---

## 📁 Estrutura

```
lib/
├── core/           # Tema, rotas, DI, config
├── features/       # Módulos do app
│   ├── auth/       # Login e cadastro
│   ├── services/   # Catálogo e agendamento
│   ├── professional/   # Área do profissional
│   └── notifications/  # Sistema de notificações
├── models/         # Modelos de dados
├── services/       # Serviços (pagamento, biometria, etc.)
└── widgets/        # Componentes reutilizáveis
```

> Veja [ARCHITECTURE.md](ARCHITECTURE.md) para detalhes da arquitetura.

---

## 🧪 Serviços Disponíveis

| Serviço | Descrição |
|---------|-----------|
| 🧹 **Limpeza Padrão** | Limpeza do dia-a-dia |
| 🧼 **Limpeza Pesada** | Limpeza profunda completa |
| 👔 **Passadoria** | Roupas passadas e dobradas |
| 📹 **Instalação de Câmeras** | Segurança residencial |

---

## 📱 Screenshots

*Em desenvolvimento*

---

## 📄 Licença

Projeto privado — uso restrito.
