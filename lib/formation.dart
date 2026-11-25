class Formation {
  int? id;
  String nom;
  int duree;

  Formation({this.id, required this.nom, required this.duree});

  factory Formation.fromMap(Map<String, dynamic> map) => Formation(
        id: map["id"],
        nom: map["nom"] ?? '',
        duree: map["duree"] ?? 0,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) "id": id,
        "nom": nom,
        "duree": duree,
      };
}
