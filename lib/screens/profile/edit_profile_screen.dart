// lib/screens/profile/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../api/user_service.dart';
import '../../models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  final String userId; // Recebe o ID do usuário a ser editado
  const EditProfileScreen({super.key, required this.userId});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final UserService _userService = UserService();
  bool _isLoading = false;
  UserModel? _currentUserData; // Para guardar os dados atuais

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Carrega os dados atuais do usuário para preencher o formulário
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final userData = await _userService.getUser(widget.userId);
      if (userData != null && mounted) {
        setState(() {
          _currentUserData = userData;
          _nameController.text = userData.nome;
          _bioController.text = userData.bio;
        });
      } else if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Não foi possível carregar os dados do perfil.')),
         );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Salva as alterações no Firestore
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final Map<String, dynamic> updatedData = {
      'nome': _nameController.text.trim(),
      'bio': _bioController.text.trim(),
      // Adicionar outros campos aqui se necessário (esportesInteresse, etc.)
    };

    try {
      await _userService.updateUser(widget.userId, updatedData);

       // Atualiza também o display name no Firebase Auth
       final user = FirebaseAuth.instance.currentUser;
       if (user != null && user.displayName != _nameController.text.trim()) {
         await user.updateDisplayName(_nameController.text.trim());
       }


      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
        Navigator.of(context).pop(); // Volta para a tela anterior
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar perfil: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

 @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        actions: [
          // Botão Salvar na AppBar
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isLoading ? null : _saveProfile,
          ),
        ],
      ),
      body: _isLoading && _currentUserData == null // Mostra loading só se ainda não carregou os dados iniciais
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // TODO: Adicionar widget para trocar foto de perfil (ImagePicker + Firebase Storage)
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _currentUserData?.fotoUrl != null && _currentUserData!.fotoUrl.isNotEmpty
                            ? NetworkImage(_currentUserData!.fotoUrl)
                            : NetworkImage('https://avatar.iran.liara.run/public/boy?username=${widget.userId}') as ImageProvider,
                         onBackgroundImageError: (exception, stackTrace) {},
                         child: _currentUserData?.fotoUrl == null || _currentUserData!.fotoUrl.isEmpty
                            ? const Icon(Icons.person, size: 50) // Ícone se não houver foto
                            : null,
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _nameController,
                      decoration: _buildInputDecoration(label: 'Nome Completo'),
                      validator: (value) => (value == null || value.isEmpty) ? 'O nome não pode ficar vazio.' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _bioController,
                      decoration: _buildInputDecoration(label: 'Bio', hint: 'Fale um pouco sobre você e seus esportes!'),
                      maxLines: 3,
                      maxLength: 150, // Limite de caracteres para a bio
                    ),
                    const SizedBox(height: 40),
                     ElevatedButton(
                       style: ElevatedButton.styleFrom(
                           padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(12),
                           ),
                       ),
                       onPressed: _isLoading ? null : _saveProfile,
                       child: _isLoading
                           ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                           : const Text('SALVAR ALTERAÇÕES'),
                     ),
                  ],
                ),
              ),
            ),
    );
  }

  // Helper para InputDecoration
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