import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:ui';
import 'package:flutter/services.dart'; 
import 'dart:ui' as ui;
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
  List<String> _selectedSports = []; 
  final List<String> _allSports = const [
    'Futebol', 
    'Basquete', 
    'Vôlei', 
    'Tênis', 
    'Corrida', 
    'Ciclismo',
    'Natação', 
    'Beach Tennis', 
    'Futevôlei', 
    'Handebol', 
    'Padel', 
    'Skate', 
    'Outro' 
  ];
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
  final Map<String, BitmapDescriptor> _sportIcons = {};
  final Map<String, PredefinedLocation> _predefinedLocationLookup = {};
  BitmapDescriptor _emptyLocationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor _activeLocationIcon = BitmapDescriptor.defaultMarker;
  // ignore: unused_field
  bool _areIconsLoading = true;
  final TextEditingController _searchController = TextEditingController();
  List<PredefinedLocation> _searchResults = [];
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    for (var loc in predefinedLocationsCascavel) {
      final key = '${loc.coordinates.latitude.toStringAsFixed(5)},${loc.coordinates.longitude.toStringAsFixed(5)}';
      _predefinedLocationLookup[key] = loc;
    }
    _loadMarkerIcons().then((_) {
      _fetchLocationAndLoadEvents();
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      if (mounted) {
        setState(() {
          _searchResults = [];
        });
      }
      return;
    }

    final query = _searchController.text.toLowerCase();
    final results = predefinedLocationsCascavel.where((loc) {
      return loc.name.toLowerCase().contains(query) ||
             loc.description.toLowerCase().contains(query);
    }).toList();

    if (mounted) {
      setState(() {
        _searchResults = results;
      });
    }
  }

  void _navigateToLocation(PredefinedLocation location) {
    _searchController.clear();
    FocusScope.of(context).unfocus();
    setState(() {
      _searchResults = [];
      _isSearchFocused = false;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PredefinedLocationDetailScreen(location: location),
      ),
    );
  }

  Future<BitmapDescriptor> _getResizedAssetIcon(String path, int width) async {
    final ByteData data = await rootBundle.load(path);
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    final ui.FrameInfo fi = await codec.getNextFrame();
    final ByteData? byteData = await fi.image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
  }

  Future<void> _loadMarkerIcons() async {
    const int markerWidth = 40; 

    final iconsToLoad = {
      'futebol': 'assets/markers/futebol.png',
      'basquete': 'assets/markers/basquete.png',
      'vôlei': 'assets/markers/volei.png',
      'tênis': 'assets/markers/tenis.png',
      'corrida': 'assets/markers/corrida.png',
      'ciclismo': 'assets/markers/ciclismo.png',
      'beach tennis': 'assets/markers/beach_tennis.png',
      'futevôlei': 'assets/markers/futevolei.png',
      'handebol': 'assets/markers/handebol.png',
      'natação': 'assets/markers/natacao.png',
      'padel': 'assets/markers/padel.png',
      'skate': 'assets/markers/skate.png',
      'outro': 'assets/markers/outro.png',
    };

    for (var entry in iconsToLoad.entries) {
      try {
        _sportIcons[entry.key] = await _getResizedAssetIcon(entry.value, markerWidth);
      } catch (e) {
        debugPrint("Erro ao carregar ícone ${entry.value}: $e. Usando padrão.");
        _sportIcons[entry.key] = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      }
    }
    
    try {
      _emptyLocationIcon = await _getResizedAssetIcon('assets/markers/EventlessArena.png', markerWidth);
      _activeLocationIcon = await _getResizedAssetIcon('assets/markers/EventArena.png', markerWidth); 
    } catch (e) {
      _emptyLocationIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      _activeLocationIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    }

    if (mounted) {
      setState(() => _areIconsLoading = false);
    }
  }

  BitmapDescriptor _getIconForEvent(Event event) {
    final sportKey = event.sport.toLowerCase();
    return _sportIcons[sportKey] ?? _sportIcons['outro'] ?? BitmapDescriptor.defaultMarker;
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
    final panelMinHeight = MediaQuery.of(context).size.height * 0.10;
    return Stack(
      children: [
        _buildMap(),
        _buildSlidingPanel(),
        _buildTopFilterBars(),
        if (_isSearchFocused && _searchResults.isNotEmpty)
            Positioned(
              top: 110, 
              left: 16,
              right: 16,
              child: Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.3, 
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final location = _searchResults[index];
                      return ListTile(
                        title: Text(location.name),
                        subtitle: Text(
                          location.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        leading: const Icon(Icons.location_pin, color: Colors.orangeAccent),
                        onTap: () => _navigateToLocation(location),
                      );
                    },
                  ),
                ),
              ),
            ),
        Positioned(
            bottom: panelMinHeight + 5,
            right: 20,
            child: FloatingActionButton(
              mini: true, 
              onPressed: _animateToCurrentLocation,
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).primaryColor, 
              heroTag: 'myLocationBtn',
              child: const Icon(Icons.my_location),
            ),
          ),
        
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
        Positioned(
          bottom: panelMinHeight + 5, 
          left: 20,
          child: Column(
            children: [
              FloatingActionButton(
                mini: true,
                onPressed: _zoomIn,
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).primaryColor,
                heroTag: 'zoomInBtn',
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                mini: true,
                onPressed: _zoomOut,
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).primaryColor,
                heroTag: 'zoomOutBtn',
                child: const Icon(Icons.remove),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMap() {
    final Map<String, Marker> markers = {};
    if (_eventsStream == null) {
      for (var loc in predefinedLocationsCascavel) {
        markers[loc.name] = _createEmptyLocationMarker(loc);
      }
      return GoogleMap(
          initialCameraPosition: const CameraPosition(target: _initialPosition, zoom: 13),
          onMapCreated: (controller) => _mapController = controller,
          markers: markers.values.toSet(),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
      );
    }
    return StreamBuilder<List<Event>>(
      stream: _eventsStream,
      builder: (context, snapshot) {
        final hasActiveFilters = _selectedSports.isNotEmpty || 
                               _filterDate != null || 
                               _filterTime != null || 
                               _filterHasVacancies;
      
      if (!hasActiveFilters) {
        for (var loc in predefinedLocationsCascavel) {
          markers[loc.name] = _createEmptyLocationMarker(loc);
        }
      }
        Set<String> processedLocations = {};
        if (snapshot.hasData) {
          final filteredEvents = snapshot.data!;     
          for (final event in filteredEvents) {    
           final eventPosKey = '${event.location.coordinates.latitude.toStringAsFixed(5)},${event.location.coordinates.longitude.toStringAsFixed(5)}';
            if (_predefinedLocationLookup.containsKey(eventPosKey)) {
              final loc = _predefinedLocationLookup[eventPosKey]!;
              processedLocations.add(loc.name);
              if (!markers.containsKey(loc.name)) {
                markers[loc.name] = _createActiveLocationMarker(loc, filteredEvents);
              }
            } else {
              if (_selectedSports.isEmpty || _selectedSports.contains(event.sport)) {
              final icon = _getIconForEvent(event);
              markers[event.id] = _createSportEventMarker(event, icon);
            }
          }
        }
        if (!hasActiveFilters) {
          for (var loc in predefinedLocationsCascavel) {
            if (!processedLocations.contains(loc.name)) {
              markers[loc.name] = _createEmptyLocationMarker(loc);
            }
          }
        }
        } else if (!hasActiveFilters) {
          for (var loc in predefinedLocationsCascavel) {
            markers[loc.name] = _createEmptyLocationMarker(loc);
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
          markers: markers.values.toSet(), 
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
        );
      },
    );
  }

  Marker _createSportEventMarker(Event event, BitmapDescriptor icon) {
    return Marker(
      markerId: MarkerId(event.id),
      position: LatLng(
        event.location.coordinates.latitude,
        event.location.coordinates.longitude,
      ),
      icon: icon, 
      infoWindow: InfoWindow(
        title: event.title,
        snippet: "${event.sport} | Clique para ver detalhes",
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

  Marker _createEmptyLocationMarker(PredefinedLocation loc) {
    return Marker(
      markerId: MarkerId('loc_${loc.name}'),
      position: LatLng(loc.coordinates.latitude, loc.coordinates.longitude),
      icon: _emptyLocationIcon, 
      infoWindow: InfoWindow(
        title: loc.name,
        snippet: "Local livre. Clique para ver detalhes.",
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => PredefinedLocationDetailScreen(location: loc),
          ));
        },
      ),
    );
  }

  Marker _createActiveLocationMarker(PredefinedLocation loc, List<Event> allEvents) {
    final eventCount = allEvents.where((e) => 
        e.location.name == loc.name || 
        (
          e.location.coordinates.latitude.toStringAsFixed(5) == loc.coordinates.latitude.toStringAsFixed(5) &&
          e.location.coordinates.longitude.toStringAsFixed(5) == loc.coordinates.longitude.toStringAsFixed(5)
        )
    ).length;

    return Marker(
      markerId: MarkerId('loc_${loc.name}'), 
      position: LatLng(loc.coordinates.latitude, loc.coordinates.longitude),
      icon: _activeLocationIcon, 
      infoWindow: InfoWindow(
        title: loc.name,
        snippet: "$eventCount evento(s) encontrado(s). Clique para ver.",
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
      initialChildSize: 0.12,
      minChildSize: 0.12,
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
                color: const Color.fromARGB(255, 220, 250, 224).withValues(alpha: 1), 
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
                  final events = snapshot.data ?? [];
                  
                  if (events.isEmpty) {
                    final message = _selectedSports.isEmpty
                        ? "Nenhum evento encontrado por perto."
                        : "Nenhum evento para os esportes selecionados.";
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
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 5,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 150, 149, 149),
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
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
                  color: Colors.black.withValues(alpha: 0.1), 
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
             child: TextField(
              controller: _searchController,
                onTap: () {
                  setState(() {
                    _isSearchFocused = true;
                  });
              },
              decoration: InputDecoration(
                  hintText: "Buscar locais...",
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Spacer(),
              InkWell(
                onTap: () => _showFilterBottomSheet(),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8), 
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset(
                            'assets/icons/filter.svg',
                            colorFilter: ColorFilter.mode(Colors.grey[800]!, BlendMode.srcIn),
                          ),
                        ),
                      ),
                      if (_selectedSports.isNotEmpty || _filterDate != null || _filterTime != null || _filterHasVacancies)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    // Criar cópias locais temporárias para o modal
    List<String> tempSelectedSports = List.from(_selectedSports);
    DateTime? tempFilterDate = _filterDate;
    TimeOfDay? tempFilterTime = _filterTime;
    double tempFilterDistance = _filterDistance;
    bool tempFilterHasVacancies = _filterHasVacancies;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return PopScope(
          canPop: true,
          onPopInvoked: (bool didPop) {
            // Quando cancela, não faz nada (mantém os filtros aplicados)
          },
          child: Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                return Column(
                  children: [
                    // Handle bar
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        'Filtrar Eventos',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          const SizedBox(height: 8),
                          const Text(
                            'Esportes',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: _allSports.map((sport) {
                              final isSelected = tempSelectedSports.contains(sport);
                              return FilterChip(
                                label: Text(sport),
                                selectedColor: const Color(0xFFC8E6C9), 
                                selected: isSelected,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.green[800] : Colors.black87,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                checkmarkColor: Colors.green[800],
                                onSelected: (selected) {
                                  setModalState(() {
                                    if (selected) {
                                      tempSelectedSports.add(sport);
                                    } else {
                                      tempSelectedSports.remove(sport);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Data e Hora',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.calendar_today, size: 20),
                                  label: Text(
                                    tempFilterDate == null
                                        ? 'Selecionar Data'
                                        : '${tempFilterDate?.day}/${tempFilterDate?.month}/${tempFilterDate?.year}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  onPressed: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: tempFilterDate ?? DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now().add(const Duration(days: 365)),
                                    );
                                    if (date != null) {
                                      setModalState(() => tempFilterDate = date);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.access_time, size: 20),
                                  label: Text(
                                    tempFilterTime == null
                                        ? 'Selecionar Hora'
                                        : '${tempFilterTime?.hour}:${tempFilterTime?.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  onPressed: () async {
                                    final time = await showTimePicker(
                                      context: context,
                                      initialTime: tempFilterTime ?? TimeOfDay.now(),
                                    );
                                    if (time != null) {
                                      setModalState(() => tempFilterTime = time);
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
                              const Text(
                                'Distância máxima',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${_filterDistance.round()} km',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: tempFilterDistance,
                            min: 1,
                            max: 50,
                            divisions: 49,
                            label: '${tempFilterDistance.round()} km',
                            activeColor: Colors.green,
                            onChanged: (value) => setModalState(() => tempFilterDistance = value),
                          ),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: const Text(
                              'Apenas com vagas disponíveis',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            activeColor: Colors.green,
                            value: tempFilterHasVacancies,
                            onChanged: (value) => setModalState(() => tempFilterHasVacancies = value),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setModalState(() {
                                    tempSelectedSports.clear();
                                    tempFilterDate = null;
                                    tempFilterTime = null;
                                    tempFilterDistance = 20.0;
                                    tempFilterHasVacancies = false;
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: const Text('Limpar Filtros'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: FilledButton(
                                onPressed: () {
                                  // Aplicar os filtros temporários aos filtros principais
                                  setState(() {
                                    _selectedSports = List.from(tempSelectedSports);
                                    _filterDate = tempFilterDate;
                                    _filterTime = tempFilterTime;
                                    _filterDistance = tempFilterDistance;
                                    _filterHasVacancies = tempFilterHasVacancies;
                                  });
                                  _applyFilters(modalContext);
                                },
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  backgroundColor: Colors.green,
                                ),
                                child: const Text('Aplicar'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _applyFilters(BuildContext modalContext) {
    if (_currentPosition != null) {
      setState(() {
        _eventsStream = _eventService
            .getNearbyEvents(_currentPosition!, _filterDistance)
            .map((events) => events.where((event) {
                  if (_selectedSports.isNotEmpty && !_selectedSports.contains(event.sport)) {
                    return false;
                  }
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
    if (_selectedSports.isNotEmpty) {
      activeFilters.add('Esportes (${_selectedSports.length})');
    }
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
        backgroundColor: Colors.green[700],
      ),
    );

    Navigator.pop(modalContext);
  }

  void _animateToCurrentLocation() {
    if (_mapController != null && _currentPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            zoom: 14.5,
          ),
        ),
      );
    } else {
      _fetchLocationAndLoadEvents();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Buscando sua localização... Tente novamente em um segundo.')),
        );
      }
    }
  }

  void _zoomIn() {
    _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    _mapController?.animateCamera(CameraUpdate.zoomOut());
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