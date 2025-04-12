import 'package:flutter/material.dart';
import '../SQLite/database_helper.dart';

class ViewContactScreen extends StatefulWidget {
  const ViewContactScreen({Key? key}) : super(key: key);

  @override
  State<ViewContactScreen> createState() => _ViewContactScreenState();
}

class _ViewContactScreenState extends State<ViewContactScreen> {
  final dbHelper = DatabaseHelper(); // Instancia del helper para la base de datos
  List<Map<String, dynamic>> contacts = []; // Lista de contactos

  @override
  void initState() {
    super.initState();
    _loadContacts(); // Cargar contactos al iniciar la pantalla
  }

  Future<void> _loadContacts() async {
    try {
      final List<Map<String, dynamic>> result = await dbHelper.getAllContacts();
      setState(() {
        contacts = result; // Asigna los contactos recuperados
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar contactos: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contactos"),
      ),
      body: contacts.isEmpty
          ? const Center(
        child: Text(
          "No hay contactos disponibles.",
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
            onTap: () {
              // Aquí puedes navegar a una vista detallada del contacto si lo deseas
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
        title: const Text("Detalles del Contacto"),
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
              "Número de Contacto: ${contact['contactNumber']}",
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}