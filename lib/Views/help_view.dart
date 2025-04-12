import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Services/theme_manager.dart';

class HelpView extends StatelessWidget {
  const HelpView({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtener el tema actual desde ThemeManager
    final themeManager = Provider.of<ThemeManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Ayuda",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: themeManager.primaryColor, // Usar color primario desde ThemeManager
        foregroundColor: themeManager.textColor, // Usar color de texto desde ThemeManager
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "¿Cómo usar esta aplicación?",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: themeManager.textColor, // Usar color de texto desde ThemeManager
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit. "
                    "Vestibulum viverra urna et nulla feugiat, ac vulputate augue scelerisque. "
                    "Sed lacinia efficitur risus, eu aliquam mauris. Nullam sit amet felis eu neque "
                    "congue tempus. Integer facilisis justo vel lorem tincidunt, a vehicula lorem placerat. "
                    "Cras aliquet massa in dui tempus, at malesuada ipsum consectetur. Integer sit amet dui nunc. "
                    "Duis vel orci libero. Etiam lacinia purus ac vehicula aliquet.",
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: themeManager.textColor, // Usar color de texto desde ThemeManager
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "¿Tienes problemas con tu cuenta?",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: themeManager.textColor, // Usar color de texto desde ThemeManager
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus non justo lectus. "
                    "Mauris at augue eu nisi ullamcorper vulputate. Fusce mollis nisl quis urna auctor, id suscipit odio "
                    "molestie. Ut pellentesque scelerisque est in lacinia. Integer sed orci tortor. Aliquam erat volutpat.",
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: themeManager.textColor, // Usar color de texto desde ThemeManager
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Si necesitas más ayuda, no dudes en contactarnos.",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: themeManager.textColor, // Usar color de texto desde ThemeManager
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
