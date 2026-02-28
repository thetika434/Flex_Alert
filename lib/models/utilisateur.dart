enum TypeUtilisateur { citoyen, medecin, autorite }

class Utilisateur {
  final String id;
  final String nom;
  final String email;
  final TypeUtilisateur type;
  final String commune;

  Utilisateur({
    required this.id,
    required this.nom,
    required this.email,
    required this.type,
    required this.commune,
  });

  factory Utilisateur.fromMap(Map<String, dynamic> map, String id) {
    return Utilisateur(
      id: id,
      nom: map['nom'] ?? '',
      email: map['email'] ?? '',
      type: TypeUtilisateur.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TypeUtilisateur.citoyen,
      ),
      commune: map['commune'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'email': email,
      'type': type.name,
      'commune': commune,
    };
  }
}
