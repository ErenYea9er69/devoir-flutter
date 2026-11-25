import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'classe.dart';
import 'api_config.dart';

class ManageGroupsScreen extends StatefulWidget {
  const ManageGroupsScreen({super.key});

  @override
  State<ManageGroupsScreen> createState() => _ManageGroupsScreenState();
}

class _ManageGroupsScreenState extends State<ManageGroupsScreen> {
  List<Classe> _classes = [
    Classe(codClass: 1, nomClass: 'DSI21'),
    Classe(codClass: 2, nomClass: 'DSI22'),
    Classe(codClass: 3, nomClass: 'DSI23'),
    Classe(codClass: 4, nomClass: 'DSI31'),
    Classe(codClass: 5, nomClass: 'DSI33'),
  ];

  String get _classesUrl => "$baseUrl/classes";

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    try {
      final response = await http.get(Uri.parse(_classesUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _classes = data.map((json) => Classe.fromMap(json)).toList();
          });
        }
      }
    } catch (e) {
      // Offline fallback
    }
  }

  void _addClassDialog() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add New Class / Group'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Class Name (e.g. DSI32)'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  final newClasse = Classe(nomClass: controller.text);
                  try {
                    await http.post(
                      Uri.parse(_classesUrl),
                      headers: {'Content-Type': 'application/json'},
                      body: json.encode(newClasse.toMap()),
                    );
                  } catch (e) {
                    // Offline fallback
                  }
                  if (mounted) {
                    setState(() {
                      _classes.add(newClasse);
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

  void _deleteClass(int index) async {
    final item = _classes[index];
    if (item.codClass != null) {
      try {
        await http.delete(Uri.parse("$_classesUrl/${item.codClass}"));
      } catch (e) {
        // Offline
      }
    }
    if (mounted) {
      setState(() {
        _classes.removeAt(index);
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
                "Classes / Groups",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addClassDialog,
                icon: const Icon(Icons.add),
                label: const Text("Add Class"),
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
              itemCount: _classes.length,
              itemBuilder: (context, index) {
                final item = _classes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo.shade100,
                      child: const Icon(
                        Icons.group,
                        color: Colors.indigo,
                      ),
                    ),
                    title: Text(
                      item.nomClass,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text("Code Class: ${item.codClass ?? 'New'}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteClass(index),
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
