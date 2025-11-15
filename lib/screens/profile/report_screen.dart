import 'package:flutter/material.dart';
import '../../api/report_service.dart';

class ReportScreen extends StatefulWidget {
  final String? prefilledEventId;
  final String? prefilledEventName;
  final String? prefilledUserId;
  final String? prefilledUserName;

  const ReportScreen({
    super.key,
    this.prefilledEventId,
    this.prefilledEventName,
    this.prefilledUserId,
    this.prefilledUserName,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final ReportService _reportService = ReportService();
  bool _isLoading = false;

  String _reportType = 'Problema no App'; 
  final List<String> _reportTypes = ['Problema no App', 'Reportar Evento', 'Reportar Usuário', 'Reportar Local'];
  final _reportedItemController = TextEditingController(); 
  bool _isItemReadOnly = false;

  @override
  void initState() {
    super.initState();
    if (widget.prefilledEventId != null) {
      setState(() {
        _reportType = 'Reportar Evento';
        _reportedItemController.text = widget.prefilledEventName ?? widget.prefilledEventId!;
        _isItemReadOnly = true; 
      });
    }
    else if (widget.prefilledUserId != null) {
      setState(() {
        _reportType = 'Reportar Usuário';
        _reportedItemController.text = widget.prefilledUserName ?? widget.prefilledUserId!;
        _isItemReadOnly = true;
      });
    }
  }

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
        reportedUserId: _reportType == 'Reportar Usuário' 
          ? (widget.prefilledUserId ?? _reportedItemController.text) 
          : null,
        reportedLocationName: _reportType == 'Reportar Local' ? _reportedItemController.text : null,
        reportedEventId: _reportType == 'Reportar Evento' 
          ? (widget.prefilledEventId ?? _reportedItemController.text) 
          : null,
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
    bool showItemField = _reportType == 'Reportar Usuário' || 
                         _reportType == 'Reportar Local' || 
                         _reportType == 'Reportar Evento';
    
    String itemLabel = 'Item a ser reportado';
    String itemHint = '';

    if (_reportType == 'Reportar Usuário') {
      itemLabel = 'Usuário';
      itemHint = 'Cole o ID do perfil do usuário';
      if(widget.prefilledUserName != null) itemLabel = 'Usuário Reportado';
    } else if (_reportType == 'Reportar Local') {
      itemLabel = 'Nome do Local';
      itemHint = 'Nome do local pré-definido';
    } else if (_reportType == 'Reportar Evento') {
      itemLabel = 'Evento';
      itemHint = 'Nome ou ID do Evento';
      if(widget.prefilledEventName != null) itemLabel = 'Evento Reportado';
    }
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
                onChanged: _isItemReadOnly 
                  ? null 
                  : (value) => setState(() {
                      _reportType = value ?? 'Problema no App';
                      if (!_isItemReadOnly) {
                        _reportedItemController.clear();
                      }
                    }),
              ),
              const SizedBox(height: 20),

              if (showItemField)
                TextFormField(
                  controller: _reportedItemController,
                  readOnly: _isItemReadOnly, 
                  decoration: _buildInputDecoration(
                    label: itemLabel,
                    hint: itemHint
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