import 'dart:async'; 
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:google_maps_apis/places.dart';
import '../../data/predefined_locations.dart';
import '../../api/event_service.dart';
import '../../models/event_model.dart' as event_model;

final kGoogleApiKey = dotenv.env['kGooglePlacesApiKey'] ?? 'fallback_key';

class CreateEventScreen extends StatefulWidget {
  final event_model.Event? eventToEdit;
  const CreateEventScreen({super.key, this.eventToEdit});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isLoading = false;
  bool _isPredictionLoading = false;
  bool _isDetailsLoading = false;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedSport;
  GeoPoint? _selectedGeoPoint;
  PlaceDetails? _placeDetails;
  PredefinedLocation? _selectedPredefinedLocation;

  late GoogleMapsPlaces _places;
  List<Prediction> _apiPredictions = [];
  List<PredefinedLocation> _filteredPredefinedLocations = [];
  String? _sessionToken;
  Timer? _debounce;
  String _selectedSkillLevel = 'Todos'; 
  bool _isPrivate = false; 
  bool get _isEditMode => widget.eventToEdit != null;
  final List<String> _sports = ['Futebol', 'Basquete', 'Vôlei', 'Tênis', 'Corrida'];
  final List<String> _skillLevels = ['Todos', 'Iniciante', 'Intermediário', 'Avançado'];
  final EventService _eventService = EventService();

  @override
  void initState() {
    super.initState();
    _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);
    _generateSessionToken();
    _filteredPredefinedLocations = [];
   _locationController.addListener(_onSearchChanged);
  if (_isEditMode) {
      final event = widget.eventToEdit!;
      _titleController.text = event.title;
      _descriptionController.text = event.description;
      _locationController.text = event.location.name;
      _selectedDate = event.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(event.dateTime);
      _selectedSport = event.sport;
      _selectedGeoPoint = event.location.coordinates;
      _selectedSkillLevel = event.skillLevel;
      _isPrivate = event.isPrivate;
    }
  }
  void _generateSessionToken() {
    _sessionToken = DateTime.now().microsecondsSinceEpoch.toString();
     debugPrint("Novo Session Token: $_sessionToken");
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.removeListener(_onSearchChanged);
    _locationController.dispose();
    _debounce?.cancel();
    _places.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
   if (_debounce?.isActive ?? false) _debounce!.cancel();
   _debounce = Timer(const Duration(milliseconds: 300), () {
     final inputText = _locationController.text;
     // Define o nome selecionado (pode ser de API ou pré-definido)
     final selectedName = _selectedPredefinedLocation?.name ?? _placeDetails?.name ?? _placeDetails?.formattedAddress;

     // Limpa seleção anterior se o texto mudar E não for o nome já selecionado
     if (_selectedGeoPoint != null && inputText != selectedName) {
       if (mounted) setState(() { _selectedGeoPoint = null; _placeDetails = null; _selectedPredefinedLocation = null; });
     }

     // Filtra locais pré-definidos
     final filtered = predefinedLocationsCascavel
         .where((loc) =>
              loc.name.toLowerCase().contains(inputText.toLowerCase()) ||
              loc.description.toLowerCase().contains(inputText.toLowerCase()) // Busca na descrição também
          )
         .toList();

     if (mounted) {
       setState(() {
         _filteredPredefinedLocations = filtered;
       });
     }

     // Busca na API se o texto for > 2 caracteres E não houver uma seleção válida ainda
     if (inputText.length > 2 && _selectedGeoPoint == null) {
       _fetchAutocompleteSuggestions(inputText);
     } else if (inputText.isEmpty) {
       // Se o campo está vazio, mostra todos os pré-definidos e limpa API
       if (mounted) {
         setState(() {
           _filteredPredefinedLocations = predefinedLocationsCascavel;
           _apiPredictions = [];
           _placeDetails = null;
           _selectedGeoPoint = null;
           _selectedPredefinedLocation = null;
         });
       }
     } else {
        // Se o texto for curto ou já houver seleção, limpa apenas as sugestões da API
        if (mounted) {
           setState(() { _apiPredictions = []; });
        }
     }
   });
 }

  Future<void> _fetchAutocompleteSuggestions(String input) async {
    if (!mounted || _sessionToken == null) return;
    setState(() => _isPredictionLoading = true);
    try {
      final response = await _places.autocomplete(
        input,
        sessionToken: _sessionToken,
        language: 'pt-BR',
        components: [Component(Component.country, "br")],
        types: ["establishment"],
        location: Location(lat: -24.9555, lng: -53.4552),
        radius: 50000,
        strictbounds: false,
      );
      if (!mounted) return;
      if (response.isOk) {
        setState(() => _apiPredictions = response.predictions!);
      } else {
        debugPrint("Erro Autocomplete: ${response.errorMessage}");
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao buscar sugestões: ${response.errorMessage}')));
      }
    } catch (e) {
      debugPrint("Exceção Autocomplete: $e");
    } finally {
      if (mounted) setState(() => _isPredictionLoading = false);
    }
  }

  Future<void> _handleSelection(dynamic selection) async {
     if (selection is Prediction) {
        await _fetchPlaceDetails(selection); // Chama busca de detalhes da API
     } else if (selection is PredefinedLocation) {
        _selectPredefinedLocation(selection); // Seleciona local pré-definido
     }
 }

 void _selectPredefinedLocation(PredefinedLocation location) {
   if (!mounted) return;
   setState(() {
     _locationController.removeListener(_onSearchChanged);
     _locationController.text = location.name; // Atualiza o campo de texto
     _locationController.addListener(_onSearchChanged);

     _selectedGeoPoint = location.coordinates; // Guarda as coordenadas
     _selectedPredefinedLocation = location; // Guarda o local pré-definido selecionado
     _placeDetails = null; // Limpa detalhes da API
     _apiPredictions = []; // Limpa sugestões da API
     _filteredPredefinedLocations = []; // Esconde a lista
   });
   FocusScope.of(context).unfocus(); // Esconde o teclado
   debugPrint("Pré-definido selecionado: ${location.name}");
 }

  Future<void> _fetchPlaceDetails(Prediction prediction) async {
    final placeId = prediction.placeId;
    if (placeId == null || !mounted || _sessionToken == null) return;

    _locationController.removeListener(_onSearchChanged);
   _locationController.text = prediction.description ?? '';
   _locationController.addListener(_onSearchChanged);

    setState(() { _isDetailsLoading = true; _apiPredictions = []; _filteredPredefinedLocations = []; _selectedPredefinedLocation = null; });

    try {
      final response = await _places.getDetailsByPlaceId( placeId, sessionToken: _sessionToken, language: 'pt-BR', fields: ["name", "formatted_address", "geometry"]);
      if (!mounted) return;
      if (response.isOk && response.result != null) {
        final details = response.result!;
        final lat = details.geometry?.location.lat;
        final lng = details.geometry?.location.lng;
        setState(() {
          _placeDetails = details;
          _locationController.removeListener(_onSearchChanged);
          if (details.formattedAddress != null && _locationController.text != details.formattedAddress) {
             _locationController.text = details.formattedAddress!;
          }
          else if (details.name != null) { _locationController.text = details.name!; }
          _locationController.addListener(_onSearchChanged);
          if (lat != null && lng != null) {
            _selectedGeoPoint = GeoPoint(lat, lng);
          } else {
            _selectedGeoPoint = null;
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não foi possível obter as coordenadas.')));
          }
        });
        _generateSessionToken();
         FocusScope.of(context).unfocus();
      } else {
        debugPrint("Erro Detalhes: ${response.errorMessage}");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao buscar detalhes: ${response.errorMessage}')));
        setState(() => _selectedGeoPoint = null);
      }
    } catch (e) {
      debugPrint("Exceção Detalhes: $e");
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao buscar detalhes.')));
      setState(() => _selectedGeoPoint = null);
    } finally {
       if (mounted) setState(() => _isDetailsLoading = false);
    }
  }

  Future<void> _saveEvent() async {
    setState(() => _isLoading = true);
    if (!_formKey.currentState!.validate()){return; }
    if (_selectedGeoPoint == null || _locationController.text.isEmpty) { 
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, selecione uma localização válida.')));
       return; }
    if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, selecione a data do evento.')),
        );
        return;
    }
    if (_selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, selecione a hora do evento.')),
        );
        return;
    }
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) { 
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Você precisa estar logado para criar um evento.')));
       return; }
    final locationName = _selectedPredefinedLocation?.name ?? _placeDetails?.name ?? _locationController.text;
    final locationAddress = _placeDetails?.formattedAddress ?? (_selectedPredefinedLocation != null ? _selectedPredefinedLocation!.description : '');

    setState(() => _isLoading = true);

    if (_isEditMode) {
      final Map<String, dynamic> updatedData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'sport': _selectedSport!,
        'dateTime': Timestamp.fromDate(DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _selectedTime!.hour, _selectedTime!.minute)),
        'location': event_model.Location(
          name: locationName,
          address: locationAddress,
          coordinates: _selectedGeoPoint!,
        ).toJson(),
        'geo': GeoFirePoint(_selectedGeoPoint!).data, 
        'skillLevel': _selectedSkillLevel,
        'isPrivate': _isPrivate,
      };

      try {
        await _eventService.updateEvent(widget.eventToEdit!.id, updatedData);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Evento atualizado com sucesso!')));
        Navigator.pop(context); // Volta para a tela de detalhes
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao atualizar evento.')));
      }

    } else {
      final organizerUser = event_model.LocalUser(id: currentUser.uid, name: currentUser.displayName ?? 'Usuário Anônimo', avatarUrl: currentUser.photoURL ?? '');
      
      final newEvent = event_model.Event(
        id: '', title: _titleController.text, description: _descriptionController.text,
        sport: _selectedSport!,
        dateTime: DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _selectedTime!.hour, _selectedTime!.minute),
        location: event_model.Location(
          name: locationName,
          address: locationAddress,
          coordinates: _selectedGeoPoint!,
        ),
        imageUrl: 'https://images.unsplash.com/photo-1551958214-2d59cc7a2a4a?q=80&w=2071&auto=format&fit=crop',
        organizer: organizerUser,
        participants: [organizerUser], 
        maxParticipants: 12,
        skillLevel: _selectedSkillLevel,
        isPrivate: _isPrivate,
        pendingParticipants: [], 
      );
      
      try {
        await _eventService.addEvent(newEvent);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Evento publicado com sucesso!')));
        Navigator.pop(context);
      } catch (e) { 
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao publicar evento.'))); 
        debugPrint("Erro ao salvar evento: $e");
      } finally { 
        if (mounted) setState(() => _isLoading = false); 
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker( context: context, initialDate: _selectedDate ?? DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2101), );
      if (picked != null && picked != _selectedDate) setState(() => _selectedDate = picked);
  }
  Future<void> _selectTime(BuildContext context) async {
      final TimeOfDay? picked = await showTimePicker( context: context, initialTime: _selectedTime ?? TimeOfDay.now(), );
      if (picked != null && picked != _selectedTime) setState(() => _selectedTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    final combinedListLength = _filteredPredefinedLocations.length + _apiPredictions.length;
    final bool showSuggestions = (_filteredPredefinedLocations.isNotEmpty || _apiPredictions.isNotEmpty) && !_isDetailsLoading;
    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Editar Evento' : 'Criar Novo Evento'), centerTitle: true),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();
          if (_filteredPredefinedLocations.isNotEmpty || _apiPredictions.isNotEmpty) {
            setState(() {
              _filteredPredefinedLocations = [];
              _apiPredictions = [];
            });
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título do Evento', hintText: 'Ex: Futebol de Sábado', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Por favor, insira um título.' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição', hintText: 'Detalhes sobre o evento, regras, etc.', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Esporte', border: OutlineInputBorder()),
                value: _selectedSport,
                items: _sports.map((String sport) => DropdownMenuItem<String>(value: sport, child: Text(sport))).toList(),
                onChanged: (newValue) => setState(() => _selectedSport = newValue),
                validator: (value) => value == null ? 'Selecione um esporte' : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Nível de Habilidade', border: OutlineInputBorder()),
                value: _selectedSkillLevel,
                items: _skillLevels.map((String level) => DropdownMenuItem<String>(value: level, child: Text(level))).toList(),
                onChanged: (newValue) => setState(() => _selectedSkillLevel = newValue ?? 'Todos'),
                validator: (value) => value == null ? 'Selecione um nível' : null,
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text('Evento Privado'),
                subtitle: const Text('Participantes precisarão da sua aprovação para entrar.'),
                value: _isPrivate,
                onChanged: (newValue) => setState(() => _isPrivate = newValue),
                activeColor: Colors.orangeAccent,
              ),
              const SizedBox(height: 20),
              TextField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: "Localização", hintText: "Digite ou selecione um local", border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    suffixIcon: _isPredictionLoading || _isDetailsLoading
                      ? Container( width: 24, height: 24, padding: const EdgeInsets.all(12.0), child: const CircularProgressIndicator(strokeWidth: 2))
                      : _locationController.text.isNotEmpty
                        ? IconButton( icon: const Icon(Icons.clear), tooltip: "Limpar", onPressed: () => _locationController.clear())
                        : const Icon(Icons.search),
                  ),
                  onTap: () {
                  },
              ),
              if (showSuggestions)
               Material(
                 elevation: 4.0, borderRadius: BorderRadius.circular(8.0),
                 child: ConstrainedBox(
                   constraints: const BoxConstraints(maxHeight: 250),
                   child: ListView.builder(
                     shrinkWrap: true,
                     itemCount: combinedListLength,
                     itemBuilder: (context, index) {
                       // Decide se mostra um item pré-definido ou da API
                       if (index < _filteredPredefinedLocations.length) {
                         // Item Pré-definido
                         final location = _filteredPredefinedLocations[index];
                         return ListTile(
                           leading: const Icon(Icons.star_border, size: 20, color: Colors.orangeAccent),
                           title: Text(location.name),
                           subtitle: Text(location.description),
                           dense: true,
                           onTap: () => _handleSelection(location), // Chama a função genérica
                         );
                       } else {
                         // Item da API
                         final apiIndex = index - _filteredPredefinedLocations.length;
                         // Proteção extra caso a lista mude durante o build
                         if (apiIndex >= _apiPredictions.length) return const SizedBox.shrink();
                         final prediction = _apiPredictions[apiIndex];
                         return ListTile(
                           leading: const Icon(Icons.pin_drop_outlined, size: 20),
                           title: Text(prediction.structuredFormatting?.mainText ?? prediction.description ?? ''),
                           subtitle: Text(prediction.structuredFormatting?.secondaryText ?? ''),
                           dense: true,
                           onTap: () => _handleSelection(prediction), // Chama a função genérica
                         );
                       }
                     },
                   ),
                 ),
               ),
             // Preview opcional
             if (_selectedGeoPoint != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text("Selecionado: ${_locationController.text}", style: TextStyle(color: Colors.grey[600])),
                ),
             const SizedBox(height: 20),

              // --- Data e Hora ---
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Data', border: OutlineInputBorder()),
                        child: Text(_selectedDate != null ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}" : 'Selecione...'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Hora', border: OutlineInputBorder()),
                        child: Text(_selectedTime != null ? _selectedTime!.format(context) : 'Selecione...'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  ),
                  onPressed: _isLoading ? null : _saveEvent,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : Text(_isEditMode ? 'SALVAR ALTERAÇÕES' : 'PUBLICAR EVENTO', style: const TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}