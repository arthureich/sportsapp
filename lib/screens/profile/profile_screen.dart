// lib/screens/profile/profile_screen.dart

import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Número de abas
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Meu Perfil'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // Navegar para configurações
              },
            ),
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