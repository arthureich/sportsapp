// lib/screens/profile/profile_screen.dart

import 'package:flutter/material.dart';
import '../auth/login_screen.dart';
import 'settings_screen.dart';

enum ProfileMenuOption { editProfile, settings, faq, logout }

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _onMenuOptionSelected(BuildContext context, ProfileMenuOption option) {
    switch (option) {
      case ProfileMenuOption.editProfile:
        // Lógica para navegar para a tela de edição de perfil
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Navegando para Editar Perfil...')),
        );
        break;
      case ProfileMenuOption.settings:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
        break;
      case ProfileMenuOption.faq:
        // Lógica para navegar para a tela de FAQ
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Navegando para FAQ...')),
        );
        break;
      case ProfileMenuOption.logout:
        // AÇÃO DE LOGOUT: Remove todas as telas e volta para o Login
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false, // Esta condição remove todas as rotas anteriores
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Número de abas
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Meu Perfil'),
          centerTitle: true,
          actions: [
            PopupMenuButton<ProfileMenuOption>(
              onSelected: (option) => _onMenuOptionSelected(context, option),
              icon: const Icon(Icons.more_vert), // Ícone de três pontinhos
              itemBuilder: (BuildContext context) => <PopupMenuEntry<ProfileMenuOption>>[
                const PopupMenuItem<ProfileMenuOption>(
                  value: ProfileMenuOption.editProfile,
                  child: ListTile(
                    leading: Icon(Icons.edit_outlined),
                    title: Text('Editar Perfil'),
                  ),
                ),
                const PopupMenuItem<ProfileMenuOption>(
                  value: ProfileMenuOption.settings,
                  child: ListTile(
                    leading: Icon(Icons.settings_outlined),
                    title: Text('Configurações'),
                  ),
                ),
                const PopupMenuItem<ProfileMenuOption>(
                  value: ProfileMenuOption.faq,
                  child: ListTile(
                    leading: Icon(Icons.quiz_outlined),
                    title: Text('FAQ'),
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<ProfileMenuOption>(
                  value: ProfileMenuOption.logout,
                  child: ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text('Sair', style: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            )
          ],
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(child: _buildProfileHeader()),
            ];
          },
          body: const TabBarView(
            children: [
              // Conteúdo da Aba 1: Meus Eventos
              Center(child: Text("Lista de eventos participados aqui")),
              // Conteúdo da Aba 2: Conquistas
              Center(child: Text("Grid de conquistas aqui")),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para o cabeçalho do perfil
  Widget _buildProfileHeader() {
    return Column(
      children: [
        const SizedBox(height: 20),
        const CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=a042581f4e29026704d'),
        ),
        const SizedBox(height: 12),
        const Text(
          'Joana da Silva',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const Text(
          'Entusiasta de Vôlei e Corrida',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 20),
        // Linha de estatísticas
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            StatItem(count: '12', label: 'Eventos'),
            StatItem(count: '5', label: 'Conquistas'),
            StatItem(count: '4.8', label: 'Avaliação'),
          ],
        ),
        const SizedBox(height: 20),
        const TabBar(
          labelColor: Colors.orangeAccent,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.orangeAccent,
          tabs: [
            Tab(icon: Icon(Icons.event), text: 'Meus Eventos'),
            Tab(icon: Icon(Icons.emoji_events), text: 'Conquistas'),
          ],
        ),
      ],
    );
  }
}

// Widget auxiliar para item de estatística
class StatItem extends StatelessWidget {
  final String count;
  final String label;
  const StatItem({super.key, required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}