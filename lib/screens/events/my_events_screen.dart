import 'package:flutter/material.dart';
import '../../api/event_service.dart'; 
import '../../models/event_model.dart'; 
import '../events/event_detail_screen.dart'; 

class MyEventsScreen extends StatelessWidget {
const MyEventsScreen({super.key});

@override
Widget build(BuildContext context) {
    final EventService eventService = EventService();
    // Simulando que o usuário 'usr01' é o logado
    final List<Event> myEvents = eventService.getEvents()
        .where((event) => 
            event.organizer.id == 'usr01' || 
            event.participants.any((p) => p.id == 'usr01')
        ).toList();

return Scaffold(
  appBar: AppBar(
    title: const Text('Minha Agenda', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
    centerTitle: true,
    elevation: 0,
    backgroundColor: Colors.grey.shade50,
  ),
  backgroundColor: Colors.grey.shade100,
  body: myEvents.isEmpty
      ? Center(
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
        )
      : ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: myEvents.length,
          itemBuilder: (context, index) {
            final event = myEvents.elementAt(index);
            return EventCard(event: event);
          },
        ),
);
}
}

// Widget para exibir cada evento na lista
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
                    "${event.dateTime.day}/${event.dateTime.month}/${event.dateTime.year}",
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