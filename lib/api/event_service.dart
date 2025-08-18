// lib/api/event_service.dart

import '../models/event_model.dart';

class EventService {
  // --- NOSSO BANCO DE DADOS LOCAL (MOCK) ---
  final List<Event> _mockEvents = [
    Event(
      id: 'evt001',
      title: 'Futebol de Sábado',
      description: 'Partida amistosa para todos os níveis no gramado principal do parque. O objetivo é se divertir e fazer novos amigos. Leve chuteira e venha jogar!',
      sport: 'Futebol',
      dateTime: DateTime(2025, 8, 16, 16, 0), // 16 de Agosto de 2025, 16:00
      location: Location(name: 'Parque Tarquínio', address: 'Av. Tarquínio Joslin dos Santos, 123'),
      imageUrl: 'https://images.unsplash.com/photo-1551958214-2d59cc7a2a4a?q=80&w=2071&auto=format&fit=crop',
      organizer: LocalUser(id: 'usr01', name: 'Carlos Silva', avatarUrl: 'https://i.pravatar.cc/150?u=carlos'),
      participants: [
        LocalUser(id: 'usr02', name: 'Ana Beatriz', avatarUrl: 'https://i.pravatar.cc/150?u=ana'),
        LocalUser(id: 'usr03', name: 'Lucas Souza', avatarUrl: 'https://i.pravatar.cc/150?u=lucas'),
      ],
      maxParticipants: 12,
    ),
    Event(
      id: 'evt002',
      title: 'Corrida no Lago',
      description: 'Corrida leve de 5km ao redor do Lago Municipal. Ponto de encontro no quiosque principal. Ritmo tranquilo, ideal para iniciantes.',
      sport: 'Corrida',
      dateTime: DateTime(2025, 8, 17, 7, 30), // 17 de Agosto de 2025, 07:30
      location: Location(name: 'Lago Municipal de Cascavel', address: 'Av. Brasil, s/n'),
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=2070&auto=format&fit=crop',
      organizer: LocalUser(id: 'usr02', name: 'Ana Beatriz', avatarUrl: 'https://i.pravatar.cc/150?u=ana'),
      participants: [
        LocalUser(id: 'usr01', name: 'Carlos Silva', avatarUrl: 'https://i.pravatar.cc/150?u=carlos'),
        LocalUser(id: 'usr04', name: 'Mariana Lima', avatarUrl: 'https://i.pravatar.cc/150?u=mariana'),
        LocalUser(id: 'usr05', name: 'Pedro Costa', avatarUrl: 'https://i.pravatar.cc/150?u=pedro'),
      ],
      maxParticipants: 20,
    ),
  ];

  // Método para buscar todos os eventos (simula uma chamada de API)
  List<Event> getEvents() {
    return _mockEvents;
  }
}