import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'classe.dart';
import 'departement.dart';

class moyrow {
  final String nom;
  final String prenom;
  final double moy;

  const moyrow({
    required this.nom,
    required this.prenom,
    required this.moy,
  });
}

class moypage extends StatefulWidget {
  const moypage({super.key});

  @override
  State<moypage> createState() => _moypagestate();
}

class _moypagestate extends State<moypage> {
  List<Departement> deps = [];
  List<Classe> classes = [];
  List<moyrow> rows = [];

  Departement? seldep;
  Classe? selcls;
  bool loading = false;

  static const Map<String, List<moyrow>> datamoy = {
    'DSI21': [
      moyrow(nom: 'ben braem', prenom: 'taieb', moy: 14.5),
      moyrow(nom: 'khedrira', prenom: 'sami', moy: 11.75),
      moyrow(nom: 'bahroune', prenom: 'adem', moy: 15.2),
    ],
    'DSI22': [
      moyrow(nom: 'ben saied', prenom: 'bachir', moy: 13.4),
      moyrow(nom: 'mathlouthi', prenom: 'ayemen', moy: 10.8),
      moyrow(nom: 'labyeth', prenom: 'slimen', moy: 16.1),
    ],
  };

  static const List<moyrow> defmoy = [
    moyrow(nom: 'etudiant 1', prenom: 'prenom 1', moy: 14.2),
    moyrow(nom: 'Etudiant 2', prenom: 'PRENOM 2', moy: 11.8),
  ];

  @override
  void initState() {
    super.initState();
    getdeps();
  }

  Future<void> getdeps() async {
    setState(() => loading = true);
    try {
      final res = await http.get(Uri.parse("$baseUrl/departements"));
      if (res.statusCode == 200 && mounted) {
        final List<dynamic> data = json.decode(res.body);
        setState(() {
          deps = data.map((e) => Departement.fromMap(e)).toList();
          seldep = deps.isNotEmpty ? deps.first : null;
        });
        if (seldep?.codDept != null) {
          await getcls(seldep!.codDept!);
        }
      }
    } catch (_) {}
    if (mounted) setState(() => loading = false);
  }

  Future<void> getcls(int id) async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/classes/dept/$id"));
      if (res.statusCode == 200 && mounted) {
        final List<dynamic> data = json.decode(res.body);
        setState(() {
          classes = data.map((e) => Classe.fromMap(e)).toList();
          selcls = classes.isNotEmpty ? classes.first : null;
        });
        loadmoy();
      }
    } catch (_) {}
  }

  void loadmoy() {
    if (selcls == null) {
      setState(() => rows = []);
      return;
    }
    final cname = selcls!.nomClass;
    setState(() {
      rows = datamoy[cname] ?? defmoy;
    });
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
              const Text("departement : ", style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: DropdownButton<Departement>(
                  isExpanded: true,
                  value: seldep,
                  items: deps
                      .map((d) => DropdownMenuItem(value: d, child: Text(d.nomDept)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => seldep = val);
                      getcls(val.codDept!);
                    }
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Text("classe : ", style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: DropdownButton<Classe>(
                  isExpanded: true,
                  value: selcls,
                  items: classes
                      .map((c) => DropdownMenuItem(value: c, child: Text(c.nomClass)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => selcls = val);
                      loadmoy();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (selcls != null) ...[
            Text(
              "Classe : ${selcls!.nomClass}    Departement : ${seldep?.nomDept ?? ''}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
          ],
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text("Nom")),
                          DataColumn(label: Text("prenom")),
                          DataColumn(label: Text("moy")),
                        ],
                        rows: rows
                            .map((r) => DataRow(cells: [
                                  DataCell(Text(r.nom)),
                                  DataCell(Text(r.prenom)),
                                  DataCell(Text(r.moy.toStringAsFixed(2))),
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
