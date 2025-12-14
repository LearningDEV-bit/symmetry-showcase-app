import 'package:flutter/material.dart';

class NewsStateScaffold extends StatelessWidget {
  const NewsStateScaffold({
    super.key,
    required this.title,
    required this.onBookmarksTap,
    required this.body,
    this.leading,
    this.floatingActionButton,
  });

  final String title;
  final VoidCallback onBookmarksTap;
  final Widget body;
  final Widget? leading;

  // permite pasar el botpn + (speed dial) o cualquier FAB

  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {

    // antes tenia un color variable, al desplazar tomaba el color de las noticias
    // no me gustaba el resultado asi que prefiero el fondo blanco y mantener el tema

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: leading,
        title: Text(title, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        actions: [
          GestureDetector(
            onTap: onBookmarksTap,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Icon(Icons.bookmark, color: Colors.black),
            ),
          ),
        ],
      ),
      body: body,


      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
