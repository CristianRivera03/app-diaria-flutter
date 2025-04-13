import 'package:flutter/material.dart';
import 'package:diaria/Views/login.dart';
import 'package:diaria/Views/signup.dart';
import 'package:diaria/Views/theme_settings_page.dart';
import '../Components/button.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Obtener el tema

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.color_lens),
                tooltip: "Personalizar colores",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ThemeSettingsPage(),
                    ),
                  );
                },
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Bienvenid@",
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    Text(
                      "¿Qué quieres hacer?",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6),
                        fontSize: 15,
                      ),
                    ),
                    Expanded(child: Image.asset("assets/imgUno.png")),
                    // botones con el color del tema
                    Button(
                      label: "Iniciar Sesión",
                      press: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      color: theme.primaryColor,
                      textColor: theme.textTheme.bodyLarge?.color,
                    ),
                    Button(
                      label: "Registrarse",
                      press: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpScreen()),
                        );
                      },
                      color: theme.primaryColor,
                      textColor: theme.textTheme.bodyLarge?.color ?? Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
