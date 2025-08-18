import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // --- Título ---
              const Text(
                'Crie sua Conta',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'É rápido e fácil!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // --- Campos de Formulário ---
              TextFormField(
                decoration: _buildInputDecoration(label: 'Nome Completo', icon: Icons.person_outline),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: _buildInputDecoration(label: 'Email', icon: Icons.email_outlined),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: _buildInputDecoration(label: 'Senha', icon: Icons.lock_outline),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: _buildInputDecoration(label: 'Confirmar Senha', icon: Icons.lock_outline),
                obscureText: true,
              ),
              const SizedBox(height: 30),

              // --- Botão de Registro ---
              ElevatedButton(
                style: _buildButtonStyle(),
                onPressed: () {
                  // Lógica de registro...
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cadastro realizado! Faça o login.')),
                  );
                  Navigator.of(context).pop();
                },
                child: const Text('CADASTRAR'),
              ),
              const SizedBox(height: 20),

              // --- Link para Login ---
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
    );
  }

  // Reutilizando os mesmos widgets de estilo
  InputDecoration _buildInputDecoration({required String label, required IconData icon}) {
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