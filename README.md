# Sustenta-Bag

![Versão](https://img.shields.io/badge/versão-1.0.0-brightgreen)
![Flutter](https://img.shields.io/badge/Flutter-3.7.0+-blue)
![Licença](https://img.shields.io/badge/licença-MIT-orange)

Aplicativo móvel para gerenciamento e incentivo à reciclagem sustentável de sacolas plásticas.

## 📋 Sobre o Projeto

Sustenta-Bag é um projeto integrador desenvolvido para conectar consumidores com pontos de coleta de sacolas plásticas, incentivando a reciclagem e reuso desses materiais. Nossa aplicação permite:

- Localização de pontos de coleta próximos
- Registro de entregas e controle de sacolas recicladas
- Sistema de recompensas para usuários ativos
- Estatísticas de impacto ambiental

## 🚀 Estrutura do Projeto

```
sustenta-bag-user/
├── .github/                # Configurações de CI/CD e GitHub Actions
├── frontend/              
│   └── sustenta_bag_application/  # Aplicação Flutter
│       ├── android/        # Configurações específicas para Android
│       ├── ios/            # Configurações específicas para iOS
│       ├── lib/            # Código fonte Dart da aplicação
│       ├── test/           # Testes automatizados
│       └── pubspec.yaml    # Definição de dependências
└── exemple.env            # Modelo de variáveis de ambiente
```

## 💻 Tecnologias Utilizadas

- **Frontend**: Flutter e Dart
- **Backend**: [Informações a adicionar]
- **CI/CD**: GitHub Actions
- **Análise de Código**: Flutter Analyzer

## 🛠️ Configuração de Desenvolvimento

### Pré-requisitos

- Flutter SDK 3.7.0 ou superior
- Dart SDK 3.0.0 ou superior
- Android Studio / VS Code com extensões Flutter e Dart
- Git

### Instalação

1. Clone o repositório:
   ```bash
   git clone https://github.com/seu-usuario/sustenta-bag-user.git
   cd sustenta-bag-user
   ```

2. Instale as dependências:
   ```bash
   cd frontend/sustenta_bag_application
   flutter pub get
   ```

3. Configure o arquivo de ambiente:
   ```bash
   cp exemple.env .env
   ```
   Abra o arquivo `.env` e configure as variáveis necessárias.

4. Execute o aplicativo:
   ```bash
   flutter run
   ```

## 🧪 Testes

Execute os testes automatizados com o comando:

```bash
flutter test
```

## 🔄 Fluxo de Trabalho (GitFlow)

Este projeto utiliza GitFlow como estratégia de branches:

- **main**: Versões estáveis de produção
- **develop**: Branch de desenvolvimento
- **feature/**: Branches para novas funcionalidades
- **hotfix/**: Branches para correções urgentes

## 🚀 Pipelines de CI/CD

O projeto conta com pipelines automatizadas para garantir qualidade e segurança:

1. **Flutter CI**: Compila, testa e valida o código a cada push
2. **Flutter GitFlow**: Gerencia tags e promoções entre branches
3. **Análise de Segurança**: Verifica vulnerabilidades e problemas de segurança
4. **Análise de Vulnerabilidades**: Audita as dependências do projeto

## 📱 Recursos do Aplicativo

[Adicionar capturas de tela e descrições dos recursos principais]

## 👥 Contribuidores

[Listar os contribuidores do projeto]

## 📄 Licença

Este projeto está licenciado sob os termos da licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 📧 Contato

Para mais informações sobre o projeto, entre em contato:
[Adicionar informações de contato]
