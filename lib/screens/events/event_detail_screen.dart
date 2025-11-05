import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../api/event_service.dart';
import '../../models/event_model.dart'; 
import 'create_event_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;
  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final EventService _eventService = EventService();
  bool _isLoading = false; 
  bool _isCurrentUserParticipant = false;  
  bool _isCurrentUserOrganizer = false;
  bool _hasUserRequested = false;
  late Stream<Event> _eventStream;

  @override
  void initState() {
    super.initState();
    _eventStream = _eventService.getEventStream(widget.event.id).map(
      (snapshot) => Event.fromSnapshot(snapshot)
    );
  }

  Future<void> _toggleParticipation(Event event) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você precisa estar logado para participar.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final localUser = LocalUser(
      id: currentUser.uid,
      name: currentUser.displayName ?? 'Usuário Anônimo',
      avatarUrl: currentUser.photoURL ?? 'https://avatar.iran.liara.run/public/boy?username=${currentUser.uid}',
    );

    try {
      bool isParticipant = event.participants.any((p) => p.id == currentUser.uid);
      if (isParticipant) {
        await _eventService.leaveEvent(event.id, localUser);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Você saiu do evento.')),
            );
        }
      } else {
         if (event.participants.length >= event.maxParticipants) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Este evento já está lotado!')),
           );
           setState(() => _isLoading = false); 
           return; 
         }

        await _eventService.joinEvent(widget.event.id, localUser);
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Você entrou no evento!')),
           );
           setState(() { 
             _isCurrentUserParticipant = true;
           });
         }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ocorreu um erro: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteEvent() async {
    // Confirmação
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza que deseja excluir este evento? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirm != true) return; // Se não confirmou, sai

    setState(() => _isLoading = true);
    try {
      await _eventService.deleteEvent(widget.event.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento excluído com sucesso.')),
        );
        Navigator.of(context).pop(); // Volta para a tela anterior
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir evento: $e')),
      );
      }
    }
  }
  
  // --- LÓGICA DE APROVAR PARTICIPANTE ---
  Future<void> _approveParticipant(LocalUser userToApprove) async {
     setState(() => _isLoading = true);
     try {
       await _eventService.approveParticipant(widget.event.id, userToApprove);
     } catch (e) {
       // ... (snackbar de erro)
     } finally {
       setState(() => _isLoading = false);
     }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<Event>(
      stream: _eventStream, 
      builder: (context, snapshot) {
        
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        
        final event = snapshot.data!; 
        
        _isCurrentUserOrganizer = (currentUserId == event.organizer.id);
        _isCurrentUserParticipant = event.participants.any((p) => p.id == currentUserId);
        _hasUserRequested = event.pendingParticipants.any((p) => p.id == currentUserId);
        
        final bool isFull = event.participants.length >= event.maxParticipants;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.event.title, 
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              background: Image.network(
                widget.event.imageUrl, 
                fit: BoxFit.cover,
                color: Colors.black.withValues(),
                colorBlendMode: BlendMode.darken,
                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.sports_soccer, 
                      color: Colors.grey[400],
                      size: 60,
                    ),
                  );
                },
              ),
            ),
            actions: [
                  if (_isCurrentUserOrganizer)
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => CreateEventScreen(eventToEdit: event),
                        ));
                      },
                    ),
                  if (_isCurrentUserOrganizer)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: _deleteEvent,
                    ),
                ],
              ),
          
          SliverList(
            delegate: SliverChildListDelegate([
                  const SizedBox(height: 20),
                  _buildInfoRow(event), 
                  const Divider(height: 40, indent: 20, endIndent: 20),
                  _buildOrganizerInfo(event.organizer),
                  const SizedBox(height: 20),
                  
                  // --- SEÇÃO DE SOLICITAÇÕES PENDENTES (SÓ PARA O ORGANIZADOR) ---
                  if (_isCurrentUserOrganizer && event.pendingParticipants.isNotEmpty)
                    _buildPendingParticipantsSection(event),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text("Descrição", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      event.description.isEmpty ? "Nenhuma descrição fornecida." : event.description,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ),
                  const Divider(height: 40, indent: 20, endIndent: 20),
                  _buildParticipantsSection(event),
                  const SizedBox(height: 100),
              ]),
            )
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildBottomButton(event, isFull),
        ),
      );
    }
  );
}

Widget _buildBottomButton(Event event, bool isFull) {
    if (_isCurrentUserParticipant) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
        onPressed: _isLoading ? null : () => _toggleParticipation(event),
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.white) 
          : const Text('SAIR DO EVENTO'),
      );
    }
    
    if (_hasUserRequested) {
      return const ElevatedButton(
        onPressed: null, 
        style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.grey)),
        child: Text('SOLICITAÇÃO ENVIADA'),
      );
    }
    
    if (isFull) {
       return const ElevatedButton(
        onPressed: null, 
        style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.grey)),
        child: Text('EVENTO LOTADO'),
      );
    }
    
    if (event.isPrivate) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
        onPressed: _isLoading ? null : () => _toggleParticipation(event),
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.white) 
          : const Text('SOLICITAR PARTICIPAÇÃO'),
      );
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
      onPressed: _isLoading ? null : () => _toggleParticipation(event),
      child: _isLoading 
        ? const CircularProgressIndicator(color: Colors.white) 
        : const Text('PARTICIPAR'),
    );
  }

  Widget _buildPendingParticipantsSection(Event event) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Solicitações Pendentes (${event.pendingParticipants.length})",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
          ),
          const SizedBox(height: 10),
          // Lista de usuários pendentes
          ListView.builder(
            shrinkWrap: true, // Para caber dentro do SliverList
            physics: const NeverScrollableScrollPhysics(),
            itemCount: event.pendingParticipants.length,
            itemBuilder: (context, index) {
              final user = event.pendingParticipants[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.avatarUrl.isNotEmpty
                      ? user.avatarUrl
                      : 'https://avatar.iran.liara.run/public/boy?username=${user.id}'),
                ),
                title: Text(user.name),
                trailing: _isLoading
                  ? const CircularProgressIndicator()
                  : TextButton(
                      child: const Text('Aprovar'),
                      onPressed: () => _approveParticipant(user),
                    ),
              );
            },
          ),
          const Divider(height: 40, indent: 20, endIndent: 20),
        ],
      ),
    );
  }

  Widget _buildInfoRow(Event event) {
    final date = "${event.dateTime.day}/${event.dateTime.month}";
    final time = "${event.dateTime.hour}:${event.dateTime.minute.toString().padLeft(2, '0')}";
    final locationText = (event.location.name.isNotEmpty
        ? event.location.name
        : (event.location.address.isNotEmpty ? event.location.address : 'Local não informado'));

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InfoItem(icon: Icons.calendar_today, text: date),
            InfoItem(icon: Icons.access_time_filled, text: time),
            InfoItem(icon: Icons.bar_chart, text: event.skillLevel),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, color: Colors.orangeAccent, size: 26),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  locationText,
                  style: const TextStyle(fontSize: 22),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildOrganizerInfo(LocalUser organizer) {
      return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(organizer.avatarUrl),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Organizado por", style: TextStyle(color: Colors.grey)),
              Text(organizer.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildParticipantsSection(Event event) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Quem vai? (${event.participants.length}/${event.maxParticipants})", 
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40, 
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: event.participants.length,
              itemBuilder: (context, index) {
                final user = event.participants[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(user.avatarUrl.isNotEmpty
                        ? user.avatarUrl
                        : 'https://avatar.iran.liara.run/public/boy?username=${user.id}'), // <-- AQUI NÃO MUDA (LocalUser não tem 'genero')
                     onBackgroundImageError: (exception, stackTrace) {},
                     radius: 18,
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const InfoItem({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.orangeAccent, size: 28),
        const SizedBox(height: 8),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}