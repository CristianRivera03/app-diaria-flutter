import 'package:flutter/material.dart';
import '../SQLite/database_helper.dart';

class ViewSalesScreen extends StatefulWidget {
  const ViewSalesScreen({Key? key}) : super(key: key);

  @override
  State<ViewSalesScreen> createState() => _ViewSalesScreenState();
}

class _ViewSalesScreenState extends State<ViewSalesScreen> {
  final dbHelper = DatabaseHelper(); // Instancia del helper para la base de datos
  List<Map<String, dynamic>> sales = []; // Lista de ventas

  @override
  void initState() {
    super.initState();
    _loadSales(); // Cargar ventas al iniciar la pantalla
  }

  Future<void> _loadSales() async {
    try {
      final List<Map<String, dynamic>> result = await dbHelper.getAllSales(); // Ajusta según tu base de datos
      setState(() {
        sales = result; // Asigna las ventas recuperadas
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar ventas: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ventas Realizadas"),
      ),
      body: sales.isEmpty
          ? const Center(
        child: Text(
          "No hay ventas disponibles.",
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: sales.length,
        itemBuilder: (context, index) {
          final sale = sales[index];
          return ListTile(
            title: Text("Producto: ${sale['productName']}"),
            subtitle: Text("Total: \$${sale['totalPrice']}"),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("¿Eliminar venta?"),
                    content: const Text("¿Estás seguro de que quieres eliminar esta venta?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text("Cancelar"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text("Eliminar"),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await dbHelper.deleteSale(sale['saleId']);
                  _loadSales(); // Recargar la lista de ventas
                }
              },
            ),
          );
        },
      ),
    );
  }
}