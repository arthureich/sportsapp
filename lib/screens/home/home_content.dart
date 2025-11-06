import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:ui';
import '../locations/predefined_location_detail_screen.dart';
import '../events/event_detail_screen.dart';
import '../../api/event_service.dart';
import '../../models/event_model.dart';
import '../../data/predefined_locations.dart'; 

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
  Stream<List<Event>>? _eventsStream;
  bool _isLoadingLocation = true;
  String? _locationError;
  GoogleMapController? _mapController;
  DateTime? _filterDate;
  double _filterDistance = 20.0;
  bool _filterHasVacancies = false;
  TimeOfDay? _filterTime;
  final double _searchRadiusKm = 25.0;

  @override
  void initState() {
    super.initState();
    _fetchLocationAndLoadEvents();
  }

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
        _eventsStream = _eventService.getNearbyEvents(position, _searchRadiusKm).asBroadcastStream();
        _isLoadingLocation = false;
        
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(position.latitude, position.longitude),
            13,
          ),
        );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _locationError = e.toString();
        _isLoadingLocation = false;
        
         _eventsStream = _eventService.getNearbyEvents(
            Position(
              latitude: _initialPosition.latitude, 
              longitude: _initialPosition.longitude, 
              timestamp: DateTime.now(), accuracy: 0, altitude: 0, 
              altitudeAccuracy: 0, heading: 0, headingAccuracy: 0, speed: 0, speedAccuracy: 0
            ), 
            _filterDistance
         ).asBroadcastStream();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
  return Stack(
      children: [
        _buildMap(),
        _buildSlidingPanel(),
        _buildTopFilterBars(),
        
        if (_isLoadingLocation)
          Container(
            color: Colors.white.withValues(alpha:0.5),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text("Buscando sua localização...", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
                ],
              ),
            ),
          ),
          
        if (_locationError != null && !_isLoadingLocation)
           Positioned(
             top: 150,
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
    final Map<String, PredefinedLocation> predefinedLocationMap = {
      for (var loc in predefinedLocationsCascavel) 
        '${loc.coordinates.latitude.toStringAsFixed(5)},${loc.coordinates.longitude.toStringAsFixed(5)}': loc
    };
    if (_eventsStream == null) {
      final Set<Marker> greenMarkers = predefinedLocationsCascavel.map((loc) {
        return _createLocationMarker(loc, false); 
      }).toSet();
      return GoogleMap(
          initialCameraPosition: const CameraPosition(target: _initialPosition, zoom: 13),
          onMapCreated: (controller) => _mapController = controller,
          markers: greenMarkers,
      );
    }
    
    return StreamBuilder<List<Event>>(
      stream: _eventsStream,
      builder: (context, snapshot) {
        Set<String> locationsWithEvents = {};
        Set<Marker> markersToShow = {};
        if (snapshot.hasData) {
          final allEvents = snapshot.data!;
          final filteredEvents = (_selectedSport == 'Todos')
              ? allEvents 
              : allEvents
                  .where((event) => event.sport == _selectedSport)
                  .toList();
        for (final event in filteredEvents) {
            final eventPosition = LatLng(
                event.location.coordinates.latitude,
                event.location.coordinates.longitude,
              );
            final eventPosKey = '${eventPosition.latitude.toStringAsFixed(5)},${eventPosition.longitude.toStringAsFixed(5)}';
            if (predefinedLocationMap.containsKey(eventPosKey)) {
              final loc = predefinedLocationMap[eventPosKey]!;
              markersToShow.add(_createLocationMarker(loc, true)); // true = com evento
              locationsWithEvents.add(loc.name); 
            } else {
              markersToShow.add(_createEventMarker(event));
            }
          }
        }
        for (final loc in predefinedLocationsCascavel) {
          if (!locationsWithEvents.contains(loc.name)) {
            markersToShow.add(_createLocationMarker(loc, false)); 
          }
        }
        return GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _currentPosition != null 
                ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                : _initialPosition,
            zoom: 13,
          ),
          onMapCreated: (controller) => _mapController = controller,
          markers: markersToShow,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
        );
      },
    );
  }

  Marker _createEventMarker(Event event) {
    return Marker(
      markerId: MarkerId(event.id),
      position: LatLng(
        event.location.coordinates.latitude,
        event.location.coordinates.longitude,
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed), 
      infoWindow: InfoWindow(
        title: event.title,
        snippet: "Clique para ver detalhes do evento",
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EventDetailScreen(event: event),
            ),
          );
        },
      ),
    );
  }

  Marker _createLocationMarker(PredefinedLocation loc, bool hasEvent) {
    return Marker(
      markerId: MarkerId('loc_${loc.name}'),
      position: LatLng(loc.coordinates.latitude, loc.coordinates.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        hasEvent ? BitmapDescriptor.hueOrange : BitmapDescriptor.hueGreen
      ),
      infoWindow: InfoWindow(
        title: loc.name,
        snippet: hasEvent 
          ? "Local com eventos! Clique para ver." 
          : "Local livre. Clique para ver.",
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => PredefinedLocationDetailScreen(location: loc),
          ));
        },
      ),
    );
  }

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
              child: StreamBuilder<List<Event>>(
                stream: _eventsStream, 
                builder: (context, snapshot) {
                  
                  if (_eventsStream == null) {
                    return _buildPanelHeader(0, "Buscando localização...");
                  }
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
                  final allEvents = snapshot.data ?? [];
                  final events = (_selectedSport == 'Todos')
                      ? allEvents
                      : allEvents
                          .where((event) => event.sport == _selectedSport)
                          .toList();
                  
                  if (events.isEmpty) {
                    final message = _selectedSport == 'Todos'
                        ? "Nenhum evento encontrado por perto."
                        : "Nenhum evento de '$_selectedSport' encontrado.";
                    return ListView(
                      controller: scrollController,
                      children: [
                        _buildPanelHeader(0, message),
                      ],
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
                    itemCount: events.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildPanelHeader(
                            events.length, "${events.length} Eventos encontrados");
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
          message,
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
                  color: Colors.black.withValues(alpha: 0.1), // Corrigido
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
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (modalContext) => Container(
                      height: MediaQuery.of(context).size.height * 0.7,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setModalState) {
                          return Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 10),
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    const Text(
                                      'Filtros Avançados',
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () => Navigator.pop(modalContext),
                                    ),
                                  ],
                                ),
                              ),

                              Expanded(
                                child: ListView(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  children: [
                                    const Text('Data e Hora', style: TextStyle(fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            icon: const Icon(Icons.calendar_today),
                                            label: Text(_filterDate == null 
                                              ? 'Selecionar Data'
                                              : '${_filterDate!.day}/${_filterDate!.month}/${_filterDate!.year}'),
                                            onPressed: () async {
                                              final date = await showDatePicker(
                                                context: context,
                                                initialDate: _filterDate ?? DateTime.now(),
                                                firstDate: DateTime.now(),
                                                lastDate: DateTime.now().add(const Duration(days: 365)),
                                              );
                                              if (date != null) {
                                                setModalState(() => _filterDate = date);
                                              }
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            icon: const Icon(Icons.access_time),
                                            label: Text(_filterTime == null 
                                              ? 'Selecionar Hora'
                                              : '${_filterTime!.hour}:${_filterTime!.minute.toString().padLeft(2, '0')}'),
                                            onPressed: () async {
                                              final time = await showTimePicker(
                                                context: context,
                                                initialTime: _filterTime ?? TimeOfDay.now(),
                                              );
                                              if (time != null) {
                                                setModalState(() => _filterTime = time);
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Distância máxima', style: TextStyle(fontWeight: FontWeight.w500)),
                                        Text('${_filterDistance.round()} km', style: TextStyle(color: Colors.grey[600])),
                                      ],
                                    ),
                                    Slider(
                                      value: _filterDistance,
                                      min: 1,
                                      max: 50,
                                      divisions: 49,
                                      label: '${_filterDistance.round()} km',
                                      onChanged: (value) => setModalState(() => _filterDistance = value),
                                    ),
                                    const SizedBox(height: 24),

                                    SwitchListTile(
                                      title: const Text('Apenas com vagas disponíveis', 
                                        style: TextStyle(fontWeight: FontWeight.w500)),
                                      value: _filterHasVacancies,
                                      onChanged: (value) => setModalState(() => _filterHasVacancies = value),
                                    ),
                                  ],
                                ),
                              ),
                              
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          setModalState(() { 
                                            _filterDate = null;
                                            _filterTime = null;
                                            _filterDistance = 20.0;
                                            _filterHasVacancies = false;
                                          });
                                          _applyFilters(modalContext); 
                                        },
                                        child: const Text('Limpar Filtros'),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: FilledButton(
                                        onPressed: () {
                                          _applyFilters(modalContext);
                                        },
                                        child: const Text('Aplicar'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        } 
                      ),
                    ),
                  );
                },
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
  void _applyFilters(BuildContext modalContext) {
    if (_currentPosition != null) {
      setState(() {
        _eventsStream = _eventService
            .getNearbyEvents(_currentPosition!, _filterDistance)
            .map((events) => events.where((event) {
                  if (_filterDate != null) {
                    final eventDate = event.dateTime;
                    if (eventDate.year != _filterDate!.year ||
                        eventDate.month != _filterDate!.month ||
                        eventDate.day != _filterDate!.day) {
                      return false;
                    }
                  }
                  if (_filterTime != null) {
                    final eventTime = TimeOfDay.fromDateTime(event.dateTime);
                    final eventTotalMinutes = eventTime.hour * 60 + eventTime.minute;
                    final filterTotalMinutes = _filterTime!.hour * 60 + _filterTime!.minute;
                    if (eventTotalMinutes < filterTotalMinutes) {
                      return false;
                    }
                  }
                  if (_filterHasVacancies) {
                    if (event.participants.length >= event.maxParticipants) {
                      return false;
                    }
                  }
                  return true;
                }).toList())
            .asBroadcastStream();
      });
    }

    String filterMessage = 'Filtros aplicados: ';
    List<String> activeFilters = [];
    if (_filterDate != null) {
      activeFilters.add('Data: ${_filterDate!.day}/${_filterDate!.month}');
    }
    if (_filterTime != null) {
      activeFilters.add('A partir de: ${_filterTime!.hour}:${_filterTime!.minute.toString().padLeft(2, '0')}');
    }
    activeFilters.add('Distância: ${_filterDistance.round()}km');
    if (_filterHasVacancies) {
      activeFilters.add('Apenas com vagas');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(activeFilters.isEmpty ? 'Filtros limpos!' : filterMessage + activeFilters.join(', ')),
        duration: const Duration(seconds: 3),
      ),
    );

    Navigator.pop(modalContext); 
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
            MaterialPageRoute(builder: (context) => EventDetailScreen(event: event)), //
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
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
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Serviços de localização estão desativados.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permissão de localização negada.');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Permissão de localização negada permanentemente. Não é possível requisitar permissões.');
    } 

    return await Geolocator.getCurrentPosition();
  }
}
