import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/utilisateur.dart';
import '../models/signalement.dart';
import '../models/alerte.dart';

class FirebaseService {
  // Instances Firebase
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ══════════════════════════════════════════
  // AUTHENTIFICATION
  // ══════════════════════════════════════════

  // Inscription
  Future<User?> inscrire({
    required String email,
    required String motDePasse,
    required String nom,
    required TypeUtilisateur type,
    required String commune,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: motDePasse,
      );

      if (result.user != null) {
        // Sauvegarder les infos utilisateur dans Firestore
        await _firestore.collection('utilisateurs').doc(result.user!.uid).set({
          'nom': nom,
          'email': email,
          'type': type.name,
          'commune': commune,
          'dateInscription': DateTime.now().millisecondsSinceEpoch,
        });
      }

      return result.user;
    } catch (e) {
      throw Exception('Erreur inscription : $e');
    }
  }

  // Connexion
  Future<User?> connecter({
    required String email,
    required String motDePasse,
  }) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: motDePasse,
      );
      return result.user;
    } catch (e) {
      throw Exception('Erreur connexion : $e');
    }
  }

  // Déconnexion
  Future<void> deconnecter() async {
    await _auth.signOut();
  }

  // Récupérer l'utilisateur connecté
  User? get utilisateurConnecte => _auth.currentUser;

  // Récupérer le profil utilisateur depuis Firestore
  Future<Utilisateur?> getProfil(String uid) async {
    try {
      final doc = await _firestore.collection('utilisateurs').doc(uid).get();
      if (doc.exists) {
        return Utilisateur.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur récupération profil : $e');
    }
  }

  // ══════════════════════════════════════════
  // SIGNALEMENTS
  // ══════════════════════════════════════════

  // Soumettre un signalement
  Future<void> soumettreSignalement(Signalement signalement) async {
    try {
      await _firestore.collection('signalements').add(signalement.toMap());

      // Vérifier si une alerte doit être déclenchée
      await _verifierEtDeclencherAlerte(signalement.commune);
    } catch (e) {
      throw Exception('Erreur signalement : $e');
    }
  }

  // Récupérer les signalements d'une commune
  Stream<List<Signalement>> getSignalements(String commune) {
    return _firestore
        .collection('signalements')
        .where('commune', isEqualTo: commune)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Signalement.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Récupérer tous les signalements (pour les autorités)
  Stream<List<Signalement>> getTousSignalements() {
    return _firestore
        .collection('signalements')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Signalement.fromMap(doc.data(), doc.id))
            .toList());
  }

  // ══════════════════════════════════════════
  // ALERTES
  // ══════════════════════════════════════════

  // Vérifier et déclencher une alerte automatiquement
  Future<void> _verifierEtDeclencherAlerte(String commune) async {
    try {
      final maintenant = DateTime.now();

      // Vérifier les cas des 72 dernières heures
      final ilYa72h = maintenant.subtract(const Duration(hours: 72));
      final snapshot = await _firestore
          .collection('signalements')
          .where('commune', isEqualTo: commune)
          .where('date', isGreaterThanOrEqualTo: ilYa72h.millisecondsSinceEpoch)
          .get();

      final nombreCas = snapshot.docs.length;

      // Déterminer le niveau d'alerte
      NiveauAlerte niveau;
      if (nombreCas >= 15) {
        niveau = NiveauAlerte.rouge;
      } else if (nombreCas >= 5) {
        niveau = NiveauAlerte.orange;
      } else {
        niveau = NiveauAlerte.vert;
      }

      // Mettre à jour ou créer l'alerte de la commune
      final alerteExistante = await _firestore
          .collection('alertes')
          .where('commune', isEqualTo: commune)
          .where('estActive', isEqualTo: true)
          .get();

      if (alerteExistante.docs.isNotEmpty) {
        // Mettre à jour l'alerte existante
        await _firestore
            .collection('alertes')
            .doc(alerteExistante.docs.first.id)
            .update({
          'niveau': niveau.name,
          'nombreCas': nombreCas,
        });
      } else {
        // Créer une nouvelle alerte
        await _firestore.collection('alertes').add({
          'commune': commune,
          'niveau': niveau.name,
          'nombreCas': nombreCas,
          'maladieSuspectee': 'En cours d\'analyse',
          'dateDebut': maintenant.millisecondsSinceEpoch,
          'estActive': true,
        });
      }
    } catch (e) {
      throw Exception('Erreur vérification alerte : $e');
    }
  }

  // Récupérer les alertes actives
  Stream<List<Alerte>> getAlertesActives() {
    return _firestore
        .collection('alertes')
        .where('estActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Alerte.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Récupérer l'alerte d'une commune spécifique
  Stream<Alerte?> getAlerteCommune(String commune) {
    return _firestore
        .collection('alertes')
        .where('commune', isEqualTo: commune)
        .where('estActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return Alerte.fromMap(
            snapshot.docs.first.data(), snapshot.docs.first.id);
      }
      return null;
    });
  }

  // Récupérer l'historique des alertes (pour les autorités)
  Future<List<Alerte>> getHistoriqueAlertes() async {
    try {
      final snapshot = await _firestore
          .collection('alertes')
          .orderBy('dateDebut', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => Alerte.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Erreur historique : $e');
    }
  }

  // Récupérer les statistiques par commune (pour le tableau de bord)
  Future<Map<String, int>> getStatistiquesParCommune() async {
    try {
      final snapshot = await _firestore.collection('signalements').get();
      final Map<String, int> stats = {};

      for (final doc in snapshot.docs) {
        final commune = doc.data()['commune'] as String;
        stats[commune] = (stats[commune] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      throw Exception('Erreur statistiques : $e');
    }
  }
}
