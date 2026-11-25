import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'class_mat.dart';
import 'classe.dart';
import 'departement.dart';
import 'etudiant.dart';
import 'matiere.dart';
import 'note.dart';

class StudentNoteRow {
  final Etudiant student;
  double? tp1;
  double? tp2;
  double? ds;
  double? examen;

  StudentNoteRow({
    required this.student,
    this.tp1,
    this.tp2,
    this.ds,
    this.examen,
  });

  bool get hasAnyNote =>
      tp1 != null || tp2 != null || ds != null || examen != null;

  double get moyenne =>
      ((tp1 ?? 0) * 0.1) +
      ((tp2 ?? 0) * 0.1) +
      ((ds ?? 0) * 0.2) +
      ((examen ?? 0) * 0.6);
}

class ClassSubjectNotesScreen extends StatefulWidget {
  const ClassSubjectNotesScreen({super.key});

  @override
  State<ClassSubjectNotesScreen> createState() =>
      _ClassSubjectNotesScreenState();
}

class _ClassSubjectNotesScreenState extends State<ClassSubjectNotesScreen> {
  List<Departement> _departements = [];
  List<Classe> _classes = [];
  List<Matiere> _matieres = [];
  List<StudentNoteRow> _rows = [];

  Departement? _selectedDept;
  Classe? _selectedClasse;
  Matiere? _selectedMatiere;

  double _coef = 2.0;
  bool _isLoading = false;
  bool _isSaving = false;
  int _loadRevision = 0;

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
        await _loadNotesData();
      }
    } catch (_) {}
  }

  Future<void> _loadNotesData() async {
    if (_selectedClasse?.codClass == null || _selectedMatiere == null) {
      setState(() => _rows = []);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final codClass = _selectedClasse!.codClass!;
      final codMat = _selectedMatiere!.codMat;

      final sRes = await http.get(Uri.parse("$baseUrl/etudiants/classe/$codClass"));

      double resolvedCoef =
          (_selectedMatiere!.type ?? '').toUpperCase() == 'TP' ? 1.0 : 2.0;
      try {
        final cmRes = await http.get(
          Uri.parse("$baseUrl/classmats/classe/$codClass/matiere/$codMat"),
        );
        if (cmRes.statusCode == 200 && cmRes.body.isNotEmpty && cmRes.body != "null") {
          final cm = ClassMat.fromMap(json.decode(cmRes.body));
          if (cm.coef != null) resolvedCoef = cm.coef!;
        }
      } catch (_) {}

      final Map<int, Note> notesByStudentId = {};
      try {
        final nRes = await http.get(Uri.parse("$baseUrl/notes/classe/$codClass"));
        if (nRes.statusCode == 200) {
          final List<dynamic> nData = json.decode(nRes.body);
          for (final n in nData.map((e) => Note.fromMap(e))) {
            if (n.matiere?.codMat == codMat && n.etudiant?.id != null) {
              notesByStudentId[n.etudiant!.id!] = n;
            }
          }
        }
      } catch (_) {}

      if (sRes.statusCode == 200 && mounted) {
        final List<dynamic> sData = json.decode(sRes.body);
        final students = sData.map((e) => Etudiant.fromMap(e)).toList();

        setState(() {
          _coef = resolvedCoef;
          _rows = students.map((st) {
            final saved = st.id != null ? notesByStudentId[st.id!] : null;
            return StudentNoteRow(
              student: st,
              tp1: saved?.tp1,
              tp2: saved?.tp2,
              ds: saved?.ds,
              examen: saved?.examen,
            );
          }).toList();
          _loadRevision++;
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveAllNotes() async {
    if (_selectedMatiere == null) return;
    final toSave = _rows.where((r) => r.student.id != null && r.hasAnyNote).toList();
    if (toSave.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saisissez au moins une note.")),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await Future.wait(toSave.map((r) => http.post(
            Uri.parse("$baseUrl/notes"),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              "etudiant": {"id": r.student.id},
              "matiere": {"codMat": _selectedMatiere!.codMat},
              "tp1": r.tp1,
              "tp2": r.tp2,
              "ds": r.ds,
              "examen": r.examen,
            }),
          )));

      if (!mounted) return;
      await _loadNotesData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Notes enregistrées dans la table Note !")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur enregistrement: $e")),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  double get _classAverage {
    final graded = _rows.where((r) => r.hasAnyNote).toList();
    if (graded.isEmpty) return 0.0;
    return graded.fold(0.0, (sum, r) => sum + r.moyenne) / graded.length;
  }

  String _formatToday() {
    final now = DateTime.now();
    final d = now.day.toString().padLeft(2, '0');
    final m = now.month.toString().padLeft(2, '0');
    return "$d-$m-${now.year}";
  }

  Widget _noteInput(
    String keyId,
    double? initial,
    ValueChanged<double?> onUpdate,
  ) {
    return SizedBox(
      width: 62,
      child: TextFormField(
        key: ValueKey("${keyId}_$_loadRevision"),
        initialValue: initial?.toString() ?? '',
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          isDense: true,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        ),
        onChanged: (val) {
          final parsed = double.tryParse(val);
          setState(() => onUpdate(parsed?.clamp(0.0, 20.0)));
        },
      ),
    );
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
                      _loadNotesData();
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
                      _loadNotesData();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_selectedClasse != null && _selectedMatiere != null) ...[
            Text("Classe : ${_selectedClasse!.nomClass}    Département : ${_selectedDept?.nomDept ?? ''}"),
            Text("Matière : ${_selectedMatiere!.codMat}"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Coef : $_coef"),
                Text("Date : ${_formatToday()}"),
              ],
            ),
            const SizedBox(height: 10),
          ],
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 16,
                        columns: const [
                          DataColumn(label: Text("Nom")),
                          DataColumn(label: Text("Prenom")),
                          DataColumn(label: Text("TP1")),
                          DataColumn(label: Text("TP2")),
                          DataColumn(label: Text("DS")),
                          DataColumn(label: Text("Examen")),
                          DataColumn(label: Text("Moyenne")),
                        ],
                        rows: _rows.map((r) {
                          final sid = r.student.id ?? r.student.nce ?? r.student.nom;
                          final cod = _selectedMatiere?.codMat ?? '';
                          return DataRow(cells: [
                            DataCell(Text(r.student.nom)),
                            DataCell(Text(r.student.prenom)),
                            DataCell(_noteInput("${sid}_${cod}_tp1", r.tp1, (v) => r.tp1 = v)),
                            DataCell(_noteInput("${sid}_${cod}_tp2", r.tp2, (v) => r.tp2 = v)),
                            DataCell(_noteInput("${sid}_${cod}_ds", r.ds, (v) => r.ds = v)),
                            DataCell(_noteInput("${sid}_${cod}_ex", r.examen, (v) => r.examen = v)),
                            DataCell(Text(
                              r.hasAnyNote ? r.moyenne.toStringAsFixed(2) : "-",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Moyenne classe : ${_classAverage.toStringAsFixed(2)} / 20",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveAllNotes,
                child: Text(_isSaving ? "Enregistrement..." : "Enregistrer Notes"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
