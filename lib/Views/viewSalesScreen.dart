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

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  // Cargar las ventas desde la base de datos
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
    final numeroController = TextEditingController(text: sale['numeroComprado'].toString());
    final precioController = TextEditingController(text: sale['precioComprado'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Editar Venta"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(labelText: "Nombre del Cliente"),
            ),
            TextField(
              controller: numeroController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Número Comprado"),
            ),
            TextField(
              controller: precioController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Precio Comprado"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              final updatedNombre = nombreController.text;
              final updatedNumero = int.tryParse(numeroController.text) ?? sale['numeroComprado'];
              final updatedPrecio = double.tryParse(precioController.text) ?? sale['precioComprado'];

              await dbHelper.updateSale(sale['idventa'], updatedNombre, updatedNumero, updatedPrecio);
              _loadSales(); // Refrescar lista de ventas
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
    return Scaffold(
      appBar: AppBar(title: const Text("Ventas Realizadas")),
      body: sales.isEmpty
          ? const Center(child: Text("No hay ventas disponibles.", style: TextStyle(fontSize: 18)))
          : ListView.builder(
        itemCount: sales.length,
        itemBuilder: (context, index) {
          final sale = sales[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text("Cliente: ${sale['nombreCliente']}"),

              subtitle: Text("Número: ${sale['numeroComprado']} - \$${sale['precioComprado'].toStringAsFixed(2)}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showEditDialog(sale), // ✅ Botón para editar la venta
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("¿Eliminar venta?"),
                          content: const Text("¿Estás seguro de que quieres eliminar esta venta?"),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text("Cancelar")),
                            TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text("Eliminar")),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await dbHelper.deleteSale(sale['idventa']);
                        _loadSales();
                      }
                    },
                  ),
                ],

              ),
            ),
          );
        },
      ),
    );
  }
}
