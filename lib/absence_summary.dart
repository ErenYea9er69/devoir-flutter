import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class AbsenceSummaryItem {
  final String codMat;
  final double totalNha;

  AbsenceSummaryItem({required this.codMat, required this.totalNha});

  factory AbsenceSummaryItem.fromMap(Map<String, dynamic> map) {
    return AbsenceSummaryItem(
      codMat: map['codMat'] ?? '',
      totalNha: (map['totalNha'] is num) ? (map['totalNha'] as num).toDouble() : 0.0,
    );
  }
}

class AbsenceSummaryScreen extends StatefulWidget {
  final String nce;
  final String nom;
  final String prenom;
  final String classe;
  final String departement;

  const AbsenceSummaryScreen({
    super.key,
    this.nce = "E1",
    this.nom = "Ben Foulen1",
    this.prenom = "Foulen1",
    this.classe = "DSI33",
    this.departement = "TI",
  });

  @override
  State<AbsenceSummaryScreen> createState() => _AbsenceSummaryScreenState();
}

class _AbsenceSummaryScreenState extends State<AbsenceSummaryScreen> {
  List<AbsenceSummaryItem> _summaryList = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSummary();
  }

  Future<void> _fetchSummary() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final res = await http.get(Uri.parse("$baseUrl/absences/summary/${widget.nce}"));
      if (res.statusCode == 200) {
        final List<dynamic> data = json.decode(res.body);
        setState(() {
          _summaryList = data.map((e) => AbsenceSummaryItem.fromMap(e)).toList();
        });
      } else {
        setState(() {
          _errorMessage = "Erreur serveur HTTP ${res.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Impossible de se connecter au backend SQLite: $e";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bilan & Courbe (SQLite Direct)"),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
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

            // Header Display
            Card(
              elevation: 4,
              color: Colors.blue.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Classe : ${widget.classe}",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                        Text("Département : ${widget.departement}",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                      ],
                    ),
                    const Divider(height: 20),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        Text("Etudiant : ${widget.nce}", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        Text("Nom : ${widget.nom}", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        Text("Prénom : ${widget.prenom}", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Summary Table from SQLite
            const Text(
              "Récapitulatif des Absences par Matière",
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
                          DataColumn(label: Text("CodMat", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                          DataColumn(label: Text("Total NHA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                        ],
                        rows: _summaryList.map((item) {
                          return DataRow(cells: [
                            DataCell(Text(item.codMat, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                            DataCell(Text(item.totalNha.toString(), style: const TextStyle(fontSize: 15))),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
            const SizedBox(height: 30),

            // Absence Chart
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
                          "Axe X: Matières (CodMat) | Axe Y: Total NHA (Heures)",
                          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Painter for Bar Chart representing total absences per subject
class AbsenceChartPainter extends CustomPainter {
  final List<AbsenceSummaryItem> items;

  AbsenceChartPainter(this.items);

  @override
  void paint(Canvas canvas, Size size) {
    if (items.isEmpty) return;

    final paintAxis = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 2.0;

    final paintBar = Paint()
      ..color = Colors.blue.shade600
      ..style = PaintingStyle.fill;

    final paintLine = Paint()
      ..color = Colors.orangeAccent
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final paintDot = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.fill;

    final double margin = 40.0;
    final double graphWidth = size.width - margin * 2;
    final double graphHeight = size.height - margin * 2;

    // Draw X and Y Axes
    canvas.drawLine(Offset(margin, size.height - margin), Offset(size.width - margin, size.height - margin), paintAxis);
    canvas.drawLine(Offset(margin, size.height - margin), Offset(margin, margin), paintAxis);

    // Find max NHA value for scaling
    double maxNha = items.map((e) => e.totalNha).fold(0.0, (prev, element) => element > prev ? element : prev);
    if (maxNha == 0) maxNha = 10.0;
    maxNha = maxNha * 1.2;

    final double barWidth = (graphWidth / items.length) * 0.4;
    final double stepX = graphWidth / items.length;

    final Path linePath = Path();
    List<Offset> points = [];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final double x = margin + (i * stepX) + (stepX / 2);
      final double barHeight = (item.totalNha / maxNha) * graphHeight;
      final double y = size.height - margin - barHeight;

      // Draw Bar
      final Rect barRect = Rect.fromLTWH(x - barWidth / 2, y, barWidth, barHeight);
      canvas.drawRRect(RRect.fromRectAndRadius(barRect, const Radius.circular(6)), paintBar);

      // Save point for Line Graph
      final Offset point = Offset(x, y);
      points.add(point);
      if (i == 0) {
        linePath.moveTo(point.dx, point.dy);
      } else {
        linePath.lineTo(point.dx, point.dy);
      }

      // Draw CodMat label on X Axis
      final textPainter = TextPainter(
        text: TextSpan(text: item.codMat, style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, size.height - margin + 6));

      // Draw Value label above bar
      final valPainter = TextPainter(
        text: TextSpan(text: "${item.totalNha}h", style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      )..layout();
      valPainter.paint(canvas, Offset(x - valPainter.width / 2, y - 18));
    }

    // Draw connecting line graph
    if (points.length > 1) {
      canvas.drawPath(linePath, paintLine);
    }
    for (final pt in points) {
      canvas.drawCircle(pt, 5, paintDot);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
