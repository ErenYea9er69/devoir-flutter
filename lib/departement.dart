class Departement {
  final int? codDept;
  final String nomDept;

  Departement({this.codDept, required this.nomDept});

  factory Departement.fromMap(Map<String, dynamic> map) {
    return Departement(
      codDept: map['codDept'],
      nomDept: map['nomDept'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (codDept != null) 'codDept': codDept,
      'nomDept': nomDept,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Departement &&
          runtimeType == other.runtimeType &&
          codDept == other.codDept;

  @override
  int get hashCode => codDept.hashCode;
}
