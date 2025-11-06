import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_application_1/api/notification_service.dart';
import 'settings_screen.dart';
import 'edit_profile_screen.dart';
import '../events/event_detail_screen.dart';
import '../../api/auth_service.dart';
import '../../api/event_service.dart'; 
import '../../api/user_service.dart'; 
import '../../api/rating_service.dart';
import '../../api/team_service.dart'; 
import '../../models/team_model.dart';
import '../../models/rating_model.dart';
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
  final NotificationService _notificationService = NotificationService();
  final UserService _userService = UserService();
  final EventService _eventService = EventService();
  final AuthService _authService = AuthService();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid; 

  final RatingService _ratingService = RatingService();
  final TeamService _teamService = TeamService();
  bool _isRating = false;

  Future<void> _onMenuOptionSelected(BuildContext context, ProfileMenuOption option) async {
    switch (option) {
      case ProfileMenuOption.editProfile:
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
        await _authService.signOut();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, 
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
                         _buildProfileHeader(user), 
                         TabBar( 
                           labelColor: Colors.green,
                           unselectedLabelColor: Colors.grey,
                           indicatorColor: Colors.green,
                           tabs: const [
                             Tab(icon: Icon(Icons.event, color: Colors.green), text: 'Meus Eventos'),
                             Tab(icon: Icon(Icons.history, color: Colors.green), text: 'Histórico'),
                             Tab(icon: Icon(Icons.emoji_events, color: Colors.green), text: 'Conquistas'),
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
                    Center(child: CircularProgressIndicator()),
                    Center(child: CircularProgressIndicator()),
                    Center(child: CircularProgressIndicator()),
                  ],
                );
              }
              final user = snapshot.data!;
              
              return TabBarView(
                children: [
                  _buildMyEventsList(isUpcoming: true),  
                  _buildMyEventsList(isUpcoming: false), 
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
               : 'https://avatar.iran.liara.run/public/${user.genero}?username=${user.id}'), 
           onBackgroundImageError: (exception, stackTrace) {},
        ),
        const SizedBox(height: 12),
        Text(
          user.nome, 
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          user.bio.isNotEmpty ? user.bio : 'Sem bio definida', 
          style: const TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const StatItem(count: '0', label: 'Eventos'), 
            const StatItem(count: '0', label: 'Conquistas'), 
            StatItem(count: user.scoreEsportividade.toStringAsFixed(1), label: 'Avaliação'),
          ],
        ),
        const SizedBox(height: 20),
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

  Widget _buildMyEventsList({required bool isUpcoming}) {
    if (_currentUserId == null) {
      return const Center(child: Text('Faça login para ver seus eventos.'));
    }

    return StreamBuilder<List<Event>>(
      stream: _eventService.getAllEvents(), 
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

        final List<Event> myEvents = snapshot.data!
            .where((event) =>
                event.organizer.id == _currentUserId ||
                event.participants.any((p) => p.id == _currentUserId))
            .toList();

        final now = DateTime.now();
        final List<Event> filteredEvents;

        if (isUpcoming) {
          filteredEvents = myEvents.where((e) => e.dateTime.isAfter(now)).toList();
          filteredEvents.sort((a, b) => a.dateTime.compareTo(b.dateTime)); 
        } else {
          filteredEvents = myEvents.where((e) => e.dateTime.isBefore(now)).toList();
          filteredEvents.sort((a, b) => b.dateTime.compareTo(a.dateTime)); 
        }

        if (filteredEvents.isEmpty) {
          final message = isUpcoming 
            ? 'Você não tem eventos futuros.' 
            : 'Você ainda não participou de nenhum evento.';
          return Center(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0), 
          itemCount: filteredEvents.length,
          itemBuilder: (context, index) {
            final event = filteredEvents[index];
            return _ProfileEventCard(
              event: event, 
              isPast: !isUpcoming, 
              onRatePressed: () {
                _showRatingModal(event);
              },
            );
          },
        );
      },
    );
 }
 void _showRatingModal(Event event) {
    final participantsToRate = event.participants
        .where((p) => p.id != _currentUserId)
        .toList();

    if (participantsToRate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Não há outros participantes para avaliar neste evento.'),
      ));
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return StatefulBuilder( 
          builder: (modalContext, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: 400, 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Avalie os participantes', style: Theme.of(context).textTheme.headlineSmall),
                  Text(event.title, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _isRating 
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                        itemCount: participantsToRate.length,
                        itemBuilder: (context, index) {
                          final participant = participantsToRate[index];
                          return _RatingParticipantTile(
                            participant: participant,
                            ratingService: _ratingService,
                            eventId: event.id,
                            raterUserId: _currentUserId!,
                            onRatingSubmited: (ratedUserId, newScore) {
                              _handleRatingLogic(ratedUserId);
                              setModalState(() {});
                            },
                          );
                        },
                      ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Future<void> _handleRatingLogic(String ratedUserId) async {
    setState(() => _isRating = true);
    try {
      final allRatings = await _ratingService.getRatingsForUser(ratedUserId);

      if (allRatings.isEmpty) {
        setState(() => _isRating = false);
        return; 
      }

      final sum = allRatings.map((r) => r.score).reduce((a, b) => a + b);
      final newAverage = sum / allRatings.length;

      await _userService.updateUserScore(ratedUserId, newAverage);

      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Avaliação registrada! O score do usuário foi atualizado para ${newAverage.toStringAsFixed(1)}.')),
        );
      }

    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao calcular score: $e')),
        );
      }
    } finally {
      if(mounted) setState(() => _isRating = false);
    }
  }



  Widget _buildAchievementsTab(UserModel user) {
      final combinedStreams = ZipStream.zip2<List<Event>, List<Team>, List<dynamic>>(
        _eventService.getAllEvents(), 
        _teamService.getTeams(),   
        (events, teams) => [events, teams],
      );

      return StreamBuilder<List<dynamic>>(
        stream: combinedStreams,
        builder: (context, streamSnapshot) {

          return FutureBuilder<List<Rating>>(
            future: _ratingService.getRatingsForUser(user.id),
            builder: (context, ratingSnapshot) {

              if (!streamSnapshot.hasData || !ratingSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final List<Event> allEvents = streamSnapshot.data![0];
              final List<Team> allTeams = streamSnapshot.data![1];
              final List<Rating> allRatingsReceived = ratingSnapshot.data!;
              final now = DateTime.now();

              final myPastEvents = allEvents.where((event) =>
                  event.dateTime.isBefore(now) &&
                  (event.organizer.id == user.id || 
                  event.participants.any((p) => p.id == user.id))
              ).toList();

              final myCreatedEvents = allEvents.where(
                  (event) => event.organizer.id == user.id
              ).toList();

              final myTeams = allTeams.where(
                  (team) => team.memberIds.contains(user.id)
              ).toList();

              final List<Achievement> allAchievements = [
                Achievement(title: "Bom Espírito", description: "Receba uma avaliação de 4.5 estrelas ou mais.", icon: Icons.sentiment_very_satisfied),
                Achievement(title: "Popular", description: "Receba 10 avaliações no total.", icon: Icons.star_rate),
                Achievement(title: "Organizador", description: "Crie seu primeiro evento.", icon: Icons.edit_calendar),
                Achievement(title: "Bom de Bola", description: "Participe de um evento de Futebol.", icon: Icons.sports_soccer),
                Achievement(title: "Veterano", description: "Participe de 5 eventos.", icon: Icons.military_tech),
                Achievement(title: "Membro de Equipe", description: "Entre para sua primeira equipe.", icon: Icons.group),
              ];

              final List<Achievement> processedAchievements = allAchievements.map((ach) {
                bool unlocked = false;
                switch (ach.title) {
                  case "Bom Espírito":
                    unlocked = user.scoreEsportividade >= 4.5;
                    break;
                  case "Popular":
                    unlocked = allRatingsReceived.length >= 10;
                    break;
                  case "Organizador":
                    unlocked = myCreatedEvents.isNotEmpty;
                    break;
                  case "Bom de Bola":
                    unlocked = myPastEvents.any((event) => event.sport == 'Futebol');
                    break;
                  case "Veterano":
                    unlocked = myPastEvents.length >= 5;
                    break;
                  case "Membro de Equipe":
                    unlocked = myTeams.isNotEmpty;
                    break;
                }
                
                return Achievement(
                  title: ach.title,
                  description: ach.description,
                  icon: ach.icon,
                  isUnlocked: unlocked,
                );
              }).toList();

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, 
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0, 
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
  class _ProfileEventCard extends StatelessWidget {
    final Event event;
    final bool isPast;
    final VoidCallback onRatePressed;

    const _ProfileEventCard({
      required this.event,
      required this.isPast,
      required this.onRatePressed,
    });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EventDetailScreen(event: event)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(event.imageUrl),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      event.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    "${event.dateTime.day.toString().padLeft(2, '0')}/${event.dateTime.month.toString().padLeft(2, '0')}/${event.dateTime.year}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.access_time_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    "${event.dateTime.hour.toString().padLeft(2, '0')}:${event.dateTime.minute.toString().padLeft(2, '0')}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      event.location.name,
                      style: const TextStyle(color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (isPast) ...[
                const Divider(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: const Icon(Icons.star_outline, size: 18),
                    label: const Text('AVALIAR EVENTO'),
                    onPressed: onRatePressed,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.orangeAccent,
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class _RatingParticipantTile extends StatefulWidget {
  final LocalUser participant;
  final RatingService ratingService;
  final String eventId;
  final String raterUserId;
  final Function(String ratedUserId, double newScore) onRatingSubmited;

  const _RatingParticipantTile({
    required this.participant,
    required this.ratingService,
    required this.eventId,
    required this.raterUserId,
    required this.onRatingSubmited,
  });

  @override
  State<_RatingParticipantTile> createState() => _RatingParticipantTileState();
}

class _RatingParticipantTileState extends State<_RatingParticipantTile> {
  double _currentRating = 0;
  bool _hasRated = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkIfAlreadyRated();
  }

  void _checkIfAlreadyRated() async {
    final hasRated = await widget.ratingService.hasUserAlreadyRated(
      widget.eventId,
      widget.raterUserId,
      widget.participant.id,
    );
    if (mounted) {
      setState(() {
        _hasRated = hasRated;
        _isLoading = false;
      });
    }
  }
  
  void _submit(double score) async {
    setState(() => _isLoading = true);
    
    final newRating = Rating(
      id: '', 
      eventId: widget.eventId,
      raterUserId: widget.raterUserId,
      ratedUserId: widget.participant.id,
      score: score,
      createdAt: Timestamp.now(),
    );

    await widget.ratingService.addOrUpdateRating(newRating);
    
    if (mounted) {
      setState(() {
         _hasRated = true;
         _isLoading = false;
      });
    }
    widget.onRatingSubmited(widget.participant.id, score);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const ListTile(title: Text("Verificando..."), leading: CircularProgressIndicator(strokeWidth: 2,));
    }
    
    if (_hasRated) {
      return ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(widget.participant.avatarUrl),
        ),
        title: Text(widget.participant.name),
        trailing: const Icon(Icons.check_circle, color: Colors.green),
        subtitle: const Text("Avaliação enviada!"),
      );
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(widget.participant.avatarUrl),
      ),
      title: Text(widget.participant.name),
      subtitle: Row(
        children: List.generate(5, (index) {
          final starScore = index + 1.0;
          return IconButton(
            icon: Icon(
              _currentRating >= starScore ? Icons.star : Icons.star_border,
              color: Colors.orangeAccent,
            ),
            onPressed: () {
              setState(() => _currentRating = starScore);
              _submit(starScore);
            },
          );
        }),
      ),
    );
  }
}