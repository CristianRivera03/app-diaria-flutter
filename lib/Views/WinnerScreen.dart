import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../SQLite/database_helper.dart';
import '../Components/footer_nav.dart';


class WinnerScreen extends StatefulWidget {
  const WinnerScreen({Key? key}) : super(key: key);

  @override
  State<WinnerScreen> createState() => _WinnerScreenState();
}

class _WinnerScreenState extends State<WinnerScreen> {
  final dbHelper = DatabaseHelper();
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> winners = [];
  String winningNumber = "00";

  @override
  void initState() {
    super.initState();
    _controller.text = "00";
    _searchWinner();
  }

  Future<void> _searchWinner() async {
    if (_controller.text.isEmpty) return;
    try {
      final result = await dbHelper.getWinnersByNumber(_controller.text);
      setState(() {
        winners = result;
        winningNumber = _controller.text;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _exportWinners() async {
    if (winners.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("No hay datos para exportar")));
      return;
    }

    // 1. Crear documento PDF
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Ganadores número $winningNumber',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 16),
              // Cabeceras de tabla
              pw.Table.fromTextArray(
                headers: ['Número', 'Cliente', 'Precio comprado', 'Premio'],
                data: winners.map((win) {
                  final num = win['numeroComprado'].toString();
                  final name = win['nombreCliente'] ?? '';
                  final price = (win['precioComprado'] as double).toStringAsFixed(2);
                  final prize = (win['precioComprado'] * 80).toStringAsFixed(2);
                  return [num, name, '\$$price', '\$$prize'];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
                headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
                cellHeight: 28,
              ),
            ],
          );
        },
      ),
    );

    // 2. Guardar en disco
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/winners_$winningNumber.pdf');
    await file.writeAsBytes(await pdf.save());

    // 3. Abrir automáticamente
    await OpenFile.open(file.path);
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String tempNumber = _controller.text;
        return AlertDialog(
          title: const Text("Ingrese número ganador"),
          content: TextField(
            keyboardType: TextInputType.number,
            maxLength: 2,
            decoration: const InputDecoration(hintText: "Ej: 00"),
            onChanged: (value) => tempNumber = value.padLeft(2, '0'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            TextButton(
              onPressed: () {
                _controller.text = tempNumber;
                Navigator.pop(context);
                _searchWinner();
              },
              child: const Text("Buscar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Número ganador"),
        leading: const BackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _exportWinners,
            tooltip: 'Exportar ganadores a PDF',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Mostrar número ganador + editar
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    winningNumber,
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(icon: const Icon(Icons.edit), onPressed: _showEditDialog),
              ],
            ),
            const SizedBox(height: 20),

            // Lista de ganadores
            Expanded(
              child: winners.isEmpty
                  ? const Center(child: Text("No hay ganadores para este número"))
                  : ListView.builder(
                itemCount: winners.length,
                itemBuilder: (context, index) {
                  final win = winners[index];
                  final prize = win['precioComprado'] * 80;
                  return Card(
                    color: Colors.grey.shade300,
                    child: ListTile(
                      leading: Text(
                        win['numeroComprado'].toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      title: Text(win['nombreCliente'] ?? ''),
                      subtitle: Text(
                        "# comprado a: \$${win['precioComprado'].toStringAsFixed(2)}",
                      ),
                      trailing: Text(
                        "\$${prize.toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const FooterNav(currentIndex: 4),
    );
  }
}
