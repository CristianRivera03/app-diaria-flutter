import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../Components/footer_nav.dart';
import '../SQLite/database_helper.dart';
import 'edit_contact_screen.dart'; // Asegúrate de que apunte correctamente

class ViewContactScreen extends StatefulWidget {
  const ViewContactScreen({Key? key}) : super(key: key);

  @override
  State<ViewContactScreen> createState() => _ViewContactScreenState();
}

class _ViewContactScreenState extends State<ViewContactScreen> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> contacts = [];

  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    try {
      final result = await dbHelper.getAllContacts();
      setState(() => contacts = result);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar clientes: $e")),
      );
    }
  }

  Future<void> _exportContacts() async {
    if (contacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No hay clientes para exportar")),
      );
      return;
    }

    // 1. Crea el PDF
    final pdf = pw.Document();
    final headers = ['Nombre Completo', 'Número de Cliente'];
    final data = contacts.map((c) {
      return [
        c['fullName'] ?? '',
        c['contactNumber'] ?? '',
      ];
    }).toList();

    // 2. Construye la página
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (_) => [
        pw.Header(
          level: 0,
          child: pw.Text('Listado de Clientes', style: pw.TextStyle(fontSize: 24)),
        ),
        pw.Table.fromTextArray(
          headers: headers,
          data: data,
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
          cellAlignment: pw.Alignment.centerLeft,
          cellPadding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        ),
      ],
    ));

    // 3. Guarda en disco
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/clientes_reporte.pdf');
    await file.writeAsBytes(await pdf.save());

    // 4. Ábrelo
    await OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = contacts.where((c) {
      final name = (c['fullName'] ?? '').toString().toLowerCase();
      final num = (c['contactNumber'] ?? '').toString().toLowerCase();
      return name.contains(_searchTerm) || num.contains(_searchTerm);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Clientes"),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Exportar clientes a PDF',
            onPressed: _exportContacts,
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
                labelText: "Buscar por nombre o número",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 16),

            // Lista filtrada
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                child: Text(
                  "No hay clientes para mostrar.",
                  style: TextStyle(fontSize: 18),
                ),
              )
                  : ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final contact = filtered[i];
                  return ListTile(
                    title: Text(contact['fullName'] ?? ''),
                    subtitle: Text(contact['contactNumber'] ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (dCtx) => AlertDialog(
                                title: const Text("¿Eliminar cliente?"),
                                content: const Text(
                                    "¿Estás seguro de que quieres eliminar este cliente?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(dCtx).pop(false),
                                    child: const Text("Cancelar"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(dCtx).pop(true),
                                    child: const Text("Eliminar"),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await dbHelper.deleteContact(contact['contactId']);
                              _loadContacts();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            final updated = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditContactScreen(contact: contact),
                              ),
                            );
                            if (updated == true) _loadContacts();
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ContactDetailScreen(contact: contact),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const FooterNav(currentIndex: 2),
    );
  }
}

// Pantalla de detalle (sin cambios)
class ContactDetailScreen extends StatelessWidget {
  final Map<String, dynamic> contact;
  const ContactDetailScreen({Key? key, required this.contact}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detalles del Cliente")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            "Nombre Completo: ${contact['fullName']}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            "Número de Cliente: ${contact['contactNumber']}",
            style: const TextStyle(fontSize: 18),
          ),
        ]),
      ),
    );
  }
}

// Pantalla de edición (sin cambios)
class EditContactScreen extends StatefulWidget {
  final Map<String, dynamic> contact;
  const EditContactScreen({Key? key, required this.contact}) : super(key: key);

  @override
  _EditContactScreenState createState() => _EditContactScreenState();
}

class _EditContactScreenState extends State<EditContactScreen> {
  final dbHelper = DatabaseHelper();
  late TextEditingController fullNameController;
  late TextEditingController contactNumberController;

  @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController(text: widget.contact['fullName']);
    contactNumberController =
        TextEditingController(text: widget.contact['contactNumber']);
  }

  @override
  void dispose() {
    fullNameController.dispose();
    contactNumberController.dispose();
    super.dispose();
  }

  Future<void> _updateContact() async {
    try {
      await dbHelper.updateContact(
        widget.contact['contactId'],
        fullNameController.text,
        contactNumberController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cliente actualizado exitosamente")),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al actualizar cliente: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Cliente")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(children: [
          TextField(
            controller: fullNameController,
            decoration: const InputDecoration(labelText: "Nombre Completo"),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: contactNumberController,
            decoration: const InputDecoration(labelText: "Número de Cliente"),
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _updateContact, child: const Text("Guardar Cambios")),
        ]),
      ),


    );
  }
}
