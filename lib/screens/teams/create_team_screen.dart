// lib/screens/teams/create_team_screen.dart

import 'package:flutter/material.dart';

class CreateTeamScreen extends StatefulWidget {
  const CreateTeamScreen({super.key});

  @override
  State<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedSport;
  bool _isPublic = true;
  double _maxMembers = 10.0;

  final List<String> _sports = ['Futebol', 'Basquete', 'Vôlei', 'Tênis', 'Corrida', 'Outro'];

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
              // --- Seção para o Brasão/Logo da Equipe ---
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      child: Icon(Icons.shield_outlined, size: 50, color: Colors.grey[600]),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- Campo Nome da Equipe ---
              TextFormField(
                decoration: _buildInputDecoration(label: 'Nome da Equipe'),
                validator: (value) => (value == null || value.isEmpty) ? 'Dê um nome para sua equipe.' : null,
              ),
              const SizedBox(height: 20),

              // --- Seleção de Esporte ---
              DropdownButtonFormField<String>(
                decoration: _buildInputDecoration(label: 'Esporte Principal'),
                value: _selectedSport,
                items: _sports.map((sport) => DropdownMenuItem(value: sport, child: Text(sport))).toList(),
                onChanged: (value) => setState(() => _selectedSport = value),
                validator: (value) => value == null ? 'Selecione um esporte.' : null,
              ),
              const SizedBox(height: 20),

              // --- Campo Descrição ---
              TextFormField(
                decoration: _buildInputDecoration(label: 'Descrição (Opcional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // --- Número Máximo de Membros (Slider) ---
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

              // --- Privacidade da Equipe (Switch) ---
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

              // --- Botão de Salvar ---
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Lógica para salvar a equipe
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Equipe criada com sucesso!')),
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('SALVAR EQUIPE'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widgets auxiliares para manter a consistência visual
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