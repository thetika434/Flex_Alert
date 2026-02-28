import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/alert_provider.dart';
import '../../models/signalement.dart';

class MedecinSignalementScreen extends StatefulWidget {
  const MedecinSignalementScreen({super.key});

  @override
  State<MedecinSignalementScreen> createState() =>
      _MedecinSignalementScreenState();
}

class _MedecinSignalementScreenState extends State<MedecinSignalementScreen> {
  final _quartierController = TextEditingController();
  final _ageController = TextEditingController();
  final List<String> _symptomesSelectionnes = [];
  String? _communeSelectionnee;
  String? _maladieSuspectee;
  GraviteSignalement _gravite = GraviteSignalement.leger;
  String _sexePatient = 'Masculin';
  bool _signalementEnvoye = false;

  final List<String> _maladies = [
    'Choléra',
    'Dengue',
    'Paludisme',
    'Fièvre Typhoïde',
    'Méningite',
    'Mpox',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    final utilisateur = context.read<AuthProvider>().utilisateur;
    _communeSelectionnee = utilisateur?.commune ?? communesAbidjan.first;
    _maladieSuspectee = _maladies.first;
  }

  @override
  void dispose() {
    _quartierController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _soumettre() async {
    if (_symptomesSelectionnes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner au moins un symptôme'),
          backgroundColor: Color(0xFFE65100),
        ),
      );
      return;
    }

    final utilisateur = context.read<AuthProvider>().utilisateur;
    final signalement = Signalement(
      id: '',
      utilisateurId: utilisateur?.id ?? '',
      commune: _communeSelectionnee!,
      quartier: _quartierController.text.trim(),
      symptomes: _symptomesSelectionnes,
      date: DateTime.now(),
      estMedecin: true,
      maladieSuspectee: _maladieSuspectee,
      gravite: _gravite,
      agePatient: int.tryParse(_ageController.text),
      sexePatient: _sexePatient,
    );

    final succes =
        await context.read<AlertProvider>().soumettreSignalement(signalement);

    if (!mounted) return;

    if (succes) {
      setState(() => _signalementEnvoye = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'envoi'),
          backgroundColor: Color(0xFFC62828),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final alertProvider = context.watch<AlertProvider>();

    if (_signalementEnvoye) {
      return _buildSucces();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF028090),
        title: const Text('Signalement médical'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Commune
            const Text('Commune',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: Color(0xFF028090))),
            const SizedBox(height: 8),
            _buildDropdown(
              value: _communeSelectionnee!,
              items: communesAbidjan,
              onChanged: (v) => setState(() => _communeSelectionnee = v),
            ),

            const SizedBox(height: 20),

            // Quartier
            const Text('Quartier (optionnel)',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: Color(0xFF028090))),
            const SizedBox(height: 8),
            TextField(
              controller: _quartierController,
              decoration: const InputDecoration(
                hintText: 'Ex: Abobo Baoulé',
                prefixIcon:
                    Icon(Icons.place_outlined, color: Color(0xFF028090)),
              ),
            ),

            const SizedBox(height: 20),

            // Maladie suspectée
            const Text('Maladie suspectée',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: Color(0xFF028090))),
            const SizedBox(height: 8),
            _buildDropdown(
              value: _maladieSuspectee!,
              items: _maladies,
              onChanged: (v) => setState(() => _maladieSuspectee = v),
            ),

            const SizedBox(height: 20),

            // Gravité
            const Text('Gravité du cas',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: Color(0xFF028090))),
            const SizedBox(height: 8),
            Row(
              children: GraviteSignalement.values.map((g) {
                final estSelectionne = _gravite == g;
                Color couleur;
                switch (g) {
                  case GraviteSignalement.leger:
                    couleur = const Color(0xFF2E7D32);
                    break;
                  case GraviteSignalement.modere:
                    couleur = const Color(0xFFE65100);
                    break;
                  case GraviteSignalement.grave:
                    couleur = const Color(0xFFC62828);
                    break;
                }
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _gravite = g),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: estSelectionne ? couleur : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: estSelectionne
                              ? couleur
                              : const Color(0xFFE2EAF4),
                        ),
                      ),
                      child: Text(
                        g.name[0].toUpperCase() + g.name.substring(1),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: estSelectionne ? Colors.white : couleur,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Infos patient
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Âge du patient',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF028090))),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Ex: 35',
                          prefixIcon:
                              Icon(Icons.person, color: Color(0xFF028090)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Sexe',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF028090))),
                      const SizedBox(height: 8),
                      _buildDropdown(
                        value: _sexePatient,
                        items: ['Masculin', 'Féminin'],
                        onChanged: (v) => setState(() => _sexePatient = v!),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Symptômes
            const Text('Symptômes observés',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: Color(0xFF028090))),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: symptomesDisponibles.map((symptome) {
                final estSelectionne =
                    _symptomesSelectionnes.contains(symptome);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (estSelectionne) {
                        _symptomesSelectionnes.remove(symptome);
                      } else {
                        _symptomesSelectionnes.add(symptome);
                      }
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: estSelectionne
                          ? const Color(0xFF028090)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: estSelectionne
                            ? const Color(0xFF028090)
                            : const Color(0xFFE2EAF4),
                      ),
                    ),
                    child: Text(
                      symptome,
                      style: TextStyle(
                        color: estSelectionne
                            ? Colors.white
                            : const Color(0xFF028090),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF028090),
                ),
                onPressed: alertProvider.chargement ? null : _soumettre,
                icon: const Icon(Icons.send),
                label: const Text(
                  'Envoyer le signalement médical',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2EAF4)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF028090)),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSucces() {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF028090).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle,
                    color: Color(0xFF028090), size: 60),
              ),
              const SizedBox(height: 24),
              const Text(
                'Signalement médical envoyé !',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF028090),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Votre signalement médical a été transmis aux autorités sanitaires.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF028090)),
                onPressed: () {
                  setState(() {
                    _signalementEnvoye = false;
                    _symptomesSelectionnes.clear();
                    _quartierController.clear();
                    _ageController.clear();
                  });
                },
                child: const Text('Nouveau signalement'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
