import 'package:flutter/material.dart';
import '../SQLite/database_helper.dart';

class ViewSalesScreen extends StatefulWidget {
  const ViewSalesScreen({Key? key}) : super(key: key);

  @override
  State<ViewSalesScreen> createState() => _ViewSalesScreenState();
}

class _ViewSalesScreenState extends State<ViewSalesScreen> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> sales = [];

  // Controladores
  final TextEditingController _commissionController =
  TextEditingController(text: '10');
  final TextEditingController _searchController = TextEditingController();

  double get _commissionPercent =>
      double.tryParse(_commissionController.text) ?? 0.0;
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _loadSales();
    _searchController.addListener(() {
      setState(() => _searchTerm = _searchController.text.trim());
    });
  }

  @override
  void dispose() {
    _commissionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSales() async {
    try {
      final result = await dbHelper.getAllVentas();
      setState(() {
        sales = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar ventas: ${e.toString()}")),
      );
    }
  }

  Future<void> _confirmClearSales() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Reiniciar jornada"),
        content: const Text("¿Seguro que quieres eliminar todas las ventas?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text("Reiniciar"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await dbHelper.deleteAllVentas();
      await _loadSales();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Jornada reiniciada exitosamente")),
      );
    }
  }

  void _showEditDialog(Map<String, dynamic> sale) {
    final nombreController =
    TextEditingController(text: sale['nombreCliente']);
    final numeroController = TextEditingController(
        text: sale['numeroComprado'].toString());
    final precioController =
    TextEditingController(text: sale['precioComprado'].toString());
    final notaController =
    TextEditingController(text: sale['nota'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                TextInputType.numberWithOptions(decimal: true),
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
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              await dbHelper.updateSale(
                sale['idventa'],
                nombreController.text,
                int.tryParse(numeroController.text) ??
                    sale['numeroComprado'],
                double.tryParse(precioController.text) ??
                    sale['precioComprado'],
                notaController.text,
              );
              await _loadSales();
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filtrar ventas por término de búsqueda
    final filteredSales = sales.where((sale) {
      final name =
      (sale['nombreCliente'] ?? '').toString().toLowerCase();
      final number = sale['numeroComprado'].toString();
      final term = _searchTerm.toLowerCase();
      return name.contains(term) || number.contains(term);
    }).toList();

    // Calcular totales
    final totalSales = filteredSales.fold<double>(
        0.0, (sum, sale) => sum + (sale['precioComprado'] as double));
    final totalProfit = totalSales * (_commissionPercent / 100);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ventas Realizadas"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Reiniciar jornada',
            onPressed: _confirmClearSales,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Buscador
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: "Buscar por número o cliente",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Input dinámico de comisión
            Row(
              children: [
                const Text("Comisión (%): "),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _commissionController,
                    keyboardType:
                    TextInputType.numberWithOptions(decimal: true),
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

            // Resumen
            Card(
              color: Colors.blue.shade50,
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total ventas: \$${totalSales.toStringAsFixed(2)}",
                      style:
                      const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Ganancia: \$${totalProfit.toStringAsFixed(2)}",
                      style:
                      const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Lista filtrada
            Expanded(
              child: filteredSales.isEmpty
                  ? const Center(
                child: Text(
                  "No hay ventas para mostrar.",
                  style: TextStyle(fontSize: 18),
                ),
              )
                  : ListView.builder(
                itemCount: filteredSales.length,
                itemBuilder: (context, index) {
                  final sale = filteredSales[index];
                  final price =
                  sale['precioComprado'] as double;
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 6),
                    child: ListTile(
                      title: Text(
                          "Cliente: ${sale['nombreCliente']}"),
                      subtitle: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Número: ${sale['numeroComprado']}  •  \$${price.toStringAsFixed(2)}",
                          ),
                          if ((sale['nota'] ?? '')
                              .isNotEmpty)
                            Padding(
                              padding: const EdgeInsets
                                  .only(top: 4.0),
                              child: Text(
                                "Nota: ${sale['nota']}",
                                style: const TextStyle(
                                  fontStyle:
                                  FontStyle.italic,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize:
                        MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.blue),
                            onPressed: () =>
                                _showEditDialog(sale),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red),
                            onPressed: () async {
                              final confirm =
                              await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text(
                                      "¿Eliminar venta?"),
                                  content:
                                  const Text(
                                      "¿Estás seguro de que quieres eliminar esta venta?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(
                                              ctx)
                                              .pop(
                                              false),
                                      child: const Text(
                                          "Cancelar"),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(
                                              ctx)
                                              .pop(
                                              true),
                                      child: const Text(
                                          "Eliminar"),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm ==
                                  true) {
                                await dbHelper
                                    .deleteSale(
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
    );
  }
}
