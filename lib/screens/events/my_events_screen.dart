import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../api/event_service.dart';
import '../../models/event_model.dart';
import '../events/event_detail_screen.dart';

class MyEventsScreen extends StatelessWidget {
  const MyEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EventService eventService = EventService();
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Agenda', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey.shade50,
      ),
      backgroundColor: Colors.grey.shade100,
      // Usamos um StreamBuilder para ouvir as atualizações do Firestore em tempo real
      body: StreamBuilder<List<Event>>(
        stream: eventService.getEvents(), // Continua buscando todos os eventos
        builder: (context, snapshot) {
          // --- Tratamento de Estados (sem alterações) ---
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar os eventos.'));
          }
          // 3. Verifica se o usuário está logado ANTES de filtrar
          if (currentUserId == null) {
             return const Center(child: Text('Faça login para ver seus eventos.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState(); // Mostra estado vazio se não houver eventos no geral
          }

          // 4. Filtra os eventos usando o ID REAL do usuário logado
          final List<Event> myEvents = snapshot.data!
              .where((event) =>
                  event.organizer.id == currentUserId || // Verifica se é organizador
                  event.participants.any((p) => p.id == currentUserId)) // Verifica se é participante
              .toList();

          // Se após o filtro a lista estiver vazia, mostra estado vazio
          if (myEvents.isEmpty) {
            return _buildEmptyState();
          }

          // --- Construção da Lista (sem alterações) ---
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: myEvents.length,
            itemBuilder: (context, index) {
              final event = myEvents[index];
              // Usar o EventCard existente
              return EventCard(event: event);
            },
          );
        },
      ),
    );
  }

  // Widget para o estado de "nenhum evento"
  Widget _buildEmptyState() {
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

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({super.key, required this.event});

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
            ],
          ),
        ),
      ),
    );
  }
}