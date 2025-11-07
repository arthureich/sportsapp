import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Termos de Uso'),
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
              'Bem-vindo ao Joga+!',
              style: textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const Text(
              'Estes termos de uso regem o uso do aplicativo móvel "Joga+" (o "Aplicativo"). Ao acessar ou usar o Aplicativo, você concorda em ficar vinculado por estes Termos.',
            ),
            const SizedBox(height: 24),
            Text(
              '1. Aceitação dos Termos',
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Ao se cadastrar e utilizar o Joga+, você (o "Usuário") confirma que leu, entendeu e concorda com os termos aqui descritos. Se você não concorda com estes termos, não deve utilizar o aplicativo.',
            ),
            const SizedBox(height: 24),
            Text(
              '2. Objeto do Aplicativo',
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'O Joga+ é uma plataforma destinada a conectar pessoas interessadas em organizar e participar de eventos esportivos informais em locais públicos na cidade de Cascavel-PR, visando combater o sedentarismo e promover a utilização de espaços públicos.',
            ),
            const SizedBox(height: 24),
            Text(
              '3. Conduta do Usuário',
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'O Usuário concorda em utilizar o aplicativo com responsabilidade e respeito. É proibido:\n'
              '- Usar linguagem ofensiva, discriminatória ou de assédio.\n'
              '- Criar eventos falsos ou com o intuito de enganar outros usuários.\n'
              '- Tentar acessar contas de outros usuários ou violar as medidas de segurança do aplicativo.\n'
              '- O Joga+ se reserva o direito de remover conteúdo ou banir usuários que violem estes termos.',
            ),
            const SizedBox(height: 24),
            Text(
              '4. Isenção de Responsabilidade',
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'O Joga+ atua apenas como um facilitador para a organização de eventos. Não nos responsabilizamos por:\n'
              '- Lesões, acidentes ou qualquer dano ocorrido durante os eventos organizados através do app.\n'
              '- A conduta dos participantes, dentro ou fora do aplicativo.\n'
              '- A veracidade ou segurança dos locais de eventos (públicos ou não).\n'
              'O Usuário participa dos eventos por sua conta e risco.',
            ),
            const SizedBox(height: 24),
            Text(
              '5. Modificações dos Termos',
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Podemos revisar estes termos de uso a qualquer momento. A versão mais recente estará sempre disponível no aplicativo.',
            ),
          ],
        ),
      ),
    );
  }
}