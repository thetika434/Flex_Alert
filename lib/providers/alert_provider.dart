import 'package:flutter/material.dart';
import '../models/alerte.dart';
import '../models/signalement.dart';
import '../services/firebase_service.dart';

class AlertProvider extends ChangeNotifier {
  final FirebaseService _service = FirebaseService();

  List<Alerte> _alertesActives = [];
  List<Signalement> _signalements = [];
  Map<String, int> _statistiques = {};
  bool _chargement = false;
  String? _erreur;

  // Getters
  List<Alerte> get alertesActives => _alertesActives;
  List<Signalement> get signalements => _signalements;
  Map<String, int> get statistiques => _statistiques;
  bool get chargement => _chargement;
  String? get erreur => _erreur;

  // Écouter les alertes actives en temps réel
  void ecouterAlertes() {
    _service.getAlertesActives().listen((alertes) {
      _alertesActives = alertes;
      notifyListeners();
    });
  }

  // Écouter les signalements d'une commune
  void ecouterSignalements(String commune) {
    _service.getSignalements(commune).listen((signalements) {
      _signalements = signalements;
      notifyListeners();
    });
  }

  // Écouter tous les signalements (autorités)
  void ecouterTousSignalements() {
    _service.getTousSignalements().listen((signalements) {
      _signalements = signalements;
      notifyListeners();
    });
  }

  // Soumettre un signalement
  Future<bool> soumettreSignalement(Signalement signalement) async {
    _chargement = true;
    _erreur = null;
    notifyListeners();

    try {
      await _service.soumettreSignalement(signalement);
      _chargement = false;
      notifyListeners();
      return true;
    } catch (e) {
      _erreur = e.toString();
      _chargement = false;
      notifyListeners();
      return false;
    }
  }

  // Charger les statistiques (autorités)
  Future<void> chargerStatistiques() async {
    _chargement = true;
    notifyListeners();

    try {
      _statistiques = await _service.getStatistiquesParCommune();
      _chargement = false;
      notifyListeners();
    } catch (e) {
      _erreur = e.toString();
      _chargement = false;
      notifyListeners();
    }
  }

  // Obtenir le niveau d'alerte d'une commune
  NiveauAlerte getNiveauAlerte(String commune) {
    final alerte = _alertesActives.firstWhere(
      (a) => a.commune == commune,
      orElse: () => Alerte(
        id: '',
        commune: commune,
        niveau: NiveauAlerte.vert,
        nombreCas: 0,
        maladieSuspectee: '',
        dateDebut: DateTime.now(),
        estActive: false,
      ),
    );
    return alerte.niveau;
  }
}
