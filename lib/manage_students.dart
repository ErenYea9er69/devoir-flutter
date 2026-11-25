import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'classe.dart';
import 'etudiant.dart';
import 'api_config.dart';

class ManageStudentsScreen extends StatefulWidget {
  const ManageStudentsScreen({super.key});

  @override
  State<ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> {
  List<Classe> _classes = [
    Classe(codClass: 1, nomClass: 'DSI21'),
    Classe(codClass: 2, nomClass: 'DSI22'),
    Classe(codClass: 3, nomClass: 'DSI23'),
    Classe(codClass: 4, nomClass: 'DSI31'),
    Classe(codClass: 5, nomClass: 'DSI33'),
  ];
  Classe? _selectedClasse;
  List<Etudiant> _students = [];
  bool _isLoading = false;
  String get _classesUrl => "$baseUrl/classes";
  String get _etudiantsUrl => "$baseUrl/etudiants";

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
            if (_classes.isNotEmpty) {
              _selectedClasse = _classes.first;
              _fetchStudentsForSelectedClass();
            }
          });
        }
      } else {
        _useDefaultData();
      }
    } catch (e) {
      _useDefaultData();
    }
  }

  void _useDefaultData() {
    if (mounted) {
      setState(() {
        _selectedClasse = _classes.first;
        _loadDummyStudents();
      });
    }
  }

  Future<void> _fetchStudentsForSelectedClass() async {
    if (_selectedClasse == null) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse("$_classesUrl/${_selectedClasse!.codClass}/etudiants"),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _students = data.map((json) => Etudiant.fromMap(json)).toList();
            _isLoading = false;
          });
        }
      } else {
        _loadDummyStudents();
      }
    } catch (e) {
      _loadDummyStudents();
    }
  }

  void _loadDummyStudents() {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (_selectedClasse?.nomClass == 'DSI33') {
        _students = [
          Etudiant(
            id: 1,
            nom: 'Ben Ali',
            prenom: 'Mohamed',
            dateNais: '2001-05-12',
            nbreEtud: 25,
            classe: _selectedClasse,
          ),
          Etudiant(
            id: 2,
            nom: 'Trabelsi',
            prenom: 'Sarra',
            dateNais: '2002-09-20',
            nbreEtud: 25,
            classe: _selectedClasse,
          ),
        ];
      } else if (_selectedClasse?.nomClass == 'DSI31') {
        _students = [
          Etudiant(
            id: 3,
            nom: 'Gharbi',
            prenom: 'Ahmed',
            dateNais: '2001-11-03',
            nbreEtud: 30,
            classe: _selectedClasse,
          ),
        ];
      } else {
        _students = [
          Etudiant(
            id: 4,
            nom: 'Foulen',
            prenom: 'Ben Foulen',
            dateNais: '2002-01-15',
            nbreEtud: 20,
            classe: _selectedClasse,
          ),
        ];
      }
    });
  }

  Future<void> _addStudentDialog() async {
    final nomController = TextEditingController();
    final prenomController = TextEditingController();
    final dateController = TextEditingController(text: '2002-01-01');

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Add Student to ${_selectedClasse?.nomClass}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomController,
                  decoration: const InputDecoration(labelText: 'Nom'),
                ),
                TextField(
                  controller: prenomController,
                  decoration: const InputDecoration(labelText: 'Prénom'),
                ),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(labelText: 'Date Naissance'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nomController.text.isNotEmpty &&
                    prenomController.text.isNotEmpty) {
                  final newStudent = Etudiant(
                    nom: nomController.text,
                    prenom: prenomController.text,
                    dateNais: dateController.text,
                    nbreEtud: 1,
                    classe: _selectedClasse,
                  );

                  try {
                    await http.post(
                      Uri.parse(_etudiantsUrl),
                      headers: {'Content-Type': 'application/json'},
                      body: json.encode(newStudent.toMap()),
                    );
                  } catch (e) {
                    // Ignore offline exception
                  }

                  if (mounted) {
                    setState(() {
                      _students.add(newStudent);
                    });
                  }

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
  void _deleteStudent(int index) async {
    final student = _students[index];
    if (student.id != null) {
      try {
        await http.delete(Uri.parse("$_etudiantsUrl/${student.id}"));
      } catch (e) {
        // Offline delete
      }
    }
    if (mounted) {
      setState(() {
        _students.removeAt(index);
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
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  const Text(
                    "Select Class: ",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButton<Classe>(
                      isExpanded: true,
                      value: _selectedClasse,
                      hint: const Text("Select a class"),
                      items: _classes.map((Classe classe) {
                        return DropdownMenuItem<Classe>(
                          value: classe,
                          child: Text(
                            classe.nomClass,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (Classe? newValue) {
                        setState(() {
                          _selectedClasse = newValue;
                        });
                        _fetchStudentsForSelectedClass();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Students in ${_selectedClasse?.nomClass ?? ''}:",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addStudentDialog,
                icon: const Icon(Icons.add),
                label: const Text("Add Student"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _students.isEmpty
                    ? const Center(
                        child: Text(
                          "No students in this class.",
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _students.length,
                        itemBuilder: (context, index) {
                          final student = _students[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.shade100,
                                child: Text(
                                  student.nom.isNotEmpty
                                      ? student.nom[0].toUpperCase()
                                      : 'S',
                                  style: TextStyle(
                                    color: Colors.blue.shade900,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                "${student.nom} ${student.prenom}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                "Date Naissance: ${student.dateNais}",
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteStudent(index),
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
