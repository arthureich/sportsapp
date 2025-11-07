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
  bool _isCurrentUserAdmin = false;
  bool _hasUserRequested = false;

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
          _isCurrentUserAdmin = _currentUserId != null && team.adminId == _currentUserId;
          _hasUserRequested = _currentUserId != null && team.pendingMemberIds.contains(_currentUserId);

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
                 if (_isCurrentUserAdmin && team.pendingMemberIds.isNotEmpty)
                    _buildPendingMembersSection(team.pendingMemberIds),
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
              if (!snapshot.hasData || snapshot.data == null) {
                return const ElevatedButton(onPressed: null, child: Text("CARREGANDO..."));
              }
              
              final team = snapshot.data!;
              final isMember = _currentUserId != null && team.memberIds.contains(_currentUserId);
              final hasRequested = _currentUserId != null && team.pendingMemberIds.contains(_currentUserId);
              final isFull = team.currentMembers >= team.maxMembers;
              final isAdmin = team.adminId == _currentUserId;

              // --- 5. LÓGICA DO BOTÃO ATUALIZADA ---
              
              // Se for admin, não mostra o botão (ou poderia mostrar "Gerenciar")
              if (isAdmin) {
                return const SizedBox.shrink(); 
              }

              // Se for membro, mostra "Sair"
              if (isMember) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  onPressed: _isLoading ? null : () => _toggleMembership(team),
                  child: _isLoading ? _loadingIndicator() : const Text("SAIR DA EQUIPE"),
                );
              }
              
              // Se já solicitou, mostra "Solicitação Enviada"
              if (hasRequested) {
                return const ElevatedButton(
                  onPressed: null,
                  style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.grey)),
                  child: Text("SOLICITAÇÃO ENVIADA"),
                );
              }

              // Se estiver lotada (e ele não for membro/pendente), mostra "Lotada"
              if (isFull) {
                return const ElevatedButton(
                  onPressed: null,
                  style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.grey)),
                  child: Text("EQUIPE LOTADA"),
                );
              }

              // Se for privada e não estiver lotada, mostra "Solicitar Entrada"
              if (!team.isPublic) {
                 return ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                  onPressed: _isLoading ? null : () => _toggleMembership(team),
                  child: _isLoading ? _loadingIndicator() : const Text("SOLICITAR ENTRADA"),
                );
              }

              // Senão (é pública, tem vaga, não é membro), mostra "Entrar"
              return ElevatedButton(
               style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
               onPressed: _isLoading ? null : () => _toggleMembership(team),
               child: _isLoading ? _loadingIndicator() : const Text("ENTRAR NA EQUIPE"),
             );
             // --- FIM DA LÓGICA DO BOTÃO ---
           }
         ),
       ),
    );
  }

  Future<void> _toggleMembership(Team team) async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faça login para interagir com equipes.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Se já é membro, ele só pode sair
      if (_isCurrentUserMember) {
        await _teamService.leaveTeam(widget.teamId, _currentUserId);
         if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Você saiu da equipe.')));
      } 
      // Se for pública, ele entra direto
      else if (team.isPublic) {
        await _teamService.joinTeam(widget.teamId, _currentUserId);
         if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Você entrou na equipe!')));
      } 
      // Se for privada, ele solicita
      else {
        await _teamService.requestToJoinTeam(widget.teamId, _currentUserId);
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitação enviada!')));
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

  Widget _loadingIndicator() {
    return const SizedBox(
      height: 20, 
      width: 20, 
      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
    );
  }

  // Constrói a lista de membros pendentes (só para o admin)
  Widget _buildPendingMembersSection(List<String> pendingMemberIds) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Solicitações Pendentes (${pendingMemberIds.length})",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<UserModel>>(
          future: _userService.getUsersData(pendingMemberIds),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final users = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user.fotoUrl.isNotEmpty
                        ? user.fotoUrl
                        : 'https://avatar.iran.liara.run/public/${user.genero}?username=${user.id}'),
                  ),
                  title: Text(user.nome),
                  trailing: _isLoading
                      ? const CircularProgressIndicator()
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => _rejectMember(user.id),
                            ),
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () => _approveMember(user.id),
                            ),
                          ],
                        ),
                );
              },
            );
          },
        ),
        const Divider(height: 30),
      ],
    );
  }

  Future<void> _approveMember(String userId) async {
    setState(() => _isLoading = true);
    try {
      await _teamService.approveMember(widget.teamId, userId);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _rejectMember(String userId) async {
     setState(() => _isLoading = true);
    try {
      await _teamService.rejectMember(widget.teamId, userId);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                 child: CircleAvatar(radius: 20, child: Text(memberIds[index].substring(0, 1))), 
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
                          : 'https://avatar.iran.liara.run/public/${user.genero}?username=${user.id}'), 
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