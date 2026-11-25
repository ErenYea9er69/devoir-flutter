import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'classe.dart';
import 'etudiant.dart';

class ClassStudentCount {
  final Classe classe;
  final int countedStudents;

  ClassStudentCount({
    required this.classe,
    required this.countedStudents,
  });
}

class MaxStudentsClassScreen extends StatefulWidget {
  const MaxStudentsClassScreen({super.key});

  @override
  State<MaxStudentsClassScreen> createState() => _MaxStudentsClassScreenState();
}

class _MaxStudentsClassScreenState extends State<MaxStudentsClassScreen> {
  List<ClassStudentCount> _classCounts = [];
  ClassStudentCount? _maxClass;
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

        final Map<int, int> countByClass = {};
        for (final s in students) {
          final codClass = s.classe?.codClass;
          if (codClass != null) {
            countByClass[codClass] = (countByClass[codClass] ?? 0) + 1;
          }
        }

        final list = classes
            .map((c) => ClassStudentCount(
                  classe: c,
                  countedStudents: countByClass[c.codClass] ?? 0,
                ))
            .toList()
          ..sort((a, b) => b.countedStudents.compareTo(a.countedStudents));

        setState(() {
          _classCounts = list;
          _maxClass = list.isNotEmpty ? list.first : null;
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _updateMaxClassNbrEtud() async {
    if (_maxClass == null) return;
    final target = _maxClass!.classe;
    final newNbrEtud = _maxClass!.countedStudents;

    setState(() => _isUpdating = true);
    try {
      final body = json.encode({
        "codClass": target.codClass,
        "nomClass": target.nomClass,
        "nbrEtud": newNbrEtud,
        if (target.departement != null) "departement": target.departement!.toMap(),
      });

      final res = await http.put(
        Uri.parse("$baseUrl/classes/${target.codClass}"),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (!mounted) return;
      if (res.statusCode == 200 || res.statusCode == 201) {
        await _loadData();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("NbrEtud mis à jour : $newNbrEtud")),
        );
      }
    } catch (_) {}
    if (mounted) setState(() => _isUpdating = false);
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
                if (_maxClass != null) ...[
                  Text(
                    "Classe max étudiants : ${_maxClass!.classe.nomClass}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text("Nombre d'étudiants (Etudiant) : ${_maxClass!.countedStudents}"),
                  Text("NbrEtud actuel (Classe) : ${_maxClass!.classe.nbrEtud ?? 0}"),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _isUpdating ? null : _updateMaxClassNbrEtud,
                    child: Text(_isUpdating ? "Mise à jour..." : "Mettre à jour NbrEtud"),
                  ),
                  const Divider(height: 24),
                ],
                Expanded(
                  child: ListView.builder(
                    itemCount: _classCounts.length,
                    itemBuilder: (context, index) {
                      final item = _classCounts[index];
                      return ListTile(
                        title: Text(item.classe.nomClass),
                        subtitle: Text("NbrEtud (Classe) : ${item.classe.nbrEtud ?? 0}"),
                        trailing: Text("${item.countedStudents} étudiants"),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
