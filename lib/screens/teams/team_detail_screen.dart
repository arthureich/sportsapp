import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/team_model.dart';
import '../../api/team_service.dart';
import '../../api/user_service.dart'; 
import '../../models/user_model.dart'; 

class TeamDetailScreen extends StatefulWidget {
  final String teamId; 

  const TeamDetailScreen({super.key, required this.teamId});

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen> {
  final TeamService _teamService = TeamService();
  final UserService _userService = UserService(); 
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  bool _isLoading = false; 
  bool _isCurrentUserMember = false; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Equipe'),
      ),
      body: StreamBuilder<Team?>(
        stream: _teamService.getTeamStream(widget.teamId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar dados da equipe.'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Equipe não encontrada.'));
          }

          final team = snapshot.data!;
          _isCurrentUserMember = _currentUserId != null && team.memberIds.contains(_currentUserId);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey[300],
                      // TODO: Exibir imagem do emblema (team.crestUrl)
                      child: Icon(_getSportIcon(team.sport), size: 40, color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(team.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          Text(team.sport, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                if (team.description.isNotEmpty) ...[
                   const Text("Descrição", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 8),
                   Text(team.description, style: const TextStyle(fontSize: 16, height: 1.4)),
                   const SizedBox(height: 24),
                ],

                 const Text("Membros", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                 const SizedBox(height: 8),
                 Row(
                   children: [
                     Expanded(
                       child: LinearProgressIndicator(
                          value: team.maxMembers > 0 ? team.currentMembers / team.maxMembers : 0,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                          minHeight: 10, 
                          borderRadius: BorderRadius.circular(10),
                        ),
                     ),
                      const SizedBox(width: 12),
                      Text('${team.currentMembers} / ${team.maxMembers}', style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.bold)),
                   ],
                 ),
                 const SizedBox(height: 24),
                 const Text("Lista de Membros", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                 const SizedBox(height: 8),
                 _buildMemberList(team.memberIds), 
                 const SizedBox(height: 80), 

              ],
            ),
          );
        },
      ),
       bottomNavigationBar: Padding(
         padding: const EdgeInsets.all(16.0),
         child: StreamBuilder<Team?>( 
           stream: _teamService.getTeamStream(widget.teamId),
           builder: (context, snapshot) {
              bool isMember = false;
              bool teamExists = false;
              bool full = false;

              if (snapshot.hasData && snapshot.data != null) {
                  teamExists = true;
                  final team = snapshot.data!;
                  isMember = _currentUserId != null && team.memberIds.contains(_currentUserId);
                  full = team.currentMembers >= team.maxMembers;
              }

             return ElevatedButton(
               style: ElevatedButton.styleFrom(
                 backgroundColor: isMember ? Colors.redAccent : (full ? Colors.grey : Colors.green), // Muda cor
                 foregroundColor: Colors.white,
                 padding: const EdgeInsets.symmetric(vertical: 16.0),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                 disabledBackgroundColor: Colors.grey.shade400,
               ),
               onPressed: (_isLoading || !teamExists || (full && !isMember)) ? null : _toggleMembership,
               child: _isLoading
                   ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                   : Text(isMember ? "SAIR DA EQUIPE" : (full ? "EQUIPE LOTADA" : "ENTRAR NA EQUIPE")),
             );
           }
         ),
       ),
    );
  }

  Future<void> _toggleMembership() async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faça login para interagir com equipes.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isCurrentUserMember) {
        await _teamService.leaveTeam(widget.teamId, _currentUserId);
         if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Você saiu da equipe.')));
      } else {
        await _teamService.joinTeam(widget.teamId, _currentUserId);
         if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Você entrou na equipe!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildMemberList(List<String> memberIds) {
    if (memberIds.isEmpty) {
      return const Text("Nenhum membro ainda.", style: TextStyle(color: Colors.grey));
    }
    return SizedBox(
      height: 60, 
      child: FutureBuilder<List<UserModel>>(
         future: _userService.getUsersData(memberIds), 
         builder: (context, snapshot) {
           if (snapshot.connectionState == ConnectionState.waiting) {
             return const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)));
           }
           if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
             return ListView.builder(
               scrollDirection: Axis.horizontal,
               itemCount: memberIds.length,
               itemBuilder: (context, index) => Padding(
                 padding: const EdgeInsets.only(right: 8.0),
                 child: CircleAvatar(radius: 20, child: Text(memberIds[index].substring(0, 1))), // Mostra inicial do ID
               ),
             );
           }

           final users = snapshot.data!;
           return ListView.builder(
             scrollDirection: Axis.horizontal,
             itemCount: users.length,
             itemBuilder: (context, index) {
               final user = users[index];
               return Padding(
                 padding: const EdgeInsets.only(right: 8.0),
                 child: Tooltip(
                   message: user.nome,
                   child: CircleAvatar(
                     radius: 20,
                      backgroundImage: NetworkImage(user.fotoUrl.isNotEmpty
                          ? user.fotoUrl
                          : 'https://avatar.iran.liara.run/public/${user.genero}?username=${user.id}'), // <-- ATUALIZADO
                      onBackgroundImageError: (e, s) {},
                   ),
                 ),
               );
             },
           );
         }
       ),
    );
  }

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
}