import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/alert_provider.dart';
import '../../models/alerte.dart';

class CitoyenAlertesScreen extends StatefulWidget {
  const CitoyenAlertesScreen({super.key});

  @override
  State<CitoyenAlertesScreen> createState() => _CitoyenAlertesScreenState();
}

class _CitoyenAlertesScreenState extends State<CitoyenAlertesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AlertProvider>().ecouterAlertes();
  }

  @override
  Widget build(BuildContext context) {
    final alertProvider = context.watch<AlertProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        title: const Text('Alertes en cours'),
        automaticallyImplyLeading: false,
      ),
      body: alertProvider.alertesActives.isEmpty
          ? _buildAucuneAlerte()
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: alertProvider.alertesActives.length,
              itemBuilder: (context, index) {
                final alerte = alertProvider.alertesActives[index];
                return _buildCarteAlerte(alerte);
              },
            ),
    );
  }

  Widget _buildAucuneAlerte() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Color(0xFF2E7D32),
              size: 60,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Aucune alerte active',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF065A82),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Abidjan est en situation normale',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarteAlerte(Alerte alerte) {
    final couleur = Color(alerte.couleur);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          left: BorderSide(color: couleur, width: 5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: couleur),
                const SizedBox(width: 8),
                Text(
                  alerte.commune,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                _buildInfoChip(
                  Icons.people,
                  '${alerte.nombreCas} cas',
                  couleur,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  Icons.medical_services,
                  alerte.maladieSuspectee,
                  const Color(0xFF065A82),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: couleur.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: couleur, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      alerte.labelNiveau,
                      style: TextStyle(
                        color: couleur,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildInfoChip(IconData icon, String label, Color couleur) {
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
          Text(
            label,
            style: TextStyle(
              color: couleur,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
