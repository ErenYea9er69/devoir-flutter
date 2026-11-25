import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'matiere.dart';

class ManageMatieresScreen extends StatefulWidget {
  const ManageMatieresScreen({super.key});

  @override
  State<ManageMatieresScreen> createState() => _ManageMatieresScreenState();
}

class _ManageMatieresScreenState extends State<ManageMatieresScreen> {
  List<Matiere> _matieres = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMatieres();
  }

  Future<void> _fetchMatieres() async {
    setState(() => _isLoading = true);
    try {
      final res = await http.get(Uri.parse("$baseUrl/matieres"));
      if (res.statusCode == 200) {
        final List<dynamic> data = json.decode(res.body);
        setState(() {
          _matieres = data.map((e) => Matiere.fromMap(e)).toList();
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur de chargement des matières depuis SQLite: $e";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addMatiere(String codMat, String intMat, String description, String type) async {
    try {
      final body = json.encode({
        "codMat": codMat,
        "intMat": intMat,
        "description": description,
        "type": type,
      });
      final res = await http.post(
        Uri.parse("$baseUrl/matieres"),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        _fetchMatieres();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la création de la matière: $e")),
      );
    }
  }

  Future<void> _updateMatiere(String codMat, String intMat, String description, String type) async {
    try {
      final body = json.encode({
        "codMat": codMat,
        "intMat": intMat,
        "description": description,
        "type": type,
      });
      final res = await http.put(
        Uri.parse("$baseUrl/matieres/$codMat"),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (res.statusCode == 200) {
        _fetchMatieres();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la mise à jour: $e")),
      );
    }
  }

  Future<void> _deleteMatiere(String codMat) async {
    try {
      final res = await http.delete(Uri.parse("$baseUrl/matieres/$codMat"));
      if (res.statusCode == 200) {
        _fetchMatieres();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la suppression: $e")),
      );
    }
  }

  void _showMatiereDialog({Matiere? existingMatiere}) {
    final codMatController = TextEditingController(text: existingMatiere?.codMat ?? "");
    final intMatController = TextEditingController(text: existingMatiere?.intMat ?? "");
    final descController = TextEditingController(text: existingMatiere?.description ?? "");
    String selectedType = existingMatiere?.type ?? "Cours";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(existingMatiere == null ? "Créer une Matière" : "Modifier la Matière"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: codMatController,
                    enabled: existingMatiere == null,
                    decoration: const InputDecoration(labelText: "Code Matière (CodMat)", hintText: "ex: AFCP"),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: intMatController,
                    decoration: const InputDecoration(labelText: "Intitulé (IntMat)", hintText: "ex: Atelier Framework"),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(labelText: "Type (Cours / TP)"),
                    items: const [
                      DropdownMenuItem(value: "Cours", child: Text("Cours")),
                      DropdownMenuItem(value: "TP", child: Text("TP")),
                    ],
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedType = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: "Description"),
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
                    final codMat = codMatController.text.trim();
                    final intMat = intMatController.text.trim();
                    final desc = descController.text.trim();
                    if (codMat.isNotEmpty) {
                      if (existingMatiere == null) {
                        _addMatiere(codMat, intMat, desc, selectedType);
                      } else {
                        _updateMatiere(codMat, intMat, desc, selectedType);
                      }
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white),
                  child: Text(existingMatiere == null ? "Créer" : "Mettre à jour"),
                ),
              ],
            );
          },
        );
      },
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Manage Matieres",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey),
              ),
              ElevatedButton.icon(
                onPressed: () => _showMatiereDialog(),
                icon: const Icon(Icons.add),
                label: const Text("Add Matiere"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              color: Colors.red.shade100,
              child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Card(
                    elevation: 3,
                    child: SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(Colors.blue.shade100),
                        columns: const [
                          DataColumn(label: Text("CodMat", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Intitulé (IntMat)", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Type", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Description", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: _matieres.map((m) {
                          return DataRow(cells: [
                            DataCell(Text(m.codMat, style: const TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text(m.intMat ?? '')),
                            DataCell(Chip(
                              label: Text(m.type ?? 'Cours', style: const TextStyle(color: Colors.white, fontSize: 12)),
                              backgroundColor: (m.type == 'TP') ? Colors.orange.shade700 : Colors.blue.shade700,
                              padding: EdgeInsets.zero,
                            )),
                            DataCell(Text(m.description ?? '')),
                            DataCell(Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.orange),
                                  onPressed: () => _showMatiereDialog(existingMatiere: m),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteMatiere(m.codMat),
                                ),
                              ],
                            )),
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
