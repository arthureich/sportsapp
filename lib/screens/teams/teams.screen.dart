// lib/screens/teams/teams_screen.dart

import 'package:flutter/material.dart';
//import 'package:flutter_svg/flutter_svg.dart';

// Modelo simples para os dados da equipe (pode ser movido para a pasta models)
class Team {
  final String id;
  final String name;
  final String sport;
  final String crestUrl; // URL para o brasão/logo da equipe
  final int currentMembers;
  final int maxMembers;
  final bool isPublic;

  Team({
    required this.id,
    required this.name,
    required this.sport,
    required this.crestUrl,
    required this.currentMembers,
    required this.maxMembers,
    required this.isPublic,
  });
}

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // --- BANCO DE DADOS LOCAL (MOCK) ---
  final List<Team> myTeams = [
    Team(id: 't01', name: 'Guerreiros da Grama', sport: 'Futebol', crestUrl: 'assets/icons/team_crest_1.svg', currentMembers: 10, maxMembers: 12, isPublic: false),
    Team(id: 't02', name: 'Reis da Cesta', sport: 'Basquete', crestUrl: 'assets/icons/team_crest_2.svg', currentMembers: 5, maxMembers: 5, isPublic: true),
  ];
  
  final List<Team> exploreTeams = [
    Team(id: 't03', name: 'Corredores de Cascavel', sport: 'Corrida', crestUrl: 'assets/icons/team_crest_3.svg', currentMembers: 25, maxMembers: 50, isPublic: true),
    Team(id: 't04', name: 'Vôlei de Quinta', sport: 'Vôlei', crestUrl: 'assets/icons/team_crest_4.svg', currentMembers: 8, maxMembers: 10, isPublic: true),
    Team(id: 't02', name: 'Reis da Cesta', sport: 'Basquete', crestUrl: 'assets/icons/team_crest_2.svg', currentMembers: 5, maxMembers: 5, isPublic: true),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Equipes', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.black, size: 28),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Botão Criar Equipe com Gradiente
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)], // Verde escuro e claro
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.green.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Criar Nova Equipe', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ),
          
          // Abas Animadas
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AnimatedTabBar(tabController: _tabController),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTeamList(myTeams),
                _buildTeamList(exploreTeams),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTeamList(List<Team> teams) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: teams.length,
      itemBuilder: (context, index) {
        return TeamCard(team: teams[index]);
      },
    );
  }
}

// Card de Equipe Repaginado
class TeamCard extends StatelessWidget {
  final Team team;
  const TeamCard({super.key, required this.team});

  IconData _getSportIcon(String sport) {
    switch (sport.toLowerCase()) {
      case 'futebol': return Icons.sports_soccer;
      case 'basquete': return Icons.sports_basketball;
      case 'vôlei': return Icons.sports_volleyball;
      case 'corrida': return Icons.directions_run;
      default: return Icons.sports;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.green[50],
                    child: Icon(_getSportIcon(team.sport), size: 30, color: Colors.green[800]),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(team.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(team.sport, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('MEMBROS: ${team.currentMembers} de ${team.maxMembers}', style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: team.currentMembers / team.maxMembers,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                borderRadius: BorderRadius.circular(10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Widget para a TabBar Animada ---
class AnimatedTabBar extends StatefulWidget {
  final TabController tabController;
  const AnimatedTabBar({super.key, required this.tabController});
  @override
  State<AnimatedTabBar> createState() => _AnimatedTabBarState();
}

class _AnimatedTabBarState extends State<AnimatedTabBar> {
  @override
  void initState() {
    super.initState();
    widget.tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // --- Fundo animado que desliza ---
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: (constraints.maxWidth / 2) * widget.tabController.index,
                child: Container(
                  width: constraints.maxWidth / 2,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 5)],
                  ),
                ),
              ),
              // --- Abas Clicáveis ---
              Row(
                children: [
                  Expanded(child: Center(child: TabButton(title: 'Minhas Equipes', isSelected: widget.tabController.index == 0, onTap: () => widget.tabController.animateTo(0)))),
                  Expanded(child: Center(child: TabButton(title: 'Explorar', isSelected: widget.tabController.index == 1, onTap: () => widget.tabController.animateTo(1)))),
                ],
              )
            ],
          );
        },
      ),
    );
  }
}

// Widget para o texto da aba
class TabButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  const TabButton({super.key, required this.title, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.green[700] : Colors.grey[600],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}