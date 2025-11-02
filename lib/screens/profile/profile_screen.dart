import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'settings_screen.dart';
import 'edit_profile_screen.dart';
import '../events/my_events_screen.dart'; 
import '../../api/event_service.dart'; 
import '../../api/user_service.dart'; 
import '../../models/user_model.dart'; 
import '../../models/event_model.dart'; 
import '../../models/achievement_model.dart';

enum ProfileMenuOption { editProfile, settings, faq, logout }

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final EventService _eventService = EventService();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid; // Pega o ID do usuário logado

  void _onMenuOptionSelected(BuildContext context, ProfileMenuOption option) {
    switch (option) {
      case ProfileMenuOption.editProfile:
         // 2. Navegar para EditProfileScreen (passando o ID se necessário, mas podemos pegar lá)
         if (_currentUserId != null) {
           Navigator.push(
             context,
             MaterialPageRoute(builder: (context) => EditProfileScreen(userId: _currentUserId)),
           );
         } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Erro: Usuário não encontrado.')),
            );
         }
        break;
      case ProfileMenuOption.settings:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
        break;
      case ProfileMenuOption.faq:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Navegando para FAQ... (Não implementado)')),
        );
        break;
      case ProfileMenuOption.logout:
         FirebaseAuth.instance.signOut();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, 
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
              SliverToBoxAdapter(
                 child: StreamBuilder<UserModel?>(
                   stream: _currentUserId != null ? _userService.getUserStream(_currentUserId) : null,
                   builder: (context, snapshot) {
                     if (snapshot.connectionState == ConnectionState.waiting && _currentUserId != null) {
                       return const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()));
                     }
                     if (snapshot.hasError) {
                       return const Center(child: Text('Erro ao carregar perfil.'));
                     }
                     if (!snapshot.hasData || snapshot.data == null) {
                       return _buildProfileHeaderPlaceholder();
                     }

                     final user = snapshot.data!;
                     return Column(
                       children: [
                         _buildProfileHeader(user), // Constrói o header
                         TabBar( // A TabBar fica *dentro* do SliverToBoxAdapter
                           labelColor: Colors.orangeAccent,
                           unselectedLabelColor: Colors.grey,
                           indicatorColor: Colors.orangeAccent,
                           tabs: const [
                             Tab(icon: Icon(Icons.event), text: 'Meus Eventos'),
                             Tab(icon: Icon(Icons.emoji_events), text: 'Conquistas'),
                           ],
                         ),
                       ],
                     );
                   },
                 ),
               ),
            ];
          },
          body: StreamBuilder<UserModel?>( 
            stream: _currentUserId != null ? _userService.getUserStream(_currentUserId) : null,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                 return TabBarView(
                  children: [
                    Center(child: Text('Carregando eventos...')),
                    Center(child: Text('Carregando conquistas...')),
                  ],
                );
              }
              final user = snapshot.data!;
              
              return TabBarView(
                children: [
                  _buildMyEventsList(), 
                  _buildAchievementsTab(user), 
                ],
              );
            }
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    return Column(
      children: [
        const SizedBox(height: 20),
        CircleAvatar(
          radius: 50,
           backgroundImage: NetworkImage(user.fotoUrl.isNotEmpty
               ? user.fotoUrl
               : 'https://avatar.iran.liara.run/public/boy?username=${user.id}'), // Placeholder
           onBackgroundImageError: (exception, stackTrace) {}, // Ignora erro de imagem
        ),
        const SizedBox(height: 12),
        Text(
          user.nome, // Dado dinâmico
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          user.bio.isNotEmpty ? user.bio : 'Sem bio definida', // Dado dinâmico
          style: const TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const StatItem(count: '0', label: 'Eventos'), // Placeholder
            const StatItem(count: '0', label: 'Conquistas'), // Placeholder
             // Exibe o score do usuário, formatado
            StatItem(count: user.scoreEsportividade.toStringAsFixed(1), label: 'Avaliação'),
          ],
        ),
        const SizedBox(height: 20),
         // A TabBar foi movida para SliverPersistentHeader
         // const TabBar(...)
      ],
    );
  }

   Widget _buildProfileHeaderPlaceholder() {
     return const Column(
       children: [
         SizedBox(height: 20),
         CircleAvatar(radius: 50, backgroundColor: Colors.grey),
         SizedBox(height: 12),
         Text('Carregando...', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
         Text('...', style: TextStyle(fontSize: 16, color: Colors.grey)),
         SizedBox(height: 20),
         Row(
           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
           children: [
             StatItem(count: '-', label: 'Eventos'),
             StatItem(count: '-', label: 'Conquistas'),
             StatItem(count: '-', label: 'Avaliação'),
           ],
         ),
         SizedBox(height: 20),
       ],
     );
   }

Widget _buildMyEventsList() {
    // Verifica se o usuário está logado
    if (_currentUserId == null) {
      return const Center(child: Text('Faça login para ver seus eventos.'));
    }

    return StreamBuilder<List<Event>>(
      stream: _eventService.getEvents(), // Busca todos os eventos
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar eventos.'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nenhum evento encontrado.'));
        }

        // Filtra os eventos para o usuário atual
        final List<Event> myEvents = snapshot.data!
            .where((event) =>
                event.organizer.id == _currentUserId ||
                event.participants.any((p) => p.id == _currentUserId))
            .toList();

        if (myEvents.isEmpty) {
          return const Center(
            child: Text(
              'Você ainda não participa ou organiza nenhum evento.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0), 
          itemCount: myEvents.length,
          itemBuilder: (context, index) {
            final event = myEvents[index];
            return EventCard(event: event, isPast: false, onRatePressed: (){},); // Reutiliza o card
          },
        );
      },
    );
 }
}

Widget _buildAchievementsTab(UserModel user) {
    // 1. Define a lista de todas as conquistas possíveis
    final List<Achievement> allAchievements = [
      Achievement(
        title: "Bom de Bola",
        description: "Participe do seu primeiro evento de Futebol.",
        icon: Icons.sports_soccer,
      ),
      Achievement(
        title: "Bom Espírito",
        description: "Receba uma avaliação de 4.5 estrelas ou mais.",
        icon: Icons.sentiment_very_satisfied,
      ),
      Achievement(
        title: "Popular",
        description: "Receba 10 avaliações no total.",
        icon: Icons.star_rate,
      ),
      Achievement(
        title: "Organizador",
        description: "Crie seu primeiro evento.",
        icon: Icons.edit_calendar,
      ),
      Achievement(
        title: "Veterano",
        description: "Participe de 5 eventos.",
        icon: Icons.military_tech,
      ),
      Achievement(
        title: "Membro de Equipe",
        description: "Entre para sua primeira equipe.",
        icon: Icons.group,
      ),
    ];

    // 2. Lógica para "desbloquear" (simples, pode ser melhorada)
    // (A lógica de 'eventos' e 'equipes' precisaria de queries extras,
    // então vamos focar na de 'score' por enquanto)
    final List<Achievement> processedAchievements = allAchievements.map((ach) {
      bool unlocked = false;
      if (ach.title == "Bom Espírito") {
        unlocked = user.scoreEsportividade >= 4.5;
      }
      // TODO: Adicionar lógica para as outras conquistas
      // (Ex: fazer um count em 'eventos' onde o user é participante/organizador)
      
      return Achievement(
        title: ach.title,
        description: ach.description,
        icon: ach.icon,
        isUnlocked: unlocked,
      );
    }).toList();


    // 3. Constrói o Grid
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 colunas
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0, // Quadrado
      ),
      itemCount: processedAchievements.length,
      itemBuilder: (context, index) {
        final ach = processedAchievements[index];
        final color = ach.isUnlocked ? Colors.orangeAccent : Colors.grey[300];
        final iconColor = ach.isUnlocked ? Colors.white : Colors.grey[600];

        return Card(
          elevation: ach.isUnlocked ? 4 : 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: ach.isUnlocked ? Colors.orange.shade100 : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: color,
                  child: Icon(ach.icon, color: iconColor, size: 30),
                ),
                const SizedBox(height: 12),
                Text(
                  ach.title, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  ach.description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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

