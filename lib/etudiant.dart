import 'classe.dart';

class Etudiant {
  int? id;
  String? nce;
  String nom;
  String prenom;
  String dateNais;
  String? lieuNais;
  int? nbreEtud;
  Classe? classe;

  Etudiant({
    this.id,
    this.nce,
    required this.nom,
    required this.prenom,
    this.dateNais = '',
    this.lieuNais = '',
    this.nbreEtud = 0,
    this.classe,
  });

  factory Etudiant.fromMap(Map<String, dynamic> map) => Etudiant(
        id: map["id"],
        nce: map["nce"],
        nom: map["nom"] ?? '',
        prenom: map["prenom"] ?? '',
        dateNais: map["dateNais"] ?? '',
        lieuNais: map["lieuNais"] ?? '',
        nbreEtud: map["nbreEtud"] ?? 0,
        classe: map["classe"] != null ? Classe.fromMap(map["classe"]) : null,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) "id": id,
        if (nce != null) "nce": nce,
        "nom": nom,
        "prenom": prenom,
        "dateNais": dateNais,
        if (lieuNais != null) "lieuNais": lieuNais,
        "nbreEtud": nbreEtud,
        if (classe != null) "classe": classe!.toMap(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Etudiant &&
          runtimeType == other.runtimeType &&
          (id != null && id == other.id || nce != null && nce == other.nce);

  @override
  int get hashCode => (id ?? nce).hashCode;
}
