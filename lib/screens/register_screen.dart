import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/utilisateur.dart';
import '../models/signalement.dart';
import 'citoyen/citoyen_home_screen.dart';
import 'medecin/medecin_home_screen.dart';
import 'autorite/autorite_home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _motDePasseController = TextEditingController();
  bool _motDePasseVisible = false;
  TypeUtilisateur _typeSelectionne = TypeUtilisateur.citoyen;
  String _communeSelectionnee = communesAbidjan.first;

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _motDePasseController.dispose();
    super.dispose();
  }

  Future<void> _inscrire() async {
    if (_nomController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _motDePasseController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final succes = await authProvider.inscrire(
      email: _emailController.text.trim(),
      motDePasse: _motDePasseController.text.trim(),
      nom: _nomController.text.trim(),
      type: _typeSelectionne,
      commune: _communeSelectionnee,
    );

    if (!mounted) return;

    if (succes) {
      _naviguerVersAccueil(authProvider.utilisateur!.type);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.erreur ?? 'Erreur d\'inscription'),
          backgroundColor: const Color(0xFFC62828),
        ),
      );
    }
  }

  void _naviguerVersAccueil(TypeUtilisateur type) {
    Widget ecran;
    switch (type) {
      case TypeUtilisateur.citoyen:
        ecran = const CitoyenHomeScreen();
        break;
      case TypeUtilisateur.medecin:
        ecran = const MedecinHomeScreen();
        break;
      case TypeUtilisateur.autorite:
        ecran = const AutoriteHomeScreen();
        break;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ecran),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        title: const Text('Créer un compte'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Champ Nom
              const Text(
                'Nom complet',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF065A82),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nomController,
                decoration: const InputDecoration(
                  hintText: 'Votre nom complet',
                  prefixIcon:
                      Icon(Icons.person_outlined, color: Color(0xFF065A82)),
                ),
              ),

              const SizedBox(height: 20),

              // Champ Email
              const Text(
                'Email',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF065A82),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'votre@email.com',
                  prefixIcon:
                      Icon(Icons.email_outlined, color: Color(0xFF065A82)),
                ),
              ),

              const SizedBox(height: 20),

              // Champ Mot de passe
              const Text(
                'Mot de passe',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF065A82),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _motDePasseController,
                obscureText: !_motDePasseVisible,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  prefixIcon:
                      const Icon(Icons.lock_outlined, color: Color(0xFF065A82)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _motDePasseVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: const Color(0xFF64748B),
                    ),
                    onPressed: () {
                      setState(() {
                        _motDePasseVisible = !_motDePasseVisible;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Type d'utilisateur
              const Text(
                'Je suis',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF065A82),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildTypeButton(
                    TypeUtilisateur.citoyen,
                    'Citoyen',
                    Icons.person,
                  ),
                  const SizedBox(width: 12),
                  _buildTypeButton(
                    TypeUtilisateur.medecin,
                    'Médecin',
                    Icons.medical_services,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Commune
              const Text(
                'Ma commune',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF065A82),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2EAF4)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _communeSelectionnee,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: Color(0xFF065A82)),
                    items: communesAbidjan
                        .map((commune) => DropdownMenuItem(
                              value: commune,
                              child: Text(commune),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _communeSelectionnee = value!;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Bouton Inscription
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: authProvider.chargement ? null : _inscrire,
                  child: authProvider.chargement
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Créer mon compte',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Lien connexion
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: RichText(
                    text: const TextSpan(
                      text: 'Déjà un compte ? ',
                      style: TextStyle(color: Color(0xFF64748B)),
                      children: [
                        TextSpan(
                          text: 'Se connecter',
                          style: TextStyle(
                            color: Color(0xFF065A82),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton(TypeUtilisateur type, String label, IconData icon) {
    final estSelectionne = _typeSelectionne == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _typeSelectionne = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: estSelectionne ? const Color(0xFF065A82) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: estSelectionne
                  ? const Color(0xFF065A82)
                  : const Color(0xFFE2EAF4),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: estSelectionne ? Colors.white : const Color(0xFF065A82),
                size: 28,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color:
                      estSelectionne ? Colors.white : const Color(0xFF065A82),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
