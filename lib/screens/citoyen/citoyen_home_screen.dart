import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/alert_provider.dart';
import '../../models/alerte.dart';
import '../login_screen.dart';
import 'citoyen_signalement_screen.dart';
import 'citoyen_alertes_screen.dart';
import 'citoyen_consignes_screen.dart';

class CitoyenHomeScreen extends StatefulWidget {
  const CitoyenHomeScreen({super.key});

  @override
  State<CitoyenHomeScreen> createState() => _CitoyenHomeScreenState();
}

class _CitoyenHomeScreenState extends State<CitoyenHomeScreen> {
  int _indexPage = 0;

  final List<Widget> _pages = [
    const CitoyenAccueil(),
    const CitoyenSignalementScreen(),
    const CitoyenAlertesScreen(),
    const CitoyenConsignesScreen(),
  ];

  @override
  void initState() {
    super.initState();
    context.read<AlertProvider>().ecouterAlertes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_indexPage],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indexPage,
        onDestinationSelected: (index) => setState(() => _indexPage = index),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF065A82).withOpacity(0.1),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Color(0xFF065A82)),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle, color: Color(0xFF065A82)),
            label: 'Signaler',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications, color: Color(0xFF065A82)),
            label: 'Alertes',
          ),
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield, color: Color(0xFF065A82)),
            label: 'Consignes',
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════
// PAGE ACCUEIL CITOYEN
// ══════════════════════════════════════════
class CitoyenAccueil extends StatelessWidget {
  const CitoyenAccueil({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final alertProvider = context.watch<AlertProvider>();
    final utilisateur = authProvider.utilisateur;
    final commune = utilisateur?.commune ?? '';
    final niveauAlerte = alertProvider.getNiveauAlerte(commune);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        title: const Text('FlexAlert'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.deconnecter();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Salutation
            Text(
              'Bonjour, ${utilisateur?.nom ?? ''} 👋',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF065A82),
              ),
            ),
            Text(
              commune,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
            ),

            const SizedBox(height: 24),

            // Voyant d'alerte de la commune
            _buildVoyantAlerte(niveauAlerte, commune),

            const SizedBox(height: 24),

            // Actions rapides
            const Text(
              'Actions rapides',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF065A82),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    context,
                    icon: Icons.add_circle,
                    titre: 'Signaler',
                    sousTitre: 'Un cas suspect',
                    couleur: const Color(0xFF065A82),
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    context,
                    icon: Icons.notifications,
                    titre: 'Alertes',
                    sousTitre: 'En cours',
                    couleur: const Color(0xFF028090),
                    onTap: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Alertes actives
            const Text(
              'Situation à Abidjan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF065A82),
              ),
            ),
            const SizedBox(height: 16),

            ...alertProvider.alertesActives
                .where((a) => a.niveau != NiveauAlerte.vert)
                .map((alerte) => _buildCarteAlerte(alerte))
                .toList(),

            if (alertProvider.alertesActives
                .where((a) => a.niveau != NiveauAlerte.vert)
                .isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
                    SizedBox(width: 12),
                    Text(
                      'Aucune alerte active à Abidjan',
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoyantAlerte(NiveauAlerte niveau, String commune) {
    Color couleur;
    String label;
    IconData icone;

    switch (niveau) {
      case NiveauAlerte.vert:
        couleur = const Color(0xFF2E7D32);
        label = 'Situation normale';
        icone = Icons.check_circle;
        break;
      case NiveauAlerte.orange:
        couleur = const Color(0xFFE65100);
        label = 'Vigilance requise';
        icone = Icons.warning;
        break;
      case NiveauAlerte.rouge:
        couleur = const Color(0xFFC62828);
        label = 'Alerte épidémique';
        icone = Icons.dangerous;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: couleur.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: couleur.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icone, color: couleur, size: 40),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                commune,
                style: TextStyle(
                  color: couleur,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                label,
                style: TextStyle(color: couleur, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String titre,
    required String sousTitre,
    required Color couleur,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: couleur,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: couleur.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 12),
            Text(
              titre,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              sousTitre,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarteAlerte(Alerte alerte) {
    final couleur = Color(alerte.couleur);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
        border: Border(
          left: BorderSide(color: couleur, width: 4),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: couleur),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alerte.commune,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${alerte.nombreCas} cas — ${alerte.labelNiveau}',
                  style: TextStyle(color: couleur, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: couleur.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              alerte.niveau.name.toUpperCase(),
              style: TextStyle(
                color: couleur,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
