import 'package:flutter/material.dart';
import '../SQLite/database_helper.dart';
import 'edit_contact_screen.dart'; // Asegúrate de que esto apunte a la pantalla correcta

class ViewContactScreen extends StatefulWidget {
  const ViewContactScreen({Key? key}) : super(key: key);

  @override
  State<ViewContactScreen> createState() => _ViewContactScreenState();
}

class _ViewContactScreenState extends State<ViewContactScreen> {
  final dbHelper = DatabaseHelper(); // instancia del helper para la base de datos
  List<Map<String, dynamic>> contacts = []; // lista de contactos

  @override
  void initState() {
    super.initState();
    _loadContacts(); // cargar contactos al iniciar la pantalla
  }

  Future<void> _loadContacts() async {
    try {
      final List<Map<String, dynamic>> result = await dbHelper.getAllContacts();
      setState(() {
        contacts = result; // asigna los contactos recuperados
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar clientes: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Clientes"),
      ),
      body: contacts.isEmpty
          ? const Center(
        child: Text(
          "No hay clientes disponibles.",
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return ListTile(
            title: Text(contact['fullName']),
            subtitle: Text(contact['contactNumber']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Botón para eliminar contacto
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text("¿Eliminar cliente?"),
                        content: Text(
                            "¿Estás seguro de que quieres eliminar este cliente?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: Text("Cancelar"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: Text("Eliminar"),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await dbHelper.deleteContact(contact['contactId']);
                      _loadContacts(); // recarga la lista de contactos
                    }
                  },
                ),
                // Botón para editar contacto
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () async {
                    // Navegar a la pantalla de edición y esperar el resultado
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditContactScreen(contact: contact),
                      ),
                    );

                    // Si se ha editado el contacto, recargar la lista de contactos
                    if (updated == true) {
                      _loadContacts(); // recarga la lista después de editar
                    }
                  },
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContactDetailScreen(contact: contact),
                ),
              );
            },
          );
        },
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
    contactNumberController = TextEditingController(text: widget.contact['contactNumber']);
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
        widget.contact['contactId'], // ID del contacto que se va a modificar
        fullNameController.text,
        contactNumberController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cliente actualizado exitosamente")),
      );
      Navigator.pop(context, true); // Regresar a la pantalla anterior y pasar 'true' indicando que se actualizó
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
