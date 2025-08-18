// lib/screens/home/home_content.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';

import '../../api/event_service.dart';
import '../../models/event_model.dart';
import '../events/event_detail_screen.dart';

// Este widget contém APENAS o conteúdo visual da sua antiga home
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String _selectedSport = 'Todos';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          'assets/images/mapa_placeholder.png',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
        _buildSlidingPanel(),
        _buildTopFilterBars(),
      ],
    );
  }

  // Cole aqui os métodos que estavam na sua home_screen.dart:
  // _buildTopFilterBars(), _buildSportFilterChip(), _buildSlidingPanel(), _buildEventListItem()

  Widget _buildTopFilterBars() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Buscar endereço...',
                icon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: ['Todos', 'Futebol', 'Vôlei', 'Basquete', 'Corrida', 'Tênis']
                        .map((sport) => _buildSportFilterChip(sport))
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(
                      'assets/icons/filter.svg',
                      colorFilter: ColorFilter.mode(Colors.grey[800]!, BlendMode.srcIn),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSportFilterChip(String sport) {
    final bool isSelected = _selectedSport == sport;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(sport),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedSport = sport;
          });
        },
        backgroundColor: Colors.white.withValues(alpha: 0.8),
        selectedColor: const Color(0xFFC8E6C9),
        labelStyle: TextStyle(
          color: isSelected ? Colors.green[800] : Colors.black,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? Colors.green : Colors.transparent,
          ),
        ),
      ),
    );
  }

  Widget _buildSlidingPanel() {
    final EventService eventService = EventService();
    final List<Event> events = eventService.getEvents();

    return DraggableScrollableSheet(
      initialChildSize: 0.25,
      minChildSize: 0.25,
      maxChildSize: 0.75,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
              ),
              child: ListView.builder(
                controller: scrollController,
                itemCount: events.length + 1, // +1 para o cabeçalho
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Column(
                      children: [
                        const SizedBox(height: 12),
                        Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: const BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "${events.length} Eventos encontrados",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                      ],
                    );
                  }
                  final event = events[index - 1];
                  return _buildEventListItem(event);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventListItem(Event event) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
          )
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EventDetailScreen(event: event)),
          );
        },
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://picsum.photos/seed/${event.id}/200/200', 
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                // Adiciona um tratamento de erro simples para a imagem
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey[200],
                    child: Icon(Icons.sports_soccer, color: Colors.grey[400]),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${event.location.name} • ${event.dateTime.day}/${event.dateTime.month}",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}