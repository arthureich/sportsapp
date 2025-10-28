import 'package:flutter/material.dart';
import '../../api/event_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/event_model.dart'; 

class EventDetailScreen extends StatefulWidget {
  final Event event;
  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final EventService _eventService = EventService();
  bool _isLoading = false; // Para controlar o estado de loading do botão
  bool _isCurrentUserParticipant = false; // Para saber se o usuário atual participa
  int _currentParticipants = 0; // Para contagem atualizada

  @override
  void initState() {
    super.initState();
    _checkParticipationStatus(); // Verifica o status inicial
    _currentParticipants = widget.event.participants.length; // Define contagem inicial
  }

  // Função para verificar se o usuário logado está na lista de participantes
  void _checkParticipationStatus() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        _isCurrentUserParticipant = widget.event.participants.any((participant) => participant.id == currentUser.uid);
      });
    }
  }

  // Função chamada ao pressionar o botão principal
  Future<void> _toggleParticipation() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você precisa estar logado para participar.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Cria o objeto LocalUser do usuário atual
    final localUser = LocalUser(
      id: currentUser.uid,
      name: currentUser.displayName ?? 'Usuário Anônimo', // Usa displayName
      avatarUrl: currentUser.photoURL ?? 'https://avatar.iran.liara.run/public/boy?username=${currentUser.uid}', // Usa photoURL ou um fallback
    );

    try {
      if (_isCurrentUserParticipant) {
        // --- Lógica para SAIR ---
        await _eventService.leaveEvent(widget.event.id, localUser);
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Você saiu do evento.')),
            );
            setState(() { // Atualiza estado local imediatamente
               _isCurrentUserParticipant = false;
               _currentParticipants--;
             });
        }
      } else {
         // Verifica se há vagas antes de tentar entrar
         if (_currentParticipants >= widget.event.maxParticipants) {
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
           setState(() { // Atualiza estado local imediatamente
             _isCurrentUserParticipant = true;
             _currentParticipants++;
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

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    bool isParticipating = false;
    if (currentUser != null) {
        // Busca a versão mais recente do evento (se estiver usando StreamBuilder, isso seria automático)
        isParticipating = _isCurrentUserParticipant;
    }
    final bool isFull = _currentParticipants >= widget.event.maxParticipants;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.event.title, // Usa o título do evento
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              background: Image.network(
                widget.event.imageUrl, // Usa a imagem do evento
                fit: BoxFit.cover,
                color: Colors.black.withValues(),
                colorBlendMode: BlendMode.darken,
                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.sports_soccer, // Ícone de fallback
                      color: Colors.grey[400],
                      size: 60,
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Conteúdo rolável da tela, AGORA COM DADOS DINÂMICOS
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 20),
              // Seção de informações rápidas
              _buildInfoRow(widget.event),
              const Divider(height: 40, indent: 20, endIndent: 20),
              // Seção do Organizador
              _buildOrganizerInfo(widget.event.organizer),
              const SizedBox(height: 20),
              // Descrição
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text("Descrição", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  widget.event.description, // Usa a descrição do evento
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
              const Divider(height: 40, indent: 20, endIndent: 20),
               // Seção de Participantes
              _buildParticipantsSection(widget.event, _currentParticipants),
              const SizedBox(height: 100), // Espaço extra para o botão não cobrir o conteúdo
            ]),
          )
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orangeAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            disabledBackgroundColor: Colors.grey.shade400,
          ),
          onPressed: (_isLoading || (isFull && !isParticipating)) ? null : _toggleParticipation,
          child: _isLoading
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(
                  isParticipating
                      ? "SAIR DO EVENTO"
                      : (isFull ? "EVENTO LOTADO" : "PARTICIPAR"), // Muda texto
                  style: const TextStyle(fontSize: 16)
                ),
        ),
      ),

    );
  }

  // Métodos auxiliares agora recebem os dados necessários
  Widget _buildInfoRow(Event event) {
    final date = "${event.dateTime.day}/${event.dateTime.month}";
    final time = "${event.dateTime.hour}:${event.dateTime.minute.toString().padLeft(2, '0')}";
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        InfoItem(icon: Icons.calendar_today, text: date),
        InfoItem(icon: Icons.access_time_filled, text: time),
        InfoItem(icon: Icons.location_on, text: event.location.name),
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

  Widget _buildParticipantsSection(Event event, int currentCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Quem vai? ($currentCount/${event.maxParticipants})", // Usa contagem atual
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          // Exibe os avatares - Usar StreamBuilder aqui seria ideal para atualizar em tempo real
          // Por enquanto, usamos os dados do widget.event que foi passado inicialmente
          SizedBox(
            height: 40, // Define uma altura fixa para a linha de avatares
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
                        : 'https://avatar.iran.liara.run/public/boy?username=${user.id}'), // Placeholder
                     onBackgroundImageError: (exception, stackTrace) {}, // Ignora erros de imagem
                     radius: 18, // Um pouco menor para caber mais
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

// Widget auxiliar InfoItem (sem alterações)
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