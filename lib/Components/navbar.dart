import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onLeftTap; // Acción para el botón de izquierdo
  final VoidCallback? onRightTap; // Acción para el botón de derecho

  const CustomAppBar({
    super.key,
    required this.title,
    this.onLeftTap,
    this.onRightTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.white,
      centerTitle: true,
      leading: GestureDetector(
        onTap: onLeftTap, // Usa la función personalizada
        child: Container(
          margin: const EdgeInsets.all(11),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFf7f8f8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: SvgPicture.asset("assets/icons/back.svg"),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: onRightTap, // Usa la función personalizada
          child: Container(
            margin: const EdgeInsets.all(5),
            alignment: Alignment.center,
            width: 30,
            decoration: BoxDecoration(
              color: const Color(0xFFf7f8f8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SvgPicture.asset("assets/icons/help.svg"),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
