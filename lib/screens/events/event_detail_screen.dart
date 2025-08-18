// lib/screens/event/event_detail_screen.dart

import 'package:flutter/material.dart';
import '../../models/event_model.dart'; // Importa nosso modelo

class EventDetailScreen extends StatelessWidget {
  // Recebe um objeto Event no construtor
  final Event event;
  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar que encolhe, AGORA COM DADOS DINÂMICOS
          SliverAppBar(
            expandedHeight: 200.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                event.title, // Usa o título do evento
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              background: Image.network(
                event.imageUrl, // Usa a imagem do evento
                fit: BoxFit.cover,
                color: Colors.black.withValues(),
                colorBlendMode: BlendMode.darken,
              ),
            ),
          ),
          
          // Conteúdo rolável da tela, AGORA COM DADOS DINÂMICOS
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 20),
              // Seção de informações rápidas
              _buildInfoRow(event),
              const Divider(height: 40, indent: 20, endIndent: 20),
              // Seção do Organizador
              _buildOrganizerInfo(event.organizer),
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
                  event.description, // Usa a descrição do evento
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
              const Divider(height: 40, indent: 20, endIndent: 20),
               // Seção de Participantes
              _buildParticipantsSection(event),
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
          ),
          onPressed: () {},
          child: const Text("PARTICIPAR", style: TextStyle(fontSize: 16)),
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
      return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=a042581f4e29026704d'),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Organizado por", style: TextStyle(color: Colors.grey)),
              Text("Carlos Silva", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
          // Cria os avatares dinamicamente
          Row(
            children: event.participants.map((user) => 
              Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: CircleAvatar(backgroundImage: NetworkImage(user.avatarUrl)),
              )
            ).toList(),
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