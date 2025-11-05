import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/event_service.dart';
import 'package:flutter_application_1/data/predefined_locations.dart';
import 'package:flutter_application_1/models/event_model.dart';
import 'package:flutter_application_1/screens/events/create_event_screen.dart';
import 'package:flutter_application_1/screens/events/event_detail_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PredefinedLocationDetailScreen extends StatefulWidget {
  final PredefinedLocation location;
  const PredefinedLocationDetailScreen({super.key, required this.location});

  @override
  State<PredefinedLocationDetailScreen> createState() => _PredefinedLocationDetailScreenState();
}

class _PredefinedLocationDetailScreenState extends State<PredefinedLocationDetailScreen> {
  final EventService _eventService = EventService();
  late Stream<List<Event>> _eventsStream;

  @override
  void initState() {
    super.initState();
    _eventsStream = _eventService.getUpcomingEventsForLocation(widget.location.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => CreateEventScreen(predefinedLocation: widget.location),
          ));
        },
        icon: const Icon(Icons.add),
        label: const Text('Criar Evento Aqui'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildHeader(),
              _buildPossibleSports(),
              _buildUpcomingEvents(),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250.0,
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.location.name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        background: Image.network(
          widget.location.imageUrl,
          fit: BoxFit.cover,
          color: Colors.black.withValues(alpha: 0.4),
          colorBlendMode: BlendMode.darken,
          errorBuilder: (context, e, s) => Container(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Sobre o Local",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.location.description,
            style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPossibleSports() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Esportes Comuns",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: widget.location.possibleSports.map((sport) {
              return Chip(
                label: Text(sport),
                backgroundColor: Colors.green[50],
                labelStyle: TextStyle(color: Colors.green[800]),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEvents() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Próximos Eventos no Local",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          StreamBuilder<List<Event>>(
            stream: _eventsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Erro ao carregar eventos.'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Nenhum evento futuro marcado aqui ainda.', style: TextStyle(color: Colors.grey)),
                  ),
                );
              }

              final events = snapshot.data!;
              return ListView.builder(
                shrinkWrap: true, 
                physics: const NeverScrollableScrollPhysics(),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return _buildEventListItem(event);
                },
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildEventListItem(Event event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!)
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EventDetailScreen(event: event)),
          );
        },
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            event.imageUrl.isNotEmpty ? event.imageUrl : 'https://picsum.photos/seed/${event.id}/200/200',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(width: 50, height: 50, color: Colors.grey[200]),
          ),
        ),
        title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          "${event.sport} • ${event.dateTime.day}/${event.dateTime.month} às ${event.dateTime.hour.toString().padLeft(2, '0')}:${event.dateTime.minute.toString().padLeft(2, '0')}",
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}