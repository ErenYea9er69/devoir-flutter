import 'etudiant.dart';
import 'matiere.dart';

class Note {
  final int? id;
  final Etudiant? etudiant;
  final Matiere? matiere;
  final double? tp1;
  final double? tp2;
  final double? ds;
  final double? examen;

  Note({
    this.id,
    this.etudiant,
    this.matiere,
    this.tp1,
    this.tp2,
    this.ds,
    this.examen,
  });

  factory Note.fromMap(Map<String, dynamic> map) {
    final examVal = map['examen'] ?? map['exam'];
    return Note(
      id: map['id'],
      etudiant: map['etudiant'] != null ? Etudiant.fromMap(map['etudiant']) : null,
      matiere: map['matiere'] != null ? Matiere.fromMap(map['matiere']) : null,
      tp1: (map['tp1'] as num?)?.toDouble(),
      tp2: (map['tp2'] as num?)?.toDouble(),
      ds: (map['ds'] as num?)?.toDouble(),
      examen: (examVal as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (etudiant != null) 'etudiant': etudiant!.toMap(),
      if (matiere != null) 'matiere': matiere!.toMap(),
      if (tp1 != null) 'tp1': tp1,
      if (tp2 != null) 'tp2': tp2,
      if (ds != null) 'ds': ds,
      if (examen != null) 'examen': examen,
    };
  }
}
