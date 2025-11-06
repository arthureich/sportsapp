import 'package:flutter/material.dart';
import '../../api/report_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final ReportService _reportService = ReportService();
  bool _isLoading = false;

  String _reportType = 'Problema no App'; // Valor inicial
  final List<String> _reportTypes = ['Problema no App', 'Reportar Usuário', 'Reportar Local'];

  final _reportedItemController = TextEditingController(); 

  @override
  void dispose() {
    _descriptionController.dispose();
    _reportedItemController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      await _reportService.submitReport(
        type: _reportType,
        description: _descriptionController.text,
        reportedUserId: _reportType == 'Reportar Usuário' ? _reportedItemController.text : null,
        reportedLocationName: _reportType == 'Reportar Local' ? _reportedItemController.text : null,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Relatório enviado com sucesso. Obrigado!')),
        );
        Navigator.pop(context);
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar relatório: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportar um Problema'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                decoration: _buildInputDecoration(label: 'Tipo de Relatório'),
                value: _reportType,
                items: _reportTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: (value) => setState(() => _reportType = value ?? 'Problema no App'),
              ),
              const SizedBox(height: 20),

              if (_reportType == 'Reportar Usuário' || _reportType == 'Reportar Local')
                TextFormField(
                  controller: _reportedItemController,
                  decoration: _buildInputDecoration(
                    label: _reportType == 'Reportar Usuário' ? 'ID do Usuário' : 'Nome do Local',
                    hint: _reportType == 'Reportar Usuário' ? 'Cole o ID do perfil do usuário' : 'Nome do local pré-definido'
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? 'Este campo é obrigatório.' : null,
                ),
                
              const SizedBox(height: 20),
              
              TextFormField(
                controller: _descriptionController,
                decoration: _buildInputDecoration(label: 'Descrição', hint: 'Descreva o que aconteceu...'),
                maxLines: 5,
                validator: (value) => (value == null || value.length < 10) ? 'Descreva com pelo menos 10 caracteres.' : null,
              ),
              const SizedBox(height: 40),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: _isLoading ? null : _submitReport,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('ENVIAR RELATÓRIO'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String label, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
    );
  }
}