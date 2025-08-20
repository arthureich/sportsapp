import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _eventNotifications = true;
  bool _teamInvites = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Configurações', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        children: [
          // --- Seção Conta ---
          _buildSectionHeader('Conta'),
          _buildSettingsTile(
            icon: Icons.person_outline,
            title: 'Editar Perfil',
            subtitle: 'Altere seu nome, foto e bio',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: 'Alterar Senha',
            subtitle: 'Mantenha sua conta segura',
            onTap: () {},
          ),
          
          // --- Seção Notificações ---
          _buildSectionHeader('Notificações'),
          SwitchListTile(
            title: const Text('Novos Eventos', style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text('Receber alertas sobre eventos perto de você', style: TextStyle(color: Colors.grey[600])),
            value: _eventNotifications,
            onChanged: (bool value) {
              setState(() {
                _eventNotifications = value;
              });
            },
            secondary: Icon(Icons.notifications_outlined, color: Colors.grey[700]),
            activeColor: Colors.green,
          ),
          SwitchListTile(
            title: const Text('Convites de Equipe', style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text('Ser notificado quando for convidado para uma equipe', style: TextStyle(color: Colors.grey[600])),
            value: _teamInvites,
            onChanged: (bool value) {
              setState(() {
                _teamInvites = value;
              });
            },
            secondary: Icon(Icons.people_outline, color: Colors.grey[700]),
            activeColor: Colors.green,
          ),

          // --- Seção Sobre ---
          _buildSectionHeader('Sobre'),
          _buildSettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Política de Privacidade',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.description_outlined,
            title: 'Termos de Uso',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: 'Versão do App',
            subtitle: '1.0.0 (Protótipo)',
            isTappable: false, // Não faz nada ao clicar
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para os cabeçalhos de seção
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // Widget auxiliar para os itens da lista
  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    bool isTappable = true,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: Colors.grey[600])) : null,
      trailing: isTappable ? Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]) : null,
      onTap: isTappable ? onTap : null,
    );
  }
}