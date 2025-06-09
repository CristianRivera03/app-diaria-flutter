import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../Components/footer_nav.dart';
import '../SQLite/database_helper.dart';

class ViewSalesScreen extends StatefulWidget {
  const ViewSalesScreen({Key? key}) : super(key: key);

  @override
  State<ViewSalesScreen> createState() => _ViewSalesScreenState();
}

class _ViewSalesScreenState extends State<ViewSalesScreen> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> sales = [];

  final TextEditingController _commissionController =
  TextEditingController(text: '10');
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  double get _commissionPercent =>
      double.tryParse(_commissionController.text) ?? 0.0;

  @override
  void initState() {
    super.initState();
    _loadSales();
    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _commissionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSales() async {
    final result = await dbHelper.getAllVentas();
    setState(() => sales = result);
  }

  Future<void> _confirmClearSales() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text("Reiniciar jornada"),
        content: const Text("¿Seguro que quieres eliminar todas las ventas?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text("Reiniciar"),
          ),
        ],
      ),
    );

    if (ok == true) {
      await dbHelper.deleteAllVentas();
      await _loadSales();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Jornada reiniciada exitosamente")),
      );
    }
  }

  Future<void> _exportSales() async {
    if (sales.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No hay ventas para exportar")),
      );
      return;
    }

    final pdf = pw.Document();
    final headers = ['Cliente', 'Número', 'Precio', 'Nota'];
    final data = sales.map((s) {
      final cliente = s['nombreCliente'] ?? '';
      final numero = s['numeroComprado'].toString();
      final precio = (s['precioComprado'] as double).toStringAsFixed(2);
      final nota = s['nota'] ?? '';
      return [cliente, numero, '\$$precio', nota];
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (_) => [
          pw.Header(
            level: 0,
            child: pw.Text('Reporte de Ventas', style: pw.TextStyle(fontSize: 24)),
          ),
          pw.Table.fromTextArray(
            headers: headers,
            data: data,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignment: pw.Alignment.centerLeft,
            cellPadding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Total ventas: \$${data.fold<double>(0, (sum, row) {
                  final p = double.tryParse(row[2].replaceAll('\$', '')) ?? 0;
                  return sum + p;
                }).toStringAsFixed(2)}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                'Ganancia (${_commissionPercent.toStringAsFixed(1)}%): \$${(data.fold<double>(0, (sum, row) {
                  final p = double.tryParse(row[2].replaceAll('\$', '')) ?? 0;
                  return sum + p;
                }) * _commissionPercent / 100).toStringAsFixed(2)}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/ventas_reporte.pdf');
    await file.writeAsBytes(await pdf.save());

    await OpenFile.open(file.path);
  }

  Future<void> _showEditDialog(Map<String, dynamic> sale) async {
    final nombreController =
    TextEditingController(text: sale['nombreCliente']);
    final numeroController =
    TextEditingController(text: sale['numeroComprado'].toString());
    final precioController =
    TextEditingController(text: sale['precioComprado'].toString());
    final notaController =
    TextEditingController(text: sale['nota'] ?? '');

    final updated = await showDialog<bool>(
      context: context,
      builder: (editCtx) => AlertDialog(
        title: const Text("Editar Venta"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration:
                const InputDecoration(labelText: "Nombre del Cliente"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: numeroController,
                keyboardType: TextInputType.number,
                decoration:
                const InputDecoration(labelText: "Número Comprado"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: precioController,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration:
                const InputDecoration(labelText: "Precio Comprado"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: notaController,
                decoration: const InputDecoration(labelText: "Nota"),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(editCtx).pop(false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.of(editCtx).pop(true),
            child: const Text("Guardar"),
          ),
        ],
      ),
    );

    if (updated == true) {
      await dbHelper.updateSale(
        sale['idventa'],
        nombreController.text.trim(),
        int.tryParse(numeroController.text) ?? sale['numeroComprado'],
        double.tryParse(precioController.text) ?? sale['precioComprado'],
        notaController.text.trim(),
      );
      await _loadSales();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = sales.where((s) {
      final name = (s['nombreCliente'] ?? '').toString().toLowerCase();
      final num  = s['numeroComprado'].toString();
      return name.contains(_searchTerm) || num.contains(_searchTerm);
    }).toList();

    final total  = filtered.fold<double>(0, (sum, s) => sum + (s['precioComprado'] as double));
    final profit = total * (_commissionPercent / 100);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ventas Realizadas"),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Exportar ventas a PDF',
            onPressed: _exportSales,
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Reiniciar jornada',
            onPressed: _confirmClearSales,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1) Buscador
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: "Buscar por número o cliente",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 2) Comisión
            Row(
              children: [
                const Text("Comisión (%): "),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _commissionController,
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      hintText: "Ej: 10",
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 3) Resumen
            Card(
              color: Colors.blue.shade50,
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total ventas: \$${total.toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("Ganancia: \$${profit.toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 4) Lista de ventas
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                child: Text("No hay ventas para mostrar.",
                    style: TextStyle(fontSize: 18)),
              )
                  : ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final sale = filtered[i];
                  final price = sale['precioComprado'] as double;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title:
                      Text("Cliente: ${sale['nombreCliente']}"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              "Número: ${sale['numeroComprado']}  •  \$${price.toStringAsFixed(2)}"),
                          if ((sale['nota'] ?? '').isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text("Nota: ${sale['nota']}",
                                  style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 12)),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.blue),
                            onPressed: () => _showEditDialog(sale),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red),
                            onPressed: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (dCtx) => AlertDialog(
                                  title: const Text("¿Eliminar venta?"),
                                  content: const Text(
                                      "¿Estás seguro de eliminar esta venta?"),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.of(dCtx)
                                                .pop(false),
                                        child: const Text("Cancelar")),
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.of(dCtx)
                                                .pop(true),
                                        child: const Text("Eliminar")),
                                  ],
                                ),
                              );
                              if (ok == true) {
                                await dbHelper.deleteSale(
                                    sale['idventa']);
                                await _loadSales();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const FooterNav(currentIndex: 0),
    );
  }
}
