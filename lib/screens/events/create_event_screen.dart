import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import '../../api/event_service.dart';
import '../../models/event_model.dart' as event_model;

const kGoogleApiKey = "AIzaSyC2H9FLjMW7NJ6AoGH2bht3kBQ-zfn197A";

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isLoading = false;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedSport;
  GeoPoint? _selectedGeoPoint;

  final List<String> _sports = ['Futebol', 'Basquete', 'Vôlei', 'Tênis', 'Corrida'];
  final EventService _eventService = EventService();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }
  
  Future<void> _handlePressButton() async {
    Prediction? p = await PlacesAutocomplete.show(
      context: context,
      apiKey: kGoogleApiKey,
      mode: Mode.overlay,
      language: "pt",
      components: [Component(Component.country, "br")],
    );

    if (p != null) {
      final places = GoogleMapsPlaces(apiKey: kGoogleApiKey);
      PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId!);
      
      final lat = detail.result.geometry!.location.lat;
      final lng = detail.result.geometry!.location.lng;

      setState(() {
        _locationController.text = detail.result.name;
        _selectedGeoPoint = GeoPoint(lat, lng);
      });
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedGeoPoint == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione um local válido.')),
      );
      return;
    }
    
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro: Você precisa estar logado para criar um evento.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final newEvent = event_model.Event(
      id: '',
      title: _titleController.text,
      description: _descriptionController.text,
      sport: _selectedSport!,
      dateTime: DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _selectedTime!.hour, _selectedTime!.minute),
      location: event_model.Location(
        name: _locationController.text,
        address: '', 
        coordinates: _selectedGeoPoint!,
      ),
      imageUrl: 'https://images.unsplash.com/photo-1551958214-2d59cc7a2a4a?q=80&w=2071&auto=format&fit=crop',
      organizer: event_model.LocalUser(id: currentUser.uid, name: currentUser.displayName ?? 'Usuário Anônimo', avatarUrl: currentUser.photoURL ?? ''),
      participants: [],
      maxParticipants: 12,
    );

    try {
      await _eventService.addEvent(newEvent);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Evento publicado com sucesso!')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ocorreu um erro ao publicar o evento.')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }


@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Novo Evento'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ... Campos de Título, Descrição, Esporte ...
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

              // --- NOVO CAMPO DE LOCALIZAÇÃO ---
              TextFormField(
                controller: _locationController,
                readOnly: true, // Impede a digitação direta
                decoration: InputDecoration(
                  labelText: 'Localização',
                  hintText: 'Clique para buscar o endereço',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _handlePressButton,
                  )
                ),
                onTap: _handlePressButton, // Abre a busca ao tocar
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione um local.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

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
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('PUBLICAR EVENTO', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}