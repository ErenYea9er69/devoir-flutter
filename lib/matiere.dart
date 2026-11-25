class Matiere {
  final String codMat;
  final String? intMat;
  final String? description;
  final String? type; // "Cours" or "TP"

  Matiere({
    required this.codMat,
    this.intMat,
    this.description,
    this.type,
  });

  factory Matiere.fromMap(Map<String, dynamic> map) {
    return Matiere(
      codMat: map['codMat'] ?? '',
      intMat: map['intMat'],
      description: map['description'],
      type: map['type'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'codMat': codMat,
      if (intMat != null) 'intMat': intMat,
      if (description != null) 'description': description,
      if (type != null) 'type': type,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Matiere &&
          runtimeType == other.runtimeType &&
          codMat == other.codMat;

  @override
  int get hashCode => codMat.hashCode;
}
