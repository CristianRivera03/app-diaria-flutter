import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import '../Services/theme_manager.dart';

class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  Color _primary = Colors.blue;
  Color _background = Colors.white;
  Color _text = Colors.black;

  final List<Map<String, Color>> predefinedPalettes = [
    {
      'primary': Colors.blue,
      'background': Colors.white,
      'text': Colors.black,
    },
    {
      'primary': Colors.pinkAccent,
      'background': const Color(0xFFFFF0F6),
      'text': const Color(0xFF3D1C2C),
    },
    {
      'primary': Colors.green,
      'background': Colors.lightGreen.shade50,
      'text': Colors.black,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Personalizar Colores")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Estilos predefinidos:"),
          ...predefinedPalettes.map((palette) {
            return ListTile(
              title: Text("Estilo ${predefinedPalettes.indexOf(palette) + 1}"),
              leading: CircleAvatar(backgroundColor: palette['primary']),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                themeManager.updateTheme(
                  palette['primary']!,
                  palette['background']!,
                  palette['text']!,
                );
              },
            );
          }),
          const Divider(),
          const Text("Selecciona colores personalizados:"),
          const SizedBox(height: 12),
          _colorBox("Primario", _primary, (c) => setState(() => _primary = c)),
          _colorBox("Fondo", _background, (c) => setState(() => _background = c)),
          _colorBox("Texto", _text, (c) => setState(() => _text = c)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              themeManager.updateTheme(_primary, _background, _text);
              Navigator.pop(context);
            },
            child: const Text("Aplicar"),
          )
        ],
      ),
    );
  }

  Widget _colorBox(String label, Color currentColor, Function(Color) onColorChanged) {
    return ListTile(
      title: Text(label),
      trailing: GestureDetector(
        onTap: () => _showColorDialog(currentColor, onColorChanged),
        child: CircleAvatar(backgroundColor: currentColor),
      ),
    );
  }

  void _showColorDialog(Color currentColor, Function(Color) onColorChanged) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Elige un color"),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: currentColor,
            onColorChanged: onColorChanged,
            enableAlpha: false,
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Listo"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }
}