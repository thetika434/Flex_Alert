import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/alert_provider.dart';
import '../../models/alerte.dart';
import '../login_screen.dart';
import 'medecin_signalement_screen.dart';
import '../citoyen/citoyen_alertes_screen.dart';
import '../citoyen/citoyen_consignes_screen.dart';

class MedecinHomeScreen extends StatefulWidget {
  const MedecinHomeScreen({super.key});

  @override
  State<MedecinHomeScreen> createState() => _MedecinHomeScreenState();
}

class _MedecinHomeScreenState extends State<MedecinHomeScreen> {
  int _indexPage = 0;

  final List<Widget> _pages = [
    const MedecinAccueil(),
    const MedecinSignalementScreen(),
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
        indicatorColor: const Color(0xFF028090).withOpacity(0.1),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Color(0xFF028090)),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle, color: Color(0xFF028090)),
            label: 'Signaler',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications, color: Color(0xFF028090)),
            label: 'Alertes',
          ),
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield, color: Color(0xFF028090)),
            label: 'Consignes',
          ),
        ],
      ),
    );
  }
}

class MedecinAccueil extends StatelessWidget {
  const MedecinAccueil({super.key});

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
        backgroundColor: const Color(0xFF028090),
        title: const Text('FlexAlert — Médecin'),
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
            // Badge médecin
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF028090).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.medical_services,
                      color: Color(0xFF028090), size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Profil Médecin',
                    style: TextStyle(
                      color: Color(0xFF028090),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Dr. ${utilisateur?.nom ?? ''} 👨‍⚕️',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF028090),
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

            // Voyant alerte commune
            _buildVoyantAlerte(niveauAlerte, commune),

            const SizedBox(height: 24),

            // Stats rapides
            const Text(
              'Situation épidémique',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF028090),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    alertProvider.alertesActives
                        .where((a) => a.niveau == NiveauAlerte.rouge)
                        .length
                        .toString(),
                    'Alertes rouges',
                    const Color(0xFFC62828),
                    Icons.dangerous,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    alertProvider.alertesActives
                        .where((a) => a.niveau == NiveauAlerte.orange)
                        .length
                        .toString(),
                    'Alertes orange',
                    const Color(0xFFE65100),
                    Icons.warning,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Alertes actives
            const Text(
              'Alertes actives',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF028090),
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
                      'Aucune alerte active',
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

  Widget _buildStatCard(
      String valeur, String label, Color couleur, IconData icone) {
    return Container(
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: couleur),
          const SizedBox(height: 8),
          Text(
            valeur,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: couleur,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
        ],
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
        border: Border(left: BorderSide(color: couleur, width: 4)),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: couleur),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alerte.commune,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('${alerte.nombreCas} cas — ${alerte.labelNiveau}',
                    style: TextStyle(color: couleur, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
