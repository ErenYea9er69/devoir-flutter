import 'classe.dart';
import 'matiere.dart';

class ClassMat {
  final int? id;
  final Matiere? matiere;
  final Classe? classe;
  final double? coef;
  final double? chsm;

  ClassMat({
    this.id,
    this.matiere,
    this.classe,
    this.coef,
    this.chsm,
  });

  factory ClassMat.fromMap(Map<String, dynamic> map) {
    return ClassMat(
      id: map['id'],
      matiere: map['matiere'] != null ? Matiere.fromMap(map['matiere']) : null,
      classe: map['classe'] != null ? Classe.fromMap(map['classe']) : null,
      coef: (map['coef'] as num?)?.toDouble(),
      chsm: (map['chsm'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (matiere != null) 'matiere': matiere!.toMap(),
      if (classe != null) 'classe': classe!.toMap(),
      if (coef != null) 'coef': coef,
      if (chsm != null) 'chsm': chsm,
    };
  }
}
