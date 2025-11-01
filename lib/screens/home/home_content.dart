import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../api/event_service.dart';
import '../../models/event_model.dart';
import '../events/event_detail_screen.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String _selectedSport = 'Todos';
  final EventService _eventService = EventService(); 
  static const LatLng _initialPosition = LatLng(-24.9555, -53.4552);

  Position? _currentPosition; 
  // Guarda o Stream que será ouvido (agora é dinâmico)
  Stream<List<Event>>? _eventsStream;
  // Controla o estado de carregamento da localização
  bool _isLoadingLocation = true;
  String? _locationError;
  GoogleMapController? _mapController;
  
  // TODO: Raio de busca em KM (pode ser um filtro no futuro)
  final double _searchRadiusKm = 20.0;

  @override
  void initState() {
    super.initState();
    _fetchLocationAndLoadEvents();
  }

  // --- NOVA FUNÇÃO: Busca localização e define o Stream ---
  Future<void> _fetchLocationAndLoadEvents() async {
    if (!mounted) return;
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });
    
    try {
      Position position = await _determinePosition();
      if (!mounted) return;

      setState(() {
        _currentPosition = position;
        // DEFINE O STREAM para usar a nova função do serviço
        _eventsStream = _eventService.getNearbyEvents(position, _searchRadiusKm);
        _isLoadingLocation = false;
        
        // Opcional: mover o mapa para a localização do usuário
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude),
          ),
        );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _locationError = e.toString();
        _isLoadingLocation = false;
        
        // Fallback: Se der erro, carrega eventos próximos da localização PADRÃO (Cascavel)
         _eventsStream = _eventService.getNearbyEvents(
            Position(
              latitude: _initialPosition.latitude, 
              longitude: _initialPosition.longitude, 
              timestamp: DateTime.now(), accuracy: 0, altitude: 0, 
              altitudeAccuracy: 0, heading: 0, headingAccuracy: 0, speed: 0, speedAccuracy: 0
            ), 
            _searchRadiusKm
         );
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
  return Stack(
      children: [
        // --- CONTEÚDO PRINCIPAL (MAPA) ---
        _buildMap(),
        
        // --- PAINEL DESLIZANTE ---
        _buildSlidingPanel(),

        // --- BARRAS DE FILTRO SUPERIORES ---
        _buildTopFilterBars(),
        
        // --- INDICADOR DE LOADING DE LOCALIZAÇÃO ---
        // Se estiver carregando a localização (não os eventos), mostra um loading
        if (_isLoadingLocation)
          Container(
            color: Colors.white.withValues(alpha: 0.5),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text("Buscando sua localização...")
                ],
              ),
            ),
          ),
          
        // --- MENSAGEM DE ERRO DE LOCALIZAÇÃO ---
        if (_locationError != null && !_isLoadingLocation)
           Positioned(
             top: 150, // Posição abaixo dos filtros
             left: 16,
             right: 16,
             child: Material(
               elevation: 4,
               color: Colors.red[100],
               borderRadius: BorderRadius.circular(8),
               child: Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Icon(Icons.location_off, color: Colors.red[700]),
                     Expanded(child: Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 8.0),
                       child: Text("Não foi possível obter sua localização.", style: TextStyle(color: Colors.red[700])),
                     )),
                     IconButton(icon: Icon(Icons.refresh, color: Colors.red[700]), onPressed: _fetchLocationAndLoadEvents)
                   ],
                 ),
               ),
             ),
           ),
      ],
    );
  }

  Widget _buildMap() {
    // Se o stream ainda não foi definido (enquanto busca localização)
    // Mostra o mapa centralizado em Cascavel, sem marcadores.
    if (_eventsStream == null) {
      return GoogleMap(
          initialCameraPosition: const CameraPosition(target: _initialPosition, zoom: 13),
          onMapCreated: (controller) => _mapController = controller,
          markers: const {},
      );
    }
    
    // Constrói o mapa usando o _eventsStream (que foi definido após pegar a localização)
    return StreamBuilder<List<Event>>(
      stream: _eventsStream, // Ouve o stream de estado
      builder: (context, snapshot) {
        
        Set<Marker> markers = {};
        
        // Se temos dados, criamos os marcadores
        if (snapshot.hasData) {
          markers = snapshot.data!.map((event) {
            return Marker(
              markerId: MarkerId(event.id),
              position: LatLng(
                event.location.coordinates.latitude,
                event.location.coordinates.longitude,
              ),
              infoWindow: InfoWindow(
                title: event.title,
                snippet: event.location.name,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EventDetailScreen(event: event),
                    ),
                  );
                },
              ),
            );
          }).toSet();
        }
        
        // Se estamos carregando os eventos (após pegar localização),
        // mostramos o mapa na posição do usuário, mas sem marcadores ainda.
        // O CircularProgressIndicator do painel indicará o loading.

        return GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _currentPosition != null 
                ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                : _initialPosition,
            zoom: 13,
          ),
          onMapCreated: (controller) => _mapController = controller,
          markers: markers,
          myLocationEnabled: true, // Habilita o pontinho azul do usuário
          myLocationButtonEnabled: true,
        );
      },
    );
  }

  // --- WIDGET DO PAINEL (Baseado no Stream dinâmico) ---
  Widget _buildSlidingPanel() {
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
              // StreamBuilder para ouvir os eventos do Firebase em tempo real.
              child: StreamBuilder<List<Event>>(
                stream: _eventsStream, // Ouve o MESMO stream do mapa
                builder: (context, snapshot) {
                  
                  // Se o stream é nulo, estamos esperando a localização
                  if (_eventsStream == null) {
                    return _buildPanelHeader(0, "Buscando localização...");
                  }
                  
                  // Se estamos esperando os eventos do stream
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Column(
                      children: [
                        _buildPanelHeader(0, "Carregando eventos..."),
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ],
                    );
                  }
                  
                  if (snapshot.hasError) {
                    return _buildPanelHeader(0, "Erro ao carregar eventos.");
                  }

                  final events = snapshot.data ?? [];
                  
                  // Se não houver dados.
                  if (events.isEmpty) {
                    return ListView(
                      controller: scrollController,
                      children: [
                         _buildPanelHeader(0, "Nenhum evento encontrado por perto."),
                      ],
                    );
                  }

                  // Temos eventos!
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: events.length + 1, // +1 para o cabeçalho
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildPanelHeader(events.length, "${events.length} Eventos encontrados");
                      }
                      final event = events[index - 1];
                      return _buildEventListItem(event);
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // --- Widgets Auxiliares (refatorados) ---

  // Header do painel agora aceita uma mensagem customizada
  Widget _buildPanelHeader(int count, String message) {
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
          message, // Usa a mensagem dinâmica
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
  
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
                  color: Colors.black.withValues(alpha: 0.1), // Correção
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
            // TODO: Adicionar lógica de filtro aqui
          });
        },
        backgroundColor: Colors.white.withValues(alpha: 0.8), // Correção
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
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                // Usa a imageUrl do evento, ou um placeholder se vazia
                event.imageUrl.isNotEmpty ? event.imageUrl : 'https://picsum.photos/seed/${event.id}/200/200',
                width: 70,
                height: 70,
                fit: BoxFit.cover,
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
                    // Formatando data e hora
                    "${event.location.name} • ${event.dateTime.day}/${event.dateTime.month} às ${event.dateTime.hour.toString().padLeft(2, '0')}:${event.dateTime.minute.toString().padLeft(2, '0')}",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // --- FUNÇÃO HELPER DO GEOLOCATOR (Padrão) ---
  /// Determina a posição atual do dispositivo.
  /// Quando os serviços de localização não estão ativados ou
  /// as permissões são negadas, um 'Exception' é lançado.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Testa se os serviços de localização estão ativos.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Serviços de localização não estão ativos. Não é possível continuar
      // acessando a posição e requisita a ativação.
      throw Exception('Serviços de localização estão desativados.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissões negadas.
        throw Exception('Permissão de localização negada.');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissões negadas para sempre.
      throw Exception(
          'Permissão de localização negada permanentemente. Não é possível requisitar permissões.');
    } 

    // Quando chegamos aqui, as permissões estão garantidas e
    // podemos continuar acessando a posição do dispositivo.
    return await Geolocator.getCurrentPosition();
  }
}
