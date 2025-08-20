import 'package:flutter/material.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedSport;

  final List<String> _sports = ['Futebol', 'Basquete', 'Vôlei', 'Tênis', 'Corrida'];

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
              // --- Campo Título ---
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Título do Evento',
                  hintText: 'Ex: Futebol de Sábado',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um título.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- Campo Descrição ---
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Detalhes sobre o evento, regras, etc.',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // --- Seleção de Esporte ---
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Esporte',
                  border: OutlineInputBorder(),
                ),
                value: _selectedSport,
                items: _sports.map((String sport) {
                  return DropdownMenuItem<String>(
                    value: sport,
                    child: Text(sport),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedSport = newValue;
                  });
                },
                 validator: (value) => value == null ? 'Selecione um esporte' : null,
              ),
              const SizedBox(height: 20),

              // --- Seleção de Data e Hora ---
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Data',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(_selectedDate != null ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}" : 'Selecione...'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Hora',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(_selectedTime != null ? _selectedTime!.format(context) : 'Selecione...'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // --- Botão de Salvar ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Lógica para salvar o evento
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Salvando evento...')),
                      );
                    }
                  },
                  child: const Text('PUBLICAR EVENTO', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}