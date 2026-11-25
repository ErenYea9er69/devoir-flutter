import 'etudiant.dart';
import 'matiere.dart';

class Absence {
  final int? id;
  final Matiere matiere;
  final Etudiant etudiant;
  final String dateA;
  final double nha;

  Absence({
    this.id,
    required this.matiere,
    required this.etudiant,
    required this.dateA,
    required this.nha,
  });

  factory Absence.fromMap(Map<String, dynamic> map) {
    return Absence(
      id: map['id'],
      matiere: Matiere.fromMap(map['matiere'] ?? {}),
      etudiant: Etudiant.fromMap(map['etudiant'] ?? {}),
      dateA: map['dateA'] ?? '',
      nha: (map['nha'] is num) ? (map['nha'] as num).toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'matiere': matiere.toMap(),
      'etudiant': etudiant.toMap(),
      'dateA': dateA,
      'nha': nha,
    };
  }
}
