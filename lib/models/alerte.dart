enum NiveauAlerte { vert, orange, rouge }

class Alerte {
  final String id;
  final String commune;
  final NiveauAlerte niveau;
  final int nombreCas;
  final String maladieSuspectee;
  final DateTime dateDebut;
  final bool estActive;

  Alerte({
    required this.id,
    required this.commune,
    required this.niveau,
    required this.nombreCas,
    required this.maladieSuspectee,
    required this.dateDebut,
    required this.estActive,
  });

  factory Alerte.fromMap(Map<String, dynamic> map, String id) {
    return Alerte(
      id: id,
      commune: map['commune'] ?? '',
      niveau: NiveauAlerte.values.firstWhere(
        (e) => e.name == map['niveau'],
        orElse: () => NiveauAlerte.vert,
      ),
      nombreCas: map['nombreCas'] ?? 0,
      maladieSuspectee: map['maladieSuspectee'] ?? '',
      dateDebut: DateTime.fromMillisecondsSinceEpoch(map['dateDebut']),
      estActive: map['estActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'commune': commune,
      'niveau': niveau.name,
      'nombreCas': nombreCas,
      'maladieSuspectee': maladieSuspectee,
      'dateDebut': dateDebut.millisecondsSinceEpoch,
      'estActive': estActive,
    };
  }

  // Couleur selon le niveau d'alerte
  int get couleur {
    switch (niveau) {
      case NiveauAlerte.vert:
        return 0xFF2E7D32;
      case NiveauAlerte.orange:
        return 0xFFE65100;
      case NiveauAlerte.rouge:
        return 0xFFC62828;
    }
  }

  // Label selon le niveau d'alerte
  String get labelNiveau {
    switch (niveau) {
      case NiveauAlerte.vert:
        return 'Situation normale';
      case NiveauAlerte.orange:
        return 'Vigilance requise';
      case NiveauAlerte.rouge:
        return 'Alerte épidémique';
    }
  }
}
