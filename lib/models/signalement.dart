enum GraviteSignalement { leger, modere, grave }

class Signalement {
  final String id;
  final String utilisateurId;
  final String commune;
  final String quartier;
  final List<String> symptomes;
  final DateTime date;
  final bool estMedecin;

  // Champs spécifiques au médecin
  final String? maladieSuspectee;
  final GraviteSignalement? gravite;
  final int? agePatient;
  final String? sexePatient;

  Signalement({
    required this.id,
    required this.utilisateurId,
    required this.commune,
    required this.quartier,
    required this.symptomes,
    required this.date,
    required this.estMedecin,
    this.maladieSuspectee,
    this.gravite,
    this.agePatient,
    this.sexePatient,
  });

  factory Signalement.fromMap(Map<String, dynamic> map, String id) {
    return Signalement(
      id: id,
      utilisateurId: map['utilisateurId'] ?? '',
      commune: map['commune'] ?? '',
      quartier: map['quartier'] ?? '',
      symptomes: List<String>.from(map['symptomes'] ?? []),
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      estMedecin: map['estMedecin'] ?? false,
      maladieSuspectee: map['maladieSuspectee'],
      gravite: map['gravite'] != null
          ? GraviteSignalement.values.firstWhere(
              (e) => e.name == map['gravite'],
              orElse: () => GraviteSignalement.leger,
            )
          : null,
      agePatient: map['agePatient'],
      sexePatient: map['sexePatient'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'utilisateurId': utilisateurId,
      'commune': commune,
      'quartier': quartier,
      'symptomes': symptomes,
      'date': date.millisecondsSinceEpoch,
      'estMedecin': estMedecin,
      'maladieSuspectee': maladieSuspectee,
      'gravite': gravite?.name,
      'agePatient': agePatient,
      'sexePatient': sexePatient,
    };
  }
}

// Liste des symptômes disponibles
const List<String> symptomesDisponibles = [
  'Fièvre',
  'Vomissements',
  'Diarrhée',
  'Toux',
  'Difficultés respiratoires',
  'Maux de tête',
  'Douleurs musculaires',
  'Éruption cutanée',
  'Fatigue intense',
  'Perte de conscience',
];

// Liste des communes d'Abidjan
const List<String> communesAbidjan = [
  'Abobo',
  'Adjamé',
  'Attécoubé',
  'Cocody',
  'Koumassi',
  'Marcory',
  'Plateau',
  'Port-Bouët',
  'Treichville',
  'Yopougon',
];
