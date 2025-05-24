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

  // Controlador para el input de porcentaje dinámico
  final TextEditingController _commissionController =
  TextEditingController(text: '10');

  double get _commissionPercent =>
      double.tryParse(_commissionController.text) ?? 0.0;

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  @override
  void dispose() {
    _commissionController.dispose();
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

  void _showEditDialog(Map<String, dynamic> sale) {
    final nombreController = TextEditingController(text: sale['nombreCliente']);
    final numeroController =
    TextEditingController(text: sale['numeroComprado'].toString());
    final precioController =
    TextEditingController(text: sale['precioComprado'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Editar Venta"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreController,
              decoration:
              const InputDecoration(labelText: "Nombre del Cliente"),
            ),
            TextField(
              controller: numeroController,
              keyboardType: TextInputType.number,
              decoration:
              const InputDecoration(labelText: "Número Comprado"),
            ),
            TextField(
              controller: precioController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration:
              const InputDecoration(labelText: "Precio Comprado"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          TextButton(
            onPressed: () async {
              final updatedNombre = nombreController.text;
              final updatedNumero =
                  int.tryParse(numeroController.text) ?? sale['numeroComprado'];
              final updatedPrecio = double.tryParse(precioController.text) ??
                  sale['precioComprado'];

              await dbHelper.updateSale(
                sale['idventa'],
                updatedNombre,
                updatedNumero,
                updatedPrecio,
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
    // Calcular el total de todas las ventas
    final double totalSales = sales.fold<double>(
      0.0,
          (sum, sale) => sum + (sale['precioComprado'] as double),
    );
    // Calcular la ganancia sobre el total
    final double totalProfit = totalSales * (_commissionPercent / 100);

    return Scaffold(
      appBar: AppBar(title: const Text("Ventas Realizadas")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input dinámico de porcentaje
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

            // Resumen: total ventas y ganancia
            Card(
              color: Colors.blue.shade50,
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total ventas: \$${totalSales.toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      "Ganancia: \$${totalProfit.toStringAsFixed(2)}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Lista de ventas
            Expanded(
              child: sales.isEmpty
                  ? const Center(
                  child: Text("No hay ventas disponibles.",
                      style: TextStyle(fontSize: 18)))
                  : ListView.builder(
                itemCount: sales.length,
                itemBuilder: (context, index) {
                  final sale = sales[index];
                  final price = sale['precioComprado'] as double;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text("Cliente: ${sale['nombreCliente']}"),
                      subtitle: Text(
                          "Número: ${sale['numeroComprado']}  •  \$${price.toStringAsFixed(2)}"),
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
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("¿Eliminar venta?"),
                                  content: const Text(
                                      "¿Estás seguro de que quieres eliminar esta venta?"),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(false),
                                        child: const Text("Cancelar")),
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(true),
                                        child: const Text("Eliminar")),
                                  ],
                                ),
                              );
                              if (confirm == true) {
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
    );
  }
}
