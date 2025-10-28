import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../api/team_service.dart';
import '../../models/team_model.dart';
import 'create_team_screen.dart';
import 'team_detail_screen.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
final TeamService _teamService = TeamService(); // Instância do serviço
final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

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
          // Botão Criar Equipe (sem alteração)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateTeamScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AnimatedTabBar(tabController: _tabController),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Aba 'Minhas Equipes' com StreamBuilder
                _buildTeamsStream(isMyTeams: true),
                // Aba 'Explorar' com StreamBuilder
                _buildTeamsStream(isMyTeams: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget que constrói a lista a partir de um Stream do Firebase
  Widget _buildTeamsStream({required bool isMyTeams}) {
    // Lógica de filtragem (ainda simulada, pode ser melhorada com queries no futuro)
    // Por agora, 'Minhas Equipes' mostra equipes privadas e 'Explorar' mostra públicas
    return StreamBuilder<List<Team>>(
      stream: _teamService.getTeams(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar as equipes.'));
        }
        // Verifica login ANTES de filtrar
        if (_currentUserId == null && isMyTeams) {
           return Center(child: Text('Faça login para ver suas equipes.', style: TextStyle(color: Colors.grey[600])));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Nenhuma equipe encontrada.', style: TextStyle(color: Colors.grey[600])));
        }

        final allTeams = snapshot.data!;
        List<Team> filteredTeams;

        if (isMyTeams) {
          // Filtra onde o ID do usuário está na lista de membros
          filteredTeams = allTeams.where((team) => team.memberIds.contains(_currentUserId)).toList();
        } else {
          // Filtra equipes públicas que o usuário NÃO participa (para não duplicar)
           filteredTeams = allTeams.where((team) => team.isPublic && !team.memberIds.contains(_currentUserId)).toList();
           // Ou apenas as públicas, se quiser mostrar todas:
           // filteredTeams = allTeams.where((team) => team.isPublic).toList();
        }

        return _buildTeamList(filteredTeams, isMyTeams: isMyTeams);
      },
    );
  }
  
Widget _buildTeamList(List<Team> teams, {required bool isMyTeams}) {
    if (teams.isEmpty) {
        final message = isMyTeams
            ? 'Você ainda não faz parte de nenhuma equipe.'
            : 'Nenhuma equipe pública encontrada para explorar.';
        return Center(child: Text(message, style: TextStyle(color: Colors.grey[600])));
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: teams.length,
      itemBuilder: (context, index) {
        // --- ADICIONA NAVEGAÇÃO AO CLICAR ---
        return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TeamDetailScreen(teamId: teams[index].id)),
              );
            },
            child: TeamCard(team: teams[index]),
        );
      },
    );
  }
}

// Card de Equipe 
class TeamCard extends StatelessWidget {
  final Team team;
  const TeamCard({super.key, required this.team});

  IconData _getSportIcon(String sport) {
    switch (sport.toLowerCase()) {
      case 'futebol': return Icons.sports_soccer;
      case 'basquete': return Icons.sports_basketball;
      case 'vôlei': return Icons.sports_volleyball;
      case 'corrida': return Icons.directions_run;
      case 'tênis': return Icons.sports_tennis;
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