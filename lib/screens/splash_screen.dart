import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/utilisateur.dart';
import 'login_screen.dart';
import 'citoyen/citoyen_home_screen.dart';
import 'medecin/medecin_home_screen.dart';
import 'autorite/autorite_home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    // Vérifier la connexion après l'animation
    Future.delayed(const Duration(seconds: 2), () {
      _verifierConnexion();
    });
  }

  Future<void> _verifierConnexion() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.verifierConnexion();

    if (!mounted) return;

    if (authProvider.estConnecte) {
      _naviguerVersAccueil(authProvider.utilisateur!.type);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF065A82),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF028090),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.health_and_safety,
                        color: Colors.white,
                        size: 70,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Nom de l'app
                    const Text(
                      'FlexAlert',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Slogan
                    const Text(
                      'Plateforme d\'Alerte d\'Épidémie',
                      style: TextStyle(
                        color: Color(0xFFCADCFC),
                        fontSize: 16,
                      ),
                    ),
                    const Text(
                      'Abidjan, Côte d\'Ivoire',
                      style: TextStyle(
                        color: Color(0xFF028090),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Indicateur de chargement
                    const CircularProgressIndicator(
                      color: Color(0xFF028090),
                      strokeWidth: 2,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
