import 'departement.dart';

class Classe {
  int? codClass;
  String nomClass;
  int? nbrEtud;
  Departement? departement;

  Classe({this.codClass, required this.nomClass, this.nbrEtud, this.departement});

  factory Classe.fromMap(Map<String, dynamic> map) => Classe(
        codClass: map["codClass"] ?? map["id"],
        nomClass: map["nomClass"] ?? map["nom"] ?? '',
        nbrEtud: map["nbrEtud"],
        departement: map["departement"] != null ? Departement.fromMap(map["departement"]) : null,
      );

  Map<String, dynamic> toMap() => {
        if (codClass != null) "codClass": codClass,
        "nomClass": nomClass,
        if (nbrEtud != null) "nbrEtud": nbrEtud,
        if (departement != null) "departement": departement!.toMap(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Classe &&
          runtimeType == other.runtimeType &&
          codClass == other.codClass;

  @override
  int get hashCode => codClass.hashCode;
}
