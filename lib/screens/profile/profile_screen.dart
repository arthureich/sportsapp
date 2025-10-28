import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import '../../api/user_service.dart'; 
import '../../models/user_model.dart'; 
import 'settings_screen.dart';
import 'edit_profile_screen.dart';
import '../../api/event_service.dart'; 
import '../../models/event_model.dart'; 
import '../events/my_events_screen.dart'; 

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
                       // Se não tem usuário ou ID é nulo, mostra um placeholder ou mensagem
                       return _buildProfileHeaderPlaceholder();
                     }

                     final user = snapshot.data!; // Temos os dados do usuário!
                     return _buildProfileHeader(user); // Passa o UserModel para o header
                   },
                 ),
               ),
              SliverPersistentHeader( // Mantém a TabBar fixa abaixo do header
                delegate: _SliverAppBarDelegate(
                  const TabBar(
                    labelColor: Colors.orangeAccent,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.orangeAccent,
                    tabs: [
                      Tab(icon: Icon(Icons.event), text: 'Meus Eventos'),
                      Tab(icon: Icon(Icons.emoji_events), text: 'Conquistas'),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            children: [
              _buildMyEventsList(), 
              const Center(child: Text("Grid de conquistas aqui")),
            ],
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

   // Widget placeholder para quando os dados não carregaram
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

        // Reutiliza o EventCard da my_events_screen
        return ListView.builder(
          padding: const EdgeInsets.all(16.0), // Adiciona padding
          itemCount: myEvents.length,
          itemBuilder: (context, index) {
            final event = myEvents[index];
            return EventCard(event: event); // Reutiliza o card
          },
        );
      },
    );
 }
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

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor, // Cor de fundo para a TabBar
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

