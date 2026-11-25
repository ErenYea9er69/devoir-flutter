import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'absence.dart';
import 'api_config.dart';
import 'classe.dart';
import 'etudiant.dart';

class ClassStatsItem {
  final Classe classe;
  final int countedStudents;
  final double totalNha;

  ClassStatsItem({
    required this.classe,
    required this.countedStudents,
    required this.totalNha,
  });
}

class MinStudentsMaxAbsencesScreen extends StatefulWidget {
  const MinStudentsMaxAbsencesScreen({super.key});

  @override
  State<MinStudentsMaxAbsencesScreen> createState() =>
      _MinStudentsMaxAbsencesScreenState();
}

class _MinStudentsMaxAbsencesScreenState
    extends State<MinStudentsMaxAbsencesScreen> {
  List<ClassStatsItem> _stats = [];
  ClassStatsItem? _minStudentsClass;
  ClassStatsItem? _maxAbsencesClass;
  bool _isLoading = false;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final cRes = await http.get(Uri.parse("$baseUrl/classes"));
      final eRes = await http.get(Uri.parse("$baseUrl/etudiants"));

      if (cRes.statusCode == 200 && eRes.statusCode == 200 && mounted) {
        final List<dynamic> cData = json.decode(cRes.body);
        final List<dynamic> eData = json.decode(eRes.body);

        final classes = cData.map((e) => Classe.fromMap(e)).toList();
        final students = eData.map((e) => Etudiant.fromMap(e)).toList();

        final Map<int, int> studentCountByClass = {};
        for (final s in students) {
          final codClass = s.classe?.codClass;
          if (codClass != null) {
            studentCountByClass[codClass] =
                (studentCountByClass[codClass] ?? 0) + 1;
          }
        }

        final absenceResponses = await Future.wait(
          students.where((st) => st.nce != null && st.nce!.isNotEmpty).map(
                (st) => http
                    .get(Uri.parse("$baseUrl/absences/etudiant/${st.nce}"))
                    .then((res) => MapEntry(st, res)),
              ),
        );

        final Map<int, double> nhaByClass = {};
        for (final entry in absenceResponses) {
          final codClass = entry.key.classe?.codClass;
          final aRes = entry.value;
          if (codClass == null || aRes.statusCode != 200) continue;

          final List<dynamic> aData = json.decode(aRes.body);
          final sum = aData
              .map((e) => Absence.fromMap(e))
              .fold(0.0, (acc, a) => acc + a.nha);
          nhaByClass[codClass] = (nhaByClass[codClass] ?? 0.0) + sum;
        }

        final list = classes
            .map((c) => ClassStatsItem(
                  classe: c,
                  countedStudents: studentCountByClass[c.codClass] ?? 0,
                  totalNha: nhaByClass[c.codClass] ?? 0.0,
                ))
            .toList();

        ClassStatsItem? minClass;
        ClassStatsItem? maxAbsClass;
        if (list.isNotEmpty) {
          minClass = list.reduce(
            (a, b) => a.countedStudents <= b.countedStudents ? a : b,
          );
          maxAbsClass = list.reduce(
            (a, b) => a.totalNha >= b.totalNha ? a : b,
          );
        }

        if (mounted) {
          setState(() {
            _stats = list;
            _minStudentsClass = minClass;
            _maxAbsencesClass = maxAbsClass;
          });
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _syncAllNbrEtud() async {
    if (_stats.isEmpty) return;
    setState(() => _isUpdating = true);
    try {
      await Future.wait(_stats.map((item) => http.put(
            Uri.parse("$baseUrl/classes/${item.classe.codClass}"),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              "codClass": item.classe.codClass,
              "nomClass": item.classe.nomClass,
              "nbrEtud": item.countedStudents,
              if (item.classe.departement != null)
                "departement": item.classe.departement!.toMap(),
            }),
          )));

      if (!mounted) return;
      await _loadData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("NbrEtud synchronisé pour toutes les classes !")),
      );
    } catch (_) {}
    if (mounted) setState(() => _isUpdating = false);
  }

  String _formatNha(double val) {
    return val == val.roundToDouble() ? val.toInt().toString() : val.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_maxAbsencesClass != null)
                  Text(
                    "Classe max absences : ${_maxAbsencesClass!.classe.nomClass} (${_formatNha(_maxAbsencesClass!.totalNha)} h)",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                const SizedBox(height: 6),
                if (_minStudentsClass != null)
                  Text(
                    "Classe min étudiants (Etudiant) : ${_minStudentsClass!.classe.nomClass} (${_minStudentsClass!.countedStudents} étudiants)",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _isUpdating ? null : _syncAllNbrEtud,
                  child: Text(_isUpdating
                      ? "Synchronisation..."
                      : "Mettre à jour NbrEtud (toutes les classes)"),
                ),
                const Divider(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: _stats.length,
                    itemBuilder: (context, index) {
                      final item = _stats[index];
                      return ListTile(
                        title: Text(item.classe.nomClass),
                        subtitle: Text(
                          "Compté (Etudiant) : ${item.countedStudents} | NbrEtud (Classe) : ${item.classe.nbrEtud ?? 0}",
                        ),
                        trailing: Text("${_formatNha(item.totalNha)} h abs."),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
