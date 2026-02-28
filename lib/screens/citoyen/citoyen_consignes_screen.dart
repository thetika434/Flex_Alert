import 'package:flutter/material.dart';

class CitoyenConsignesScreen extends StatelessWidget {
  const CitoyenConsignesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        title: const Text('Consignes de protection'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildCarteConsigne(
            titre: 'Choléra',
            icone: Icons.water_drop,
            couleur: const Color(0xFF065A82),
            symptomes: ['Diarrhée aqueuse', 'Vomissements', 'Déshydratation'],
            consignes: [
              'Boire uniquement de l\'eau bouillie ou en bouteille',
              'Se laver les mains régulièrement au savon',
              'Consulter immédiatement un médecin',
              'Éviter les aliments crus',
            ],
          ),
          _buildCarteConsigne(
            titre: 'Dengue',
            icone: Icons.bug_report,
            couleur: const Color(0xFFE65100),
            symptomes: [
              'Forte fièvre',
              'Douleurs musculaires',
              'Éruption cutanée'
            ],
            consignes: [
              'Éliminer les eaux stagnantes autour de la maison',
              'Utiliser des moustiquaires la nuit',
              'Porter des vêtements couvrants',
              'Consulter un médecin si fièvre > 38°C',
            ],
          ),
          _buildCarteConsigne(
            titre: 'Paludisme',
            icone: Icons.coronavirus,
            couleur: const Color(0xFF028090),
            symptomes: ['Fièvre', 'Frissons', 'Maux de tête', 'Fatigue'],
            consignes: [
              'Dormir sous moustiquaire imprégnée',
              'Utiliser des répulsifs anti-moustiques',
              'Prendre un traitement préventif si prescrit',
              'Consulter rapidement en cas de fièvre',
            ],
          ),
          _buildCarteConsigne(
            titre: 'Fièvre Typhoïde',
            icone: Icons.sick,
            couleur: const Color(0xFF2E7D32),
            symptomes: [
              'Fièvre prolongée',
              'Maux de ventre',
              'Diarrhée ou constipation'
            ],
            consignes: [
              'Boire uniquement de l\'eau potable',
              'Se laver les mains avant de manger',
              'Éviter les aliments de rue non cuits',
              'Se faire vacciner si possible',
            ],
          ),
          // Consignes générales
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF065A82),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.health_and_safety, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Consignes générales',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...[
                  'Se laver les mains régulièrement',
                  'Signaler tout cas suspect sur FlexAlert',
                  'Consulter un médecin sans attendre',
                  'Informer votre entourage en cas de maladie',
                ].map((consigne) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle,
                              color: Color(0xFF02C39A), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              consigne,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarteConsigne({
    required String titre,
    required IconData icone,
    required Color couleur,
    required List<String> symptomes,
    required List<String> consignes,
  }) {
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
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: couleur.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icone, color: couleur),
        ),
        title: Text(
          titre,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: couleur,
          ),
        ),
        subtitle: Text(
          symptomes.join(' • '),
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const Text(
                  'Que faire ?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF065A82),
                  ),
                ),
                const SizedBox(height: 8),
                ...consignes.map((consigne) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.arrow_right, color: couleur, size: 20),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              consigne,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
