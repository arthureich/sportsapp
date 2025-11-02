import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../api/event_service.dart';
import '../../models/event_model.dart';
import '../../api/rating_service.dart';
import '../../api/user_service.dart';
import '../../models/rating_model.dart';
import '../events/event_detail_screen.dart';

class MyEventsScreen extends StatefulWidget { // 1. Converter para StatefulWidget
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> { 
  final EventService _eventService = EventService();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  // --- INSTÂNCIAS DOS NOVOS SERVIÇOS ---
  final RatingService _ratingService = RatingService();
  final UserService _userService = UserService();
  bool _isRating = false; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Agenda', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey.shade50,
      ),
      backgroundColor: Colors.grey.shade100,
      body: StreamBuilder<List<Event>>(
        stream: _eventService.getEvents(), // Continua buscando todos os eventos
        builder: (context, snapshot) {
          // ... (Tratamento de Estados: waiting, error, no-user) ...
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar os eventos.'));
          }
          if (_currentUserId == null) {
             return const Center(child: Text('Faça login para ver seus eventos.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final allEvents = snapshot.data!;
          
          // Separa os eventos em futuros e passados
          final now = DateTime.now();
          final List<Event> myEvents = allEvents
              .where((event) =>
                  event.organizer.id == _currentUserId ||
                  event.participants.any((p) => p.id == _currentUserId))
              .toList();

          final pastEvents = myEvents.where((e) => e.dateTime.isBefore(now)).toList();
          final upcomingEvents = myEvents.where((e) => e.dateTime.isAfter(now)).toList();

          // Ordena os passados (mais recente primeiro) e futuros (mais próximo primeiro)
          pastEvents.sort((a, b) => b.dateTime.compareTo(a.dateTime));
          upcomingEvents.sort((a, b) => a.dateTime.compareTo(b.dateTime));
          
          if (myEvents.isEmpty) {
            return _buildEmptyState();
          }

          // 3. Usa um ListView com títulos de seção
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              if (upcomingEvents.isNotEmpty) ...[
                const Text("PRÓXIMOS EVENTOS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                ...upcomingEvents.map((event) => EventCard(
                      event: event,
                      isPast: false,
                      onRatePressed: () {}, // Não avalia eventos futuros
                    )).toList(),
                const SizedBox(height: 24),
              ],
              
              if (pastEvents.isNotEmpty) ...[
                const Text("EVENTOS PASSADOS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                ...pastEvents.map((event) => EventCard(
                      event: event,
                      isPast: true,
                      onRatePressed: () {
                        // 4. CHAMA O MODAL DE AVALIAÇÃO
                        _showRatingModal(event);
                      },
                    )).toList(),
              ],
            ],
          );
        },
      ),
    );
  }

  // --- ETAPA 3: UI DE AVALIAÇÃO (O MODAL) ---
  void _showRatingModal(Event event) {
    // Filtra o próprio usuário da lista
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
        return StatefulBuilder( // Necessário para atualizar o estado *dentro* do modal
          builder: (modalContext, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: 400, // Altura definida
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
                          // Widget para mostrar o participante e as estrelas
                          return _RatingParticipantTile(
                            participant: participant,
                            ratingService: _ratingService,
                            eventId: event.id,
                            raterUserId: _currentUserId!,
                            onRatingSubmited: (ratedUserId, newScore) {
                              // --- ETAPA 4: LÓGICA DE CÁLCULO ---
                              _handleRatingLogic(ratedUserId);
                              // Atualiza a UI do modal
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

  // --- ETAPA 4: LÓGICA DE CÁLCULO (Client-Side) ---
  Future<void> _handleRatingLogic(String ratedUserId) async {
    setState(() => _isRating = true); // Ativa o loading
    try {
      // 1. Busca todas as avaliações do usuário que foi avaliado
      final allRatings = await _ratingService.getRatingsForUser(ratedUserId);

      if (allRatings.isEmpty) {
        setState(() => _isRating = false);
        return; // Não deveria acontecer, pois acabamos de adicionar uma
      }

      // 2. Calcula a nova média
      final sum = allRatings.map((r) => r.score).reduce((a, b) => a + b);
      final newAverage = sum / allRatings.length;

      // 3. Atualiza o score no perfil do usuário
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
      if(mounted) setState(() => _isRating = false); // Desativa o loading
    }
  }


  Widget _buildEmptyState() {
    // ... (seu widget _buildEmptyState existente) ...
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 60, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            'Nenhum evento agendado ainda.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 10),
          Text(
            'Crie ou participe de um evento para vê-lo aqui!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

// --- WIDGET DO CARD DE EVENTO MODIFICADO ---
class EventCard extends StatelessWidget {
  final Event event;
  final bool isPast;
  final VoidCallback onRatePressed;

  const EventCard({
    super.key, 
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
              // ... (Row com Avatar e Título existente) ...
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
              // ... (Row com Data/Hora existente) ...
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
              // ... (Row com Localização existente) ...
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

              // --- NOVO BOTÃO DE AVALIAR ---
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

// --- NOVO WIDGET INTERNO PARA O MODAL ---
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

  // Verifica se esta avaliação específica já foi feita
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
      id: '', // O ID será o docId gerado no serviço
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
    // Chama a função de callback para recalcular o score geral do usuário
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

    // Se não foi avaliado, mostra as estrelas
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
              _submit(starScore); // Salva imediatamente ao clicar
            },
          );
        }),
      ),
    );
  }
}