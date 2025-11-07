import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../api/team_service.dart';
import '../../api/storage_service.dart';
import '../../models/team_model.dart';

class CreateTeamScreen extends StatefulWidget {
  const CreateTeamScreen({super.key});

  @override
  State<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  String? _selectedSport;
  bool _isPublic = true;
  double _maxMembers = 10.0;

  final List<String> _sports = const [
  'Basquete', 'Beach Tennis', 'Ciclismo', 'Corrida', 'Futebol', 
  'Futevôlei', 'Handebol', 'Natação', 'Padel', 'Skate', 'Tênis', 'Vôlei', 'Outro'
];
  final TeamService _teamService = TeamService();
  final StorageService _storageService = StorageService();
  final ImagePicker _picker = ImagePicker();
  File? _pickedCrest;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      setState(() {
        _pickedCrest = File(image.path);
      });
    }
  }

  Future<void> _saveTeam() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro: Você precisa estar logado para criar uma equipe.')),
        );
        return;
    }
    
    setState(() => _isLoading = true);

    try {
      String crestUrl = '';

      if (_pickedCrest != null) {
        crestUrl = await _storageService.uploadImage(
          _pickedCrest!, 
          'team_crests' 
        );
      }
    
    final newTeam = Team(
        id: '', 
        name: _nameController.text,
        description: _descriptionController.text,
        sport: _selectedSport!,
        crestUrl: crestUrl, 
        currentMembers: 1, 
        maxMembers: _maxMembers.toInt(),
        isPublic: _isPublic,
        memberIds: [currentUser.uid],
      );

    await _teamService.addTeam(newTeam);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Equipe criada com sucesso!')),
      );
    }  catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ocorreu um erro ao criar a equipe.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Criar Nova Equipe', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _pickedCrest != null 
                        ? FileImage(_pickedCrest!) as ImageProvider 
                        : null,
                      child: _pickedCrest == null 
                        ? Icon(Icons.shield_outlined, size: 50, color: Colors.grey[600])
                        : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: -10,
                      child: IconButton(
                        icon: const CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.green,
                          child: Icon(Icons.camera_alt, size: 18, color: Colors.white)
                        ),
                        onPressed: _pickImage,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _nameController,
                decoration: _buildInputDecoration(label: 'Nome da Equipe'),
                validator: (value) => (value == null || value.isEmpty) ? 'Dê um nome para sua equipe.' : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: _buildInputDecoration(label: 'Esporte Principal'),
                value: _selectedSport,
                items: _sports.map((sport) => DropdownMenuItem(value: sport, child: Text(sport))).toList(),
                onChanged: (value) => setState(() => _selectedSport = value),
                validator: (value) => value == null ? 'Selecione um esporte.' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: _buildInputDecoration(label: 'Descrição (Opcional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              Text('Máximo de Membros: ${_maxMembers.toInt()}', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold)),
              Slider(
                value: _maxMembers,
                min: 2.0,
                max: 50.0,
                divisions: 48,
                label: _maxMembers.round().toString(),
                activeColor: Colors.green,
                onChanged: (double value) {
                  setState(() {
                    _maxMembers = value;
                  });
                },
              ),
              const SizedBox(height: 10),

              SwitchListTile(
                title: const Text('Equipe Aberta', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(_isPublic ? 'Qualquer um pode entrar' : 'Apenas por convite'),
                value: _isPublic,
                onChanged: (value) {
                  setState(() {
                    _isPublic = value;
                  });
                },
                activeColor: Colors.green,
                secondary: Icon(_isPublic ? Icons.lock_open : Icons.lock),
              ),
              const SizedBox(height: 40),

              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  style: _buildButtonStyle(),
                  onPressed: _isLoading ? null : _saveTeam,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0)
                      : const Text('SALVAR EQUIPE'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String label}) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.green, width: 2),
      ),
    );
  }

  ButtonStyle _buildButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }
}