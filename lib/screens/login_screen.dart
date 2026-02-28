import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/utilisateur.dart';
import 'register_screen.dart';
import 'citoyen/citoyen_home_screen.dart';
import 'medecin/medecin_home_screen.dart';
import 'autorite/autorite_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _motDePasseController = TextEditingController();
  bool _motDePasseVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _motDePasseController.dispose();
    super.dispose();
  }

  Future<void> _connecter() async {
    if (_emailController.text.isEmpty || _motDePasseController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final succes = await authProvider.connecter(
      email: _emailController.text.trim(),
      motDePasse: _motDePasseController.text.trim(),
    );

    if (!mounted) return;

    if (succes) {
      _naviguerVersAccueil(authProvider.utilisateur!.type);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.erreur ?? 'Erreur de connexion'),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF065A82),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.health_and_safety,
                        color: Colors.white,
                        size: 45,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'FlexAlert',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF065A82),
                      ),
                    ),
                    const Text(
                      'Connectez-vous à votre compte',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

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

              const SizedBox(height: 32),

              // Bouton Connexion
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: authProvider.chargement ? null : _connecter,
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
                          'Se connecter',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Lien inscription
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: 'Pas encore de compte ? ',
                      style: TextStyle(color: Color(0xFF64748B)),
                      children: [
                        TextSpan(
                          text: 'S\'inscrire',
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
}
