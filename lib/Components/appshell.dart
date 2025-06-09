import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Services/theme_manager.dart';
import '../JSON/users.dart';
import '../Views/AddSaleScreen.dart';
import '../Views/viewSalesScreen.dart';
import '../Views/viewContactScreen.dart';
import '../Views/add_contact_screen.dart';
import '../Views/WinnerScreen.dart';
import '../Views/profile.dart';

class AppShell extends StatefulWidget {
  final Users userProfile;
  final int initialIndex;

  const AppShell({
    Key? key,
    required this.userProfile,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _currentIndex;

  final List<Widget> _pages = [
    const ViewSalesScreen(),    // índice 0
    const AddSaleScreen(),      // índice 1
    const ViewContactScreen(),  // índice 2
    const AddContactScreen(),   // índice 3
    const WinnerScreen(),       // índice 4
  ];

  final List<String> _titles = [
    'Visualizar Ventas',
    'Registrar Venta',
    'Clientes',
    'Agregar Cliente',
    'Ver Ganadores',
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        backgroundColor: theme.primary,
        foregroundColor: theme.textOnPrimary,
        actions: [
          // Ícono de perfil
          IconButton(
            icon: const Icon(Icons.account_circle, size: 28),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Profile(profile: widget.userProfile),
              ),
            ),
          ),
          // Toggle Light/Dark
          IconButton(
            icon: Icon(
              theme.isDarkMode ? Icons.wb_sunny : Icons.nights_stay,
            ),
            onPressed: theme.toggleTheme,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: theme.primary,
        unselectedItemColor: theme.textOnPrimary.withOpacity(0.6),
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.show_chart),   label: 'Ventas'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Vender'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt),     label: 'Clientes'),
          BottomNavigationBarItem(icon: Icon(Icons.person_add),   label: 'Nuevo'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Ganadores'),
        ],
      ),
    );
  }
}
