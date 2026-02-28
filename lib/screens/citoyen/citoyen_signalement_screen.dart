import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/alert_provider.dart';
import '../../models/signalement.dart';

class CitoyenSignalementScreen extends StatefulWidget {
  const CitoyenSignalementScreen({super.key});

  @override
  State<CitoyenSignalementScreen> createState() =>
      _CitoyenSignalementScreenState();
}

class _CitoyenSignalementScreenState extends State<CitoyenSignalementScreen> {
  final _quartierController = TextEditingController();
  final List<String> _symptomesSelectionnes = [];
  String? _communeSelectionnee;
  bool _signalementEnvoye = false;

  @override
  void initState() {
    super.initState();
    final utilisateur = context.read<AuthProvider>().utilisateur;
    _communeSelectionnee = utilisateur?.commune ?? communesAbidjan.first;
  }

  @override
  void dispose() {
    _quartierController.dispose();
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
      estMedecin: false,
    );

    final succes =
        await context.read<AlertProvider>().soumettreSignalement(signalement);

    if (!mounted) return;

    if (succes) {
      setState(() => _signalementEnvoye = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'envoi du signalement'),
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
        title: const Text('Signaler un cas'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF065A82).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF065A82)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Votre signalement aide à protéger toute la communauté d\'Abidjan.',
                      style: TextStyle(
                        color: Color(0xFF065A82),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Commune
            const Text(
              'Commune',
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
                  onChanged: (value) =>
                      setState(() => _communeSelectionnee = value),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Quartier
            const Text(
              'Quartier (optionnel)',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF065A82),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _quartierController,
              decoration: const InputDecoration(
                hintText: 'Ex: Abobo Baoulé',
                prefixIcon:
                    Icon(Icons.place_outlined, color: Color(0xFF065A82)),
              ),
            ),

            const SizedBox(height: 20),

            // Symptômes
            const Text(
              'Symptômes observés',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF065A82),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Sélectionnez tous les symptômes présents',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
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
                          ? const Color(0xFF065A82)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: estSelectionne
                            ? const Color(0xFF065A82)
                            : const Color(0xFFE2EAF4),
                      ),
                    ),
                    child: Text(
                      symptome,
                      style: TextStyle(
                        color: estSelectionne
                            ? Colors.white
                            : const Color(0xFF065A82),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // Bouton Envoyer
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: alertProvider.chargement ? null : _soumettre,
                icon: alertProvider.chargement
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send),
                label: const Text(
                  'Envoyer le signalement',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
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
                  color: const Color(0xFF2E7D32).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF2E7D32),
                  size: 60,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Signalement envoyé !',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF065A82),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Merci pour votre contribution. Votre signalement aide à protéger la communauté d\'Abidjan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _signalementEnvoye = false;
                    _symptomesSelectionnes.clear();
                    _quartierController.clear();
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
