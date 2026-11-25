import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'absence.dart';
import 'api_config.dart';
import 'etudiant.dart';
import 'matiere.dart';

class matabs {
  final Matiere mat;
  final double nha;

  matabs({
    required this.mat,
    required this.nha,
  });
}

extension _limitext<T> on List<T> {
  List<T> limit(int n) => length > n ? sublist(0, n) : this;
}

class top3absence extends StatefulWidget {
  const top3absence({super.key});

  @override
  State<top3absence> createState() => _topabsenses();
}

class _topabsenses extends State<top3absence> {
  List<matabs> top3list = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadabs();
  }

  Future<void> loadabs() async {
    setState(() => loading = true);
    try {
      final mres = await http.get(Uri.parse("$baseUrl/matieres"));
      final eres = await http.get(Uri.parse("$baseUrl/etudiants"));

      if (mres.statusCode == 200 && eres.statusCode == 200 && mounted) {
        final List<dynamic> mdata = json.decode(mres.body);
        final List<dynamic> edata = json.decode(eres.body);

        final mats = mdata.map((e) => Matiere.fromMap(e)).toList();
        final etuds = edata.map((e) => Etudiant.fromMap(e)).toList();

        final resps = await Future.wait(
          etuds.where((s) => s.nce != null && s.nce!.isNotEmpty).map(
                (s) =>
                http.get(Uri.parse("$baseUrl/absences/etudiant/${s.nce}")),
          ),
        );

        final Map<String, double> nhamap = {};
        for (final r in resps) {
          if (r.statusCode != 200) continue;
          final List<dynamic> adata = json.decode(r.body);
          for (final a in adata.map((e) => Absence.fromMap(e))) {
            final cod = a.matiere.codMat;
            nhamap[cod] = (nhamap[cod] ?? 0.0) + a.nha;
          }
        }

        final list = mats
            .map((m) =>
            matabs(
              mat: m,
              nha: nhamap[m.codMat] ?? 0.0,
            ))
            .toList()
          ..sort((a, b) => b.nha.compareTo(a.nha));

        if (mounted) {
          setState(() {
            top3list = list.limit(3);
          });
        }
      }
    } catch (_) {}
    if (mounted) setState(() => loading = false);
  }

  String fmtnha(double val) {
    return val == val.roundToDouble() ? val.toInt().toString() : val.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "top 3 absense matirere",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text("Rang")),
                    DataColumn(label: Text("CodMat")),
                    DataColumn(label: Text("IntMat")),
                    DataColumn(label: Text("Total NHA")),
                  ],
                  rows: top3list
                      .asMap()
                      .entries
                      .map((entry) {
                    final rank = entry.key + 1;
                    final item = entry.value;
                    return DataRow(cells: [
                      DataCell(Text("$rank")),
                      DataCell(Text(item.mat.codMat)),
                      DataCell(Text(item.mat.intMat ?? '')),
                      DataCell(Text("${fmtnha(item.nha)} h")),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
