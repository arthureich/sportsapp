import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../api/user_service.dart';
import '../../api/storage_service.dart';
import '../../models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  final String userId; 
  const EditProfileScreen({super.key, required this.userId});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final UserService _userService = UserService();
  final StorageService _storageService = StorageService();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  UserModel? _currentUserData; 
  File? _pickedImage;
  final List<String> _selectedSports = [];
  final List<String> _availableSports = const [
  'Basquete', 'Beach Tennis', 'Ciclismo', 'Corrida', 'Futebol', 'Futsal',
  'Futevôlei', 'Handebol', 'Natação', 'Padel', 'Skate', 'Tênis', 'Vôlei', 'Outro'
];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final userData = await _userService.getUser(widget.userId);
      if (userData != null && mounted) {
        setState(() {
          _currentUserData = userData;
          _nameController.text = userData.nome;
          _bioController.text = userData.bio;
          _selectedSports.clear(); 
          _selectedSports.addAll(userData.esportesInteresse);
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

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedSports.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Por favor, selecione pelo menos um esporte de interesse.')),
       );
       return;
    }

    setState(() => _isLoading = true);
    String? newImageUrl;
    
    try {
      if (_pickedImage != null) {
        newImageUrl = await _storageService.uploadImage(
          _pickedImage!, 
          'profile_images/${widget.userId}' 
        );
      }
    final Map<String, dynamic> updatedData = {
      'nome': _nameController.text.trim(),
      'bio': _bioController.text.trim(),
      'esportesInteresse': _selectedSports,
      if (newImageUrl != null) 'fotoUrl': newImageUrl,
    };

      await _userService.updateUser(widget.userId, updatedData);

       final user = FirebaseAuth.instance.currentUser;
       if (user != null) {
         if (user.displayName != _nameController.text.trim()) {
           await user.updateDisplayName(_nameController.text.trim());
         }
         if (newImageUrl != null && user.photoURL != newImageUrl) {
           await user.updatePhotoURL(newImageUrl);
         }
       }


      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
        if(Navigator.canPop(context)) {
           Navigator.of(context).pop();
        }
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
    final canPop = Navigator.canPop(context);
    return Scaffold(
      appBar: AppBar(
        leading: canPop ? BackButton(color: Colors.grey[800]) : null,
        title: const Text('Editar Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isLoading ? null : _saveProfile,
          ),
        ],
      ),
      body: _isLoading && _currentUserData == null 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: _pickedImage != null
                                ? FileImage(_pickedImage!) as ImageProvider
                                : (_currentUserData?.fotoUrl != null && _currentUserData!.fotoUrl.isNotEmpty
                                  ? NetworkImage(_currentUserData!.fotoUrl)
                                  : NetworkImage('https://avatar.iran.liara.run/public/${_currentUserData?.genero ?? 'boy'}?username=${widget.userId}') as ImageProvider
                                ),
                             onBackgroundImageError: (exception, stackTrace) {},
                          ),
                          Positioned(
                            bottom: 0,
                            right: -10,
                            child: IconButton(
                              icon: const CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.orangeAccent,
                                child: Icon(Icons.edit, size: 18, color: Colors.white)
                              ),
                              onPressed: _pickImage,
                            ),
                          )
                        ],
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
                      maxLength: 150, 
                    ),
                    const SizedBox(height: 20),
                    Text('Esportes de Interesse:', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0, 
                      runSpacing: 4.0, 
                      children: _availableSports.map((sport) {
                        final isSelected = _selectedSports.contains(sport);
                        return FilterChip(
                          label: Text(sport),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedSports.add(sport);
                              } else {
                                _selectedSports.remove(sport);
                              }
                            });
                          },
                          selectedColor: Colors.green.shade100,
                          checkmarkColor: Colors.green.shade800,
                        );
                      }).toList(),
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
                           : const Text('SALVAR PERFIL'),
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
