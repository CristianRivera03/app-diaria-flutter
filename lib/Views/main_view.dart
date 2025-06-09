import 'package:diaria/Views/AddSaleScreen.dart';
import 'package:diaria/Views/profile.dart';
import 'package:diaria/Views/viewContactScreen.dart';
import 'package:diaria/Views/viewSalesScreen.dart';
import 'package:diaria/Views/WinnerScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../JSON/users.dart';
import 'add_contact_screen.dart';
import '../Services/theme_manager.dart';
import '../SQLite/database_helper.dart';
import '../Components/footer_nav.dart';

class MainView extends StatefulWidget {
  final Users userProfile;
  const MainView({Key? key, required this.userProfile}) : super(key: key);

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  double _totalSales = 0.0;

  @override
  void initState() {
    super.initState();
    _loadTotalSales();
  }

  Future<void> _loadTotalSales() async {
    final ventas = await DatabaseHelper().getAllVentas();
    final sum = ventas.fold<double>(
      0,
          (prev, v) => prev + (v['precioComprado'] as double),
    );
    setState(() => _totalSales = sum);
  }

  @override
  Widget build(BuildContext context) {
    // Accedemos a tu ThemeManager
    final theme = Provider.of<ThemeManager>(context);

    return Scaffold(
      // Usamos backgroundColor de tu ThemeManager
      backgroundColor: theme.backgroundColor,

      // ─── HEADER ──────────────────────────────────────────
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.primaryColor, // primaryColor
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Perfil
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.account_circle,
                              size: 32, color: theme.textColor),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    Profile(profile: widget.userProfile),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    Text(
                      'Total ventas realizadas:',
                      style: TextStyle(
                        color: theme.textColor.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 8),
                    Card(
                      color: theme.primaryColor.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                      child: SizedBox(
                        width: double.infinity,
                        height: 80,
                        child: Center(
                          child: Text(
                            '\$${_totalSales.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: theme.textColor,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ─── PRIMERA FILA BOTONES CUADRADOS ────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _SquareButton(
                    icon: Icons.casino,
                    label: 'Agregar venta',
                    color: theme.primaryColor,
                    textColor: theme.textColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AddSaleScreen()),
                      ).then((_) => _loadTotalSales());
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SquareButton(
                    icon: Icons.emoji_events,
                    label: 'Ver ganadores',
                    color: theme.primaryColor,
                    textColor: theme.textColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const WinnerScreen()),
                      ).then((_) => _loadTotalSales());
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ─── BOTONES RECTANGULARES ──────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              children: [
                _FullWidthButton(
                  icon: Icons.show_chart,
                  label: 'Visualizar ventas',
                  color: theme.primaryColor,
                  textColor: theme.textColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ViewSalesScreen()),
                    ).then((_) => _loadTotalSales());
                  },
                ),
                const SizedBox(height: 16),
                _FullWidthButton(
                  icon: Icons.person_add,
                  label: 'Agregar cliente',
                  color: theme.primaryColor,
                  textColor: theme.textColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AddContactScreen()),
                    ).then((_) => _loadTotalSales());
                  },
                ),
                const SizedBox(height: 16),
                _FullWidthButton(
                  icon: Icons.list_alt,
                  label: 'Visualizar clientes',
                  color: theme.primaryColor,
                  textColor: theme.textColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ViewContactScreen()),
                    ).then((_) => _loadTotalSales());
                  },
                ),
              ],
            ),
          ),
        ],
      ),

      // ─── FOOTER NAVEGACIÓN ───────────────────────────────
      bottomNavigationBar: const FooterNav(currentIndex: 0),
    );
  }
}

/// Botón cuadrado icon + texto
class _SquareButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _SquareButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: textColor),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(color: textColor)),
          ],
        ),
      ),
    );
  }
}

/// Botón ancho full-width icon + texto
class _FullWidthButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _FullWidthButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: textColor),
        label: Text(label, style: TextStyle(color: textColor)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onTap,
      ),
    );
  }
}
