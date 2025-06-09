import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Services/theme_manager.dart';
import '../Views/viewSalesScreen.dart';
import '../Views/AddSaleScreen.dart';
import '../Views/viewContactScreen.dart';
import '../Views/add_contact_screen.dart';
import '../Views/WinnerScreen.dart';
class FooterNav extends StatelessWidget {
  final int currentIndex;
  const FooterNav({Key? key, required this.currentIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeManager>(context);
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: theme.primaryColor,
      unselectedItemColor: theme.textColor.withOpacity(0.6),
      onTap: (index) {
        if (index == currentIndex) return;
        Widget target;
        switch (index) {
          case 0:
            target = const ViewSalesScreen();
            break;
          case 1:
            target = const AddSaleScreen();
            break;
          case 2:
            target = const ViewContactScreen();
            break;
          case 3:
            target = const AddContactScreen();
            break;
          case 4:
            target = const WinnerScreen();
            break;
          default:
            target = const ViewSalesScreen();
        }
        Navigator.push(   // ← aquí, push en vez de pushReplacement
          context,
          MaterialPageRoute(builder: (_) => target),
        );
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Ventas'),
        BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Vender'),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Clientes'),
        BottomNavigationBarItem(icon: Icon(Icons.person_add), label: 'Nuevo'),
        BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Ganadores'),
      ],
    );
  }
}
