import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'departement.dart';
import 'classe.dart';
import 'etudiant.dart';
import 'matiere.dart';
import 'absence.dart';

class AbsenceSummaryItem {
  final String codMat;
  final String? type;
  final double totalNha;

  AbsenceSummaryItem({required this.codMat, this.type, required this.totalNha});
}

class ManageAbsencesScreen extends StatefulWidget {
  const ManageAbsencesScreen({super.key});

  @override
  State<ManageAbsencesScreen> createState() => _ManageAbsencesScreenState();
}

class _ManageAbsencesScreenState extends State<ManageAbsencesScreen> {
  List<Departement> _departements = [];
  List<Classe> _classes = [];
  List<Etudiant> _students = [];
  List<Matiere> _matieres = [];
  List<Absence> _absences = [];

  Departement? _selectedDept;
  Classe? _selectedClasse;
  Etudiant? _selectedStudent;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDepartements();
    _fetchMatieres();
  }

  Future<void> _fetchDepartements() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/departements"));
      if (res.statusCode == 200) {
        final List<dynamic> data = json.decode(res.body);
        setState(() {
          _departements = data.map((e) => Departement.fromMap(e)).toList();
          if (_departements.isNotEmpty) {
            _selectedDept = _departements.first;
            _fetchClassesForDept(_selectedDept!.codDept!);
          } else {
            _selectedDept = null;
            _classes = [];
            _selectedClasse = null;
            _students = [];
            _selectedStudent = null;
            _absences = [];
          }
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur de connexion avec le serveur SQLite: $e";
      });
    }
  }

  Future<void> _fetchClassesForDept(int codDept) async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/classes/dept/$codDept"));
      if (res.statusCode == 200) {
        final List<dynamic> data = json.decode(res.body);
        setState(() {
          _classes = data.map((e) => Classe.fromMap(e)).toList();
          _selectedClasse = _classes.isNotEmpty ? _classes.first : null;
          if (_selectedClasse != null) {
            _fetchStudentsForClasse(_selectedClasse!.codClass!);
          } else {
            _students = [];
            _selectedStudent = null;
            _absences = [];
          }
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur lors du chargement des classes depuis SQLite";
      });
    }
  }

  Future<void> _fetchStudentsForClasse(int codClass) async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/etudiants/classe/$codClass"));
      if (res.statusCode == 200) {
        final List<dynamic> data = json.decode(res.body);
        setState(() {
          _students = data.map((e) => Etudiant.fromMap(e)).toList();
          _selectedStudent = _students.isNotEmpty ? _students.first : null;
          if (_selectedStudent != null) {
            _fetchAbsencesForStudent(_selectedStudent!.nce ?? "E1");
          } else {
            _absences = [];
          }
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur lors du chargement des étudiants depuis SQLite";
      });
    }
  }

  Future<void> _fetchMatieres() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/matieres"));
      if (res.statusCode == 200) {
        final List<dynamic> data = json.decode(res.body);
        setState(() {
          _matieres = data.map((e) => Matiere.fromMap(e)).toList();
        });
      }
    } catch (e) {
      // no-op
    }
  }

  Future<void> _fetchAbsencesForStudent(String nce) async {
    setState(() => _isLoading = true);
    try {
      final res = await http.get(Uri.parse("$baseUrl/absences/etudiant/$nce"));
      if (res.statusCode == 200) {
        final List<dynamic> data = json.decode(res.body);
        setState(() {
          _absences = data.map((e) => Absence.fromMap(e)).toList();
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Impossible de récupérer les absences pour $nce";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addAbsence(String dateA, String codMat, double nha) async {
    if (_selectedStudent == null) return;
    try {
      final body = json.encode({
        "etudiant": {"id": _selectedStudent!.id, "nce": _selectedStudent!.nce},
        "matiere": {"codMat": codMat},
        "dateA": dateA,
        "nha": nha
      });
      final res = await http.post(
        Uri.parse("$baseUrl/absences"),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        _fetchAbsencesForStudent(_selectedStudent!.nce ?? "E1");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'ajout d'absence dans SQLite: $e")),
      );
    }
  }

  Future<void> _updateAbsence(int id, String dateA, String codMat, double nha) async {
    try {
      final body = json.encode({
        "id": id,
        "etudiant": {"id": _selectedStudent?.id, "nce": _selectedStudent?.nce},
        "matiere": {"codMat": codMat},
        "dateA": dateA,
        "nha": nha
      });
      final res = await http.put(
        Uri.parse("$baseUrl/absences/$id"),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (res.statusCode == 200) {
        _fetchAbsencesForStudent(_selectedStudent?.nce ?? "E1");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la mise à jour dans SQLite: $e")),
      );
    }
  }

  Future<void> _deleteAbsence(int id) async {
    try {
      final res = await http.delete(Uri.parse("$baseUrl/absences/$id"));
      if (res.statusCode == 200) {
        _fetchAbsencesForStudent(_selectedStudent?.nce ?? "E1");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la suppression dans SQLite: $e")),
      );
    }
  }

  void _showAbsenceDialog({Absence? existingAbsence}) {
    final dateController = TextEditingController(text: existingAbsence?.dateA ?? "");
    final nhaController = TextEditingController(text: existingAbsence != null ? existingAbsence.nha.toString() : "");
    String selectedCodMat = existingAbsence?.matiere.codMat ?? (_matieres.isNotEmpty ? _matieres.first.codMat : "AFCP");

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(existingAbsence == null ? "Saisir une Absence" : "Modifier l'Absence"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: dateController,
                    decoration: const InputDecoration(labelText: "Date Absence (DateA)", hintText: "DD-MM-YYYY"),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCodMat,
                    decoration: const InputDecoration(labelText: "Matière (CodMat)"),
                    items: _matieres
                        .map((m) => DropdownMenuItem(
                            value: m.codMat,
                            child: Text("${m.codMat} (${m.type ?? 'Cours'})")))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedCodMat = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nhaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Nbr d'heures (NHA)"),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Annuler"),
                ),
                ElevatedButton(
                  onPressed: () {
                    final dateA = dateController.text.trim();
                    final nha = double.tryParse(nhaController.text.trim()) ?? 0.0;
                    if (existingAbsence == null) {
                      _addAbsence(dateA, selectedCodMat, nha);
                    } else {
                      _updateAbsence(existingAbsence.id!, dateA, selectedCodMat, nha);
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white),
                  child: Text(existingAbsence == null ? "Ajouter" : "Mettre à jour"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<AbsenceSummaryItem> get _summaryList {
    Map<String, Map<String, dynamic>> totals = {};
    for (var a in _absences) {
      final key = a.matiere.codMat;
      final type = a.matiere.type ?? 'Cours';
      if (!totals.containsKey(key)) {
        totals[key] = {'totalNha': 0.0, 'type': type};
      }
      totals[key]!['totalNha'] = (totals[key]!['totalNha'] as double) + a.nha;
    }
    return totals.entries
        .map((e) => AbsenceSummaryItem(
            codMat: e.key,
            type: e.value['type'] as String?,
            totalNha: e.value['totalNha'] as double))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                color: Colors.red.shade100,
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ),

            // 1. Department, Class, and Student Dropdowns
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.business, color: Colors.blue),
                        const SizedBox(width: 12),
                        const Text("Département: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButton<Departement>(
                            isExpanded: true,
                            value: _selectedDept,
                            items: _departements
                                .map((d) => DropdownMenuItem(value: d, child: Text(d.nomDept)))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedDept = val;
                                  _fetchClassesForDept(val.codDept!);
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        const Icon(Icons.group, color: Colors.blue),
                        const SizedBox(width: 12),
                        const Text("Classe: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButton<Classe>(
                            isExpanded: true,
                            value: _selectedClasse,
                            items: _classes
                                .map((c) => DropdownMenuItem(value: c, child: Text(c.nomClass)))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedClasse = val;
                                  _fetchStudentsForClasse(val.codClass!);
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.blue),
                        const SizedBox(width: 12),
                        const Text("Etudiant: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButton<Etudiant>(
                            isExpanded: true,
                            value: _selectedStudent,
                            items: _students
                                .map((s) => DropdownMenuItem(
                                    value: s, child: Text("${s.nce ?? s.id} - ${s.nom} ${s.prenom}")))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedStudent = val;
                                  _fetchAbsencesForStudent(val.nce ?? "E1");
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Student Info Header Card
            if (_selectedStudent != null)
              Card(
                elevation: 3,
                color: Colors.blue.shade50,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Classe : ${_selectedClasse?.nomClass ?? 'DSI33'}",
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blue)),
                          Text("Département : ${_selectedDept?.nomDept ?? 'TI'}",
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blue)),
                        ],
                      ),
                      const Divider(height: 16),
                      Wrap(
                        spacing: 20,
                        runSpacing: 6,
                        children: [
                          Text("Etudiant : ${_selectedStudent?.nce ?? 'E1'}", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                          Text("Nom : ${_selectedStudent?.nom ?? ''}", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                          Text("Prénom : ${_selectedStudent?.prenom ?? ''}", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // 3. Absence DataTable
            const Text(
              "Liste des Absences",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Card(
                    elevation: 3,
                    child: SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(Colors.blue.shade100),
                        columns: const [
                          DataColumn(label: Text("DateA", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("CodMat", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Type", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("NHA", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: _absences.map((a) {
                          final mType = a.matiere.type ?? 'Cours';
                          return DataRow(cells: [
                            DataCell(Text(a.dateA)),
                            DataCell(Text(a.matiere.codMat, style: const TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (mType == 'TP') ? Colors.orange.shade100 : Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(mType, style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: (mType == 'TP') ? Colors.orange.shade900 : Colors.blue.shade900,
                              )),
                            )),
                            DataCell(Text(a.nha.toString())),
                            DataCell(Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.orange),
                                  onPressed: () => _showAbsenceDialog(existingAbsence: a),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteAbsence(a.id!),
                                ),
                              ],
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
            const SizedBox(height: 30),

            // 4. Summary Table directly under Absence Management
            const Text(
              "Récapitulatif des Absences par Matière",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Card(
              elevation: 3,
              child: SizedBox(
                width: double.infinity,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.blue.shade100),
                  columns: const [
                    DataColumn(label: Text("CodMat", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                    DataColumn(label: Text("Type", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                    DataColumn(label: Text("Total NHA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                  ],
                  rows: _summaryList.map((item) {
                    final mType = item.type ?? 'Cours';
                    return DataRow(cells: [
                      DataCell(Text(item.codMat, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (mType == 'TP') ? Colors.orange.shade100 : Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(mType, style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: (mType == 'TP') ? Colors.orange.shade900 : Colors.blue.shade900,
                        )),
                      )),
                      DataCell(Text("${item.totalNha} h", style: const TextStyle(fontSize: 15))),
                    ]);
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // 5. Courbe / Graphique des Absences par Matière
            const Text(
              "Courbe / Graphique des Absences par Matière",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 220,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: AbsenceChartPainter(_summaryList),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.bar_chart, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          "Axe X: Matières (CodMat + Type) | Axe Y: Total NHA (Heures)",
                          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),

      // Floating Action Button "+" at bottom
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAbsenceDialog(),
        icon: const Icon(Icons.add),
        label: const Text("Ajouter Absence"),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
    );
  }
}

// Custom Painter for Bar Chart
class AbsenceChartPainter extends CustomPainter {
  final List<AbsenceSummaryItem> items;

  AbsenceChartPainter(this.items);

  @override
  void paint(Canvas canvas, Size size) {
    if (items.isEmpty) return;

    final paintAxis = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 2.0;

    final paintBarCours = Paint()
      ..color = Colors.blue.shade600
      ..style = PaintingStyle.fill;

    final paintBarTP = Paint()
      ..color = Colors.orange.shade600
      ..style = PaintingStyle.fill;

    final double margin = 40.0;
    final double graphWidth = size.width - margin * 2;
    final double graphHeight = size.height - margin * 2;

    // Draw X and Y Axes
    canvas.drawLine(Offset(margin, size.height - margin), Offset(size.width - margin, size.height - margin), paintAxis);
    canvas.drawLine(Offset(margin, size.height - margin), Offset(margin, margin), paintAxis);

    // Find max NHA value
    double maxNha = items.map((e) => e.totalNha).fold(0.0, (prev, element) => element > prev ? element : prev);
    if (maxNha == 0) maxNha = 10.0;
    maxNha = maxNha * 1.2;

    final double barWidth = (graphWidth / items.length) * 0.4;
    final double stepX = graphWidth / items.length;

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final double x = margin + (i * stepX) + (stepX / 2);
      final double barHeight = (item.totalNha / maxNha) * graphHeight;
      final double y = size.height - margin - barHeight;

      // Draw Bar (Color code by type)
      final isTP = (item.type == 'TP');
      final Rect barRect = Rect.fromLTWH(x - barWidth / 2, y, barWidth, barHeight);
      canvas.drawRRect(RRect.fromRectAndRadius(barRect, const Radius.circular(6)), isTP ? paintBarTP : paintBarCours);

      // Draw CodMat & Type label on X Axis
      final labelText = "${item.codMat}\n(${item.type ?? 'Cours'})";
      final textPainter = TextPainter(
        text: TextSpan(text: labelText, style: const TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.bold), children: []),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, size.height - margin + 4));

      // Draw Value label above bar
      final valPainter = TextPainter(
        text: TextSpan(text: "${item.totalNha}h", style: TextStyle(color: isTP ? Colors.orange.shade800 : Colors.blue.shade800, fontSize: 12, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      )..layout();
      valPainter.paint(canvas, Offset(x - valPainter.width / 2, y - 18));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
