import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../api/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _bioController = TextEditingController();
  final List<String> _selectedSports = [];
  bool _isLoading = false;

  String? _selectedGender; 
  final List<String> _genders = ['Masculino', 'Feminino'];
  final List<String> _availableSports = const [
  'Basquete', 'Beach Tennis', 'Ciclismo', 'Corrida', 'Futebol', 
  'Futevôlei', 'Handebol', 'Natação', 'Padel', 'Skate', 'Tênis', 'Vôlei', 'Outro'
];
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedSports.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione pelo menos um esporte de interesse.')),
      );
      return;
    }
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione seu gênero.')),
      );
      return;
    }
    setState(() {
      _isLoading = true; 
    });

    try {
      await _authService.registerWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        nome: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        genero: _selectedGender!,
        esportes: _selectedSports,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cadastro realizado! Faça o login.')),
        );
        Navigator.of(context).pop();
      }

    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro no cadastro: ${e.message}')),
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.grey[800]),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form( 
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Crie sua Conta',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Complete seu perfil para começar!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 40),

                TextFormField(
                  controller: _nameController,
                  decoration: _buildInputDecoration(label: 'Nome Completo', icon: Icons.person_outline),
                  validator: (value) => (value == null || value.isEmpty) ? 'Por favor, insira seu nome.' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: _buildInputDecoration(label: 'Email', icon: Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => (value == null || !value.contains('@')) ? 'Por favor, insira um e-mail válido.' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: _buildInputDecoration(label: 'Senha', icon: Icons.lock_outline),
                  obscureText: true,
                  validator: (value) => (value == null || value.length < 6) ? 'A senha deve ter no mínimo 6 caracteres.' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: _buildInputDecoration(label: 'Confirmar Senha', icon: Icons.lock_outline),
                  obscureText: true,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'As senhas não coincidem.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                TextFormField(
                   controller: _bioController,
                   decoration: _buildInputDecoration(
                     label: 'Sua Bio (Opcional)',
                     icon: Icons.article_outlined,
                     hint: 'Ex: Atleta amador, adoro futebol aos sábados!'
                   ),
                   maxLines: 2,
                 ),
                 const SizedBox(height: 20),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: _buildInputDecoration(label: 'Gênero', icon: Icons.person_search_outlined),
                  value: _selectedGender,
                  items: _genders.map((gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                  validator: (value) => value == null ? 'Selecione um gênero.' : null,
                ),
                const SizedBox(height: 20),
                 Text('Esportes de Interesse:', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold)),
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

                const SizedBox(height: 30),

                ElevatedButton(
                  style: _buildButtonStyle(),
                  onPressed: _isLoading ? null : _registerUser,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0)
                      : const Text('CADASTRAR'),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Já tem uma conta?"),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Faça login', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String label, required IconData icon, String? hint}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.green),
      ),
    );
  }

  ButtonStyle _buildButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF4CAF50),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }
}
