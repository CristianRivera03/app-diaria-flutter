import 'package:flutter/material.dart';
import '../SQLite/database_helper.dart';
import 'edit_contact_screen.dart'; // Asegúrate de que esto apunte a la pantalla correcta

class ViewContactScreen extends StatefulWidget {
  const ViewContactScreen({Key? key}) : super(key: key);

  @override
  State<ViewContactScreen> createState() => _ViewContactScreenState();
}

class _ViewContactScreenState extends State<ViewContactScreen> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> contacts = [];

  // Controlador y término de búsqueda
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
      setState(() {
        contacts = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar clientes: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filtrar contactos por búsqueda (nombre o número)
    final filteredContacts = contacts.where((c) {
      final name = (c['fullName'] ?? '').toString().toLowerCase();
      final number = (c['contactNumber'] ?? '').toString().toLowerCase();
      return name.contains(_searchTerm) || number.contains(_searchTerm);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Clientes"),
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

            // Lista de contactos (filtrada)
            Expanded(
              child: filteredContacts.isEmpty
                  ? const Center(
                child: Text(
                  "No hay clientes para mostrar.",
                  style: TextStyle(fontSize: 18),
                ),
              )
                  : ListView.builder(
                itemCount: filteredContacts.length,
                itemBuilder: (context, index) {
                  final contact = filteredContacts[index];
                  return ListTile(
                    title: Text(contact['fullName']),
                    subtitle: Text(contact['contactNumber']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Eliminar
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("¿Eliminar cliente?"),
                                content: const Text(
                                    "¿Estás seguro de que quieres eliminar este cliente?"),
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
                              await dbHelper.deleteContact(contact['contactId']);
                              _loadContacts();
                            }
                          },
                        ),
                        // Editar
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            final updated = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditContactScreen(contact: contact),
                              ),
                            );
                            if (updated == true) {
                              _loadContacts();
                            }
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ContactDetailScreen(contact: contact),
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
    );
  }
}

class ContactDetailScreen extends StatelessWidget {
  final Map<String, dynamic> contact;

  const ContactDetailScreen({Key? key, required this.contact}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalles del Cliente"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Nombre Completo: ${contact['fullName']}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Número de Cliente: ${contact['contactNumber']}",
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

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
        SnackBar(content: Text("Error al actualizar cliente: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar cliente"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
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
            ElevatedButton(
              onPressed: _updateContact,
              child: const Text("Guardar Cambios"),
            ),
          ],
        ),
      ),
    );
  }
}
