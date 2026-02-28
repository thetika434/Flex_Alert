import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/alert_provider.dart';
import '../../models/alerte.dart';
import '../login_screen.dart';

class AutoriteHomeScreen extends StatefulWidget {
  const AutoriteHomeScreen({super.key});

  @override
  State<AutoriteHomeScreen> createState() => _AutoriteHomeScreenState();
}

class _AutoriteHomeScreenState extends State<AutoriteHomeScreen> {
  int _indexPage = 0;

  @override
  void initState() {
    super.initState();
    context.read<AlertProvider>().ecouterAlertes();
    context.read<AlertProvider>().chargerStatistiques();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _indexPage == 0
          ? const AutoriteDashboard()
          : const AutoriteHistorique(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indexPage,
        onDestinationSelected: (index) => setState(() => _indexPage = index),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF1F4E79).withOpacity(0.1),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: Color(0xFF1F4E79)),
            label: 'Tableau de bord',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history, color: Color(0xFF1F4E79)),
            label: 'Historique',
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════
// TABLEAU DE BORD
// ══════════════════════════════════════════
class AutoriteDashboard extends StatelessWidget {
  const AutoriteDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final alertProvider = context.watch<AlertProvider>();

    final alertesRouges = alertProvider.alertesActives
        .where((a) => a.niveau == NiveauAlerte.rouge)
        .length;
    final alertesOranges = alertProvider.alertesActives
        .where((a) => a.niveau == NiveauAlerte.orange)
        .length;
    final totalCas = alertProvider.alertesActives
        .fold<int>(0, (sum, a) => sum + a.nombreCas);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F4E79),
        title: const Text('Tableau de bord — Autorités'),
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
            // Stats globales
            const Text(
              'Vue d\'ensemble — Abidjan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F4E79),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    alertesRouges.toString(),
                    'Alertes rouges',
                    const Color(0xFFC62828),
                    Icons.dangerous,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    alertesOranges.toString(),
                    'Alertes orange',
                    const Color(0xFFE65100),
                    Icons.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    totalCas.toString(),
                    'Total cas',
                    const Color(0xFF1F4E79),
                    Icons.people,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Alertes par commune
            const Text(
              'Alertes par commune',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F4E79),
              ),
            ),
            const SizedBox(height: 16),

            if (alertProvider.alertesActives.isEmpty)
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
              )
            else
              ...alertProvider.alertesActives
                  .map((alerte) => _buildCarteAlerteAutorite(alerte))
                  .toList(),

            const SizedBox(height: 24),

            // Statistiques par commune
            const Text(
              'Signalements par commune',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F4E79),
              ),
            ),
            const SizedBox(height: 16),

            ...alertProvider.statistiques.entries.map((entry) {
              final total = alertProvider.statistiques.values
                  .fold<int>(0, (sum, v) => sum + v);
              final pourcentage = total > 0 ? entry.value / total : 0.0;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F4E79),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${entry.value} cas',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: pourcentage,
                      backgroundColor: const Color(0xFFE2EAF4),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF1F4E79)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String valeur, String label, Color couleur, IconData icone) {
    return Container(
      padding: const EdgeInsets.all(12),
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
          Icon(icone, color: couleur, size: 20),
          const SizedBox(height: 8),
          Text(
            valeur,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: couleur,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarteAlerteAutorite(Alerte alerte) {
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
        border: Border(left: BorderSide(color: couleur, width: 5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: couleur),
              const SizedBox(width: 8),
              Text(
                alerte.commune,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: couleur.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  alerte.niveau.name.toUpperCase(),
                  style: TextStyle(
                    color: couleur,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildChip(Icons.people, '${alerte.nombreCas} cas', couleur),
              const SizedBox(width: 8),
              _buildChip(Icons.medical_services, alerte.maladieSuspectee,
                  const Color(0xFF1F4E79)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, Color couleur) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: couleur.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: couleur),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: couleur, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════
// HISTORIQUE
// ══════════════════════════════════════════
class AutoriteHistorique extends StatelessWidget {
  const AutoriteHistorique({super.key});

  @override
  Widget build(BuildContext context) {
    final alertProvider = context.watch<AlertProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F4E79),
        title: const Text('Historique des alertes'),
        automaticallyImplyLeading: false,
      ),
      body: alertProvider.alertesActives.isEmpty
          ? const Center(
              child: Text(
                'Aucun historique disponible',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: alertProvider.alertesActives.length,
              itemBuilder: (context, index) {
                final alerte = alertProvider.alertesActives[index];
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
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text(
                              '${alerte.nombreCas} cas — ${alerte.labelNiveau}',
                              style: TextStyle(color: couleur, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: couleur.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          alerte.estActive ? 'Actif' : 'Terminé',
                          style: TextStyle(
                              color: couleur,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
