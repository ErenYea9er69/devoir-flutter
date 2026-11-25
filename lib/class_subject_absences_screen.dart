import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'absence.dart';
import 'api_config.dart';
import 'class_mat.dart';
import 'classe.dart';
import 'departement.dart';
import 'etudiant.dart';
import 'matiere.dart';

class StudentNhaRow {
  final String nom;
  final String prenom;
  final double nha;

  StudentNhaRow({
    required this.nom,
    required this.prenom,
    required this.nha,
  });
}

class ClassSubjectAbsencesScreen extends StatefulWidget {
  const ClassSubjectAbsencesScreen({super.key});

  @override
  State<ClassSubjectAbsencesScreen> createState() =>
      _ClassSubjectAbsencesScreenState();
}

class _ClassSubjectAbsencesScreenState
    extends State<ClassSubjectAbsencesScreen> {
  List<Departement> _departements = [];
  List<Classe> _classes = [];
  List<Matiere> _matieres = [];
  List<StudentNhaRow> _rows = [];

  Departement? _selectedDept;
  Classe? _selectedClasse;
  Matiere? _selectedMatiere;

  double _chsm = 45.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final dRes = await http.get(Uri.parse("$baseUrl/departements"));
      final mRes = await http.get(Uri.parse("$baseUrl/matieres"));

      if (dRes.statusCode == 200 && mRes.statusCode == 200 && mounted) {
        final List<dynamic> dData = json.decode(dRes.body);
        final List<dynamic> mData = json.decode(mRes.body);

        setState(() {
          _departements = dData.map((e) => Departement.fromMap(e)).toList();
          _matieres = mData.map((e) => Matiere.fromMap(e)).toList();
          _selectedDept = _departements.isNotEmpty ? _departements.first : null;
          _selectedMatiere = _matieres.isNotEmpty ? _matieres.first : null;
        });

        if (_selectedDept?.codDept != null) {
          await _loadClassesForDept(_selectedDept!.codDept!);
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadClassesForDept(int codDept) async {
    try {
      final cRes = await http.get(Uri.parse("$baseUrl/classes/dept/$codDept"));
      if (cRes.statusCode == 200 && mounted) {
        final List<dynamic> cData = json.decode(cRes.body);
        setState(() {
          _classes = cData.map((e) => Classe.fromMap(e)).toList();
          _selectedClasse = _classes.firstWhere(
            (c) => c.nomClass == 'DSI33',
            orElse: () => _classes.isNotEmpty ? _classes.first : Classe(nomClass: ''),
          );
          if (_classes.isEmpty) _selectedClasse = null;
        });
        await _loadAbsencesReport();
      }
    } catch (_) {}
  }

  Future<void> _loadAbsencesReport() async {
    if (_selectedClasse?.codClass == null || _selectedMatiere == null) {
      setState(() => _rows = []);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final codClass = _selectedClasse!.codClass!;
      final codMat = _selectedMatiere!.codMat;

      final sRes = await http.get(Uri.parse("$baseUrl/etudiants/classe/$codClass"));

      double resolvedChsm = 45.0;
      try {
        final cmRes = await http.get(
          Uri.parse("$baseUrl/classmats/classe/$codClass/matiere/$codMat"),
        );
        if (cmRes.statusCode == 200 && cmRes.body.isNotEmpty && cmRes.body != "null") {
          final cm = ClassMat.fromMap(json.decode(cmRes.body));
          if (cm.chsm != null) {
            resolvedChsm = cm.chsm!;
          }
        }
      } catch (_) {}

      if (sRes.statusCode == 200 && mounted) {
        final List<dynamic> sData = json.decode(sRes.body);
        final students = sData.map((e) => Etudiant.fromMap(e)).toList();

        final absenceResponses = await Future.wait(
          students.where((st) => st.nce != null && st.nce!.isNotEmpty).map(
                (st) => http
                    .get(Uri.parse("$baseUrl/absences/etudiant/${st.nce}"))
                    .then((res) => MapEntry(st, res)),
              ),
        );

        final List<StudentNhaRow> computed = [];
        for (final entry in absenceResponses) {
          final st = entry.key;
          final aRes = entry.value;
          if (aRes.statusCode != 200) continue;

          final List<dynamic> aData = json.decode(aRes.body);
          final absences = aData.map((e) => Absence.fromMap(e)).toList();

          final totalNha = absences
              .where((a) => a.matiere.codMat == codMat)
              .fold(0.0, (sum, a) => sum + a.nha);

          if (totalNha > 0) {
            computed.add(StudentNhaRow(
              nom: st.nom,
              prenom: st.prenom,
              nha: totalNha,
            ));
          }
        }

        computed.sort((a, b) => b.nha.compareTo(a.nha));

        if (mounted) {
          setState(() {
            _chsm = resolvedChsm;
            _rows = computed;
          });
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  String _formatToday() {
    final now = DateTime.now();
    final d = now.day.toString().padLeft(2, '0');
    final m = now.month.toString().padLeft(2, '0');
    return "$d-$m-${now.year}";
  }

  String _formatNha(double val) {
    return val == val.roundToDouble() ? val.toInt().toString() : val.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text("Département : ", style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: DropdownButton<Departement>(
                  isExpanded: true,
                  value: _selectedDept,
                  items: _departements
                      .map((d) => DropdownMenuItem(value: d, child: Text(d.nomDept)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedDept = val);
                      _loadClassesForDept(val.codDept!);
                    }
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Text("Classe : ", style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: DropdownButton<Classe>(
                  isExpanded: true,
                  value: _selectedClasse,
                  items: _classes
                      .map((c) => DropdownMenuItem(value: c, child: Text(c.nomClass)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedClasse = val);
                      _loadAbsencesReport();
                    }
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Text("Matière : ", style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: DropdownButton<Matiere>(
                  isExpanded: true,
                  value: _selectedMatiere,
                  items: _matieres
                      .map((m) => DropdownMenuItem(value: m, child: Text(m.codMat)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedMatiere = val);
                      _loadAbsencesReport();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_selectedClasse != null && _selectedMatiere != null) ...[
            Text("Classe : ${_selectedClasse!.nomClass}    Département : ${_selectedDept?.nomDept ?? ''}"),
            Text("Matière : ${_selectedMatiere!.codMat}"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("CHSM : ${_chsm.toStringAsFixed(0)} heures"),
                Text("Date : ${_formatToday()}"),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text("Nom")),
                          DataColumn(label: Text("Prenom")),
                          DataColumn(label: Text("NHA")),
                        ],
                        rows: _rows
                            .map((r) => DataRow(cells: [
                                  DataCell(Text(r.nom)),
                                  DataCell(Text(r.prenom)),
                                  DataCell(Text(_formatNha(r.nha))),
                                ]))
                            .toList(),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
