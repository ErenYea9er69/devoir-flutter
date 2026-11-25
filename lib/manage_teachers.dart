import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'formation.dart';
import 'api_config.dart';

class ManageTeachersScreen extends StatefulWidget {
  const ManageTeachersScreen({super.key});

  @override
  State<ManageTeachersScreen> createState() => _ManageTeachersScreenState();
}

class _ManageTeachersScreenState extends State<ManageTeachersScreen> {
  List<Formation> _formations = [
    Formation(id: 1, nom: 'Mobile Development (Flutter)', duree: 30),
    Formation(id: 2, nom: 'Web REST APIs (Spring Boot)', duree: 45),
    Formation(id: 3, nom: 'Cloud & DevOps', duree: 20),
  ];

  String get _formationsUrl => "$baseUrl/formations";

  @override
  void initState() {
    super.initState();
    _fetchFormations();
  }

  Future<void> _fetchFormations() async {
    try {
      final response = await http.get(Uri.parse(_formationsUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _formations = data.map((json) => Formation.fromMap(json)).toList();
          });
        }
      }
    } catch (e) {
      // Offline fallback
    }
  }

  void _addFormationDialog() async {
    final nomController = TextEditingController();
    final dureeController = TextEditingController(text: '30');

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Training / Teacher Module'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: dureeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Duration (hours)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nomController.text.isNotEmpty) {
                  final newFormation = Formation(
                    nom: nomController.text,
                    duree: int.tryParse(dureeController.text) ?? 30,
                  );
                  try {
                    await http.post(
                      Uri.parse(_formationsUrl),
                      headers: {'Content-Type': 'application/json'},
                      body: json.encode(newFormation.toMap()),
                    );
                  } catch (e) {
                    // Offline fallback
                  }
                  if (mounted) {
                    setState(() {
                      _formations.add(newFormation);
                    });
                  }
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _deleteFormation(int index) async {
    final item = _formations[index];
    if (item.id != null) {
      try {
        await http.delete(Uri.parse("$_formationsUrl/${item.id}"));
      } catch (e) {
        // Offline
      }
    }
    if (mounted) {
      setState(() {
        _formations.removeAt(index);
      });
    }
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
                "Training / Modules",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addFormationDialog,
                icon: const Icon(Icons.add),
                label: const Text("Add Training"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _formations.length,
              itemBuilder: (context, index) {
                final item = _formations[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple.shade100,
                      child: const Icon(
                        Icons.book,
                        color: Colors.purple,
                      ),
                    ),
                    title: Text(
                      item.nom,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text("Duration: ${item.duree} hours"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteFormation(index),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
