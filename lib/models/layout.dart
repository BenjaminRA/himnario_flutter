import 'package:flutter/widgets.dart';

class MainMenuTile {
  Icon icon;
  String title;
  Function onTap;

  MainMenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}

class HimnosListTile {
  String title;
  Widget page;
  bool expanded;
  List<HimnosListTile> subCategorias;

  HimnosListTile({
    required this.title,
    required this.page,
    this.expanded = false,
    this.subCategorias = const [],
  });
}
