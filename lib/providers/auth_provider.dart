import 'package:flutter/material.dart';
import '../models/utilisateur.dart';
import '../services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseService _service = FirebaseService();

  Utilisateur? _utilisateur;
  bool _chargement = false;
  String? _erreur;

  // Getters
  Utilisateur? get utilisateur => _utilisateur;
  bool get chargement => _chargement;
  String? get erreur => _erreur;
  bool get estConnecte => _utilisateur != null;

  // Vérifier si l'utilisateur est déjà connecté au démarrage
  Future<void> verifierConnexion() async {
    final user = _service.utilisateurConnecte;
    if (user != null) {
      _utilisateur = await _service.getProfil(user.uid);
      notifyListeners();
    }
  }

  // Inscription// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

  Future<bool> inscrire({
    required String email,
    required String motDePasse,
    required String nom,
    required TypeUtilisateur type,
    required String commune,
  }) async {
    _chargement = true;
    _erreur = null;
    notifyListeners();

    try {
      final user = await _service.inscrire(
        email: email,
        motDePasse: motDePasse,
        nom: nom,
        type: type,
        commune: commune,
      );

      if (user != null) {
        _utilisateur = await _service.getProfil(user.uid);
        _chargement = false;
        notifyListeners();
        return true;
      }

      _chargement = false;
      notifyListeners();
      return false;
    } catch (e) {
      _erreur = e.toString();
      _chargement = false;
      notifyListeners();
      return false;
    }
  }

  // Connexion
  Future<bool> connecter({
    required String email,
    required String motDePasse,
  }) async {
    _chargement = true;
    _erreur = null;
    notifyListeners();

    try {
      final user = await _service.connecter(
        email: email,
        motDePasse: motDePasse,
      );

      if (user != null) {
        _utilisateur = await _service.getProfil(user.uid);
        _chargement = false;
        notifyListeners();
        return true;
      }

      _chargement = false;
      notifyListeners();
      return false;
    } catch (e) {
      _erreur = e.toString();
      _chargement = false;
      notifyListeners();
      return false;
    }
  }

  // Déconnexion
  Future<void> deconnecter() async {
    await _service.deconnecter();
    _utilisateur = null;
    notifyListeners();
  }
}
