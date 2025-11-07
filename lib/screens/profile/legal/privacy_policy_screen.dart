import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Política de Privacidade'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Última atualização: 07 de novembro de 2025',
              style: textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 24),
            Text(
              'Esta Política de Privacidade descreve como o Joga+ coleta, usa e protege suas informações.',
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            Text(
              '1. Informações que Coletamos',
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Para fornecer nossos serviços, coletamos as seguintes informações:\n'
              '- Informações de Cadastro: Nome, e-mail, foto de perfil, biografia, esportes de interesse e gênero (para o avatar padrão).\n'
              '- Informações de Uso: Eventos que você cria, participa ou avalia.\n'
              '- Dados de Localização: Apenas com sua permissão (via `geolocator`), usamos sua localização para centralizar o mapa e sugerir eventos próximos (via `geoflutterfire_plus`). Não armazenamos seu histórico de localização.\n'
              '- Tokens de Notificação: Coletamos o FCM Token (Firebase Cloud Messaging) para enviar notificações push relevantes sobre eventos.',
            ),
            const SizedBox(height: 24),
            Text(
              '2. Como Usamos Serviços de Terceiros',
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'O Joga+ é construído sobre a plataforma Firebase (BaaS) e Google Maps. Isso significa que utilizamos:\n'
              '- Firebase Authentication: Para gerenciar seu login (E-mail/Senha e Google Sign-In).\n'
              '- Cloud Firestore: Para armazenar os dados do aplicativo (perfis, eventos, equipes, avaliações).\n'
              '- Firebase Storage: Para armazenar imagens de perfil e emblemas de equipes que você envia.\n'
              '- Google Maps Platform (SDK e API): Para exibir o mapa, os marcadores e permitir a seleção de locais.\n'
              'Estes serviços são regidos pelas políticas de privacidade do Google.',
            ),
            const SizedBox(height: 24),
            Text(
              '3. Segurança dos Dados',
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Empregamos regras de segurança do Firestore (Security Rules) para garantir que os usuários só possam acessar e modificar seus próprios dados. Organizadores de eventos têm permissão para gerenciar seus respectivos eventos.',
            ),
            const SizedBox(height: 24),
            Text(
              '4. Contato',
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Em caso de dúvidas sobre esta política de privacidade, entre em contato pelo e-mail: [seu-email-de-contato@gmail.com].',
            ),
          ],
        ),
      ),
    );
  }
}