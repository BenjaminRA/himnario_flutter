import 'package:Himnario/components/corosScroller.dart';
import 'package:Himnario/components/scroller.dart';
import 'package:Himnario/db/db.dart';
import 'package:Himnario/helpers/isAndroid.dart';
import 'package:Himnario/models/tema.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';

import 'package:Himnario/models/himnos.dart';

enum BuscadorType { Himnos, Coros, Todos }

class Buscador extends StatefulWidget {
  final int id;
  final bool subtema;
  final BuscadorType type;

  Buscador({
    required this.id,
    this.subtema = false,
    this.type = BuscadorType.Todos,
  });

  @override
  _BuscadorState createState() => _BuscadorState();
}

class _BuscadorState extends State<Buscador> {
  List<Himno> himnos = [];
  bool cargando = true;
  String path = '';
  Database? db;

  @override
  void initState() {
    super.initState();
    fetchHimnos("");
  }

  Future<Null> fetchHimnos(String query) async {
    setState(() => cargando = true);
    List<Himno> result = [];
    String queryTitulo = '';
    String queryParrafo = '';
    List<String> palabras = query.split(' ');
    for (String palabra in palabras) {
      palabra = palabra.replaceAll('á', 'a');
      palabra = palabra.replaceAll('é', 'e');
      palabra = palabra.replaceAll('í', 'i');
      palabra = palabra.replaceAll('ó', 'o');
      palabra = palabra.replaceAll('ú', 'u');
      if (queryTitulo.isEmpty)
        queryTitulo +=
            "REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(himnos.id || ' ' || himnos.titulo,'á','a'), 'é','e'),'í','i'),'ó','o'),'ú','u') like '%$palabra%'";
      else
        queryTitulo +=
            " and REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(himnos.id || ' ' || himnos.titulo,'á','a'), 'é','e'),'í','i'),'ó','o'),'ú','u') like '%$palabra%'";

      if (queryParrafo.isEmpty)
        queryParrafo += " REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(parrafo,'á','a'), 'é','e'),'í','i'),'ó','o'),'ú','u') like '%$palabra%'";
      else
        queryParrafo += " and REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(parrafo,'á','a'), 'é','e'),'í','i'),'ó','o'),'ú','u') like '%$palabra%'";
    }

    List<Map<String, dynamic>> data = await DB.rawQuery(
        "select himnos.id, himnos.titulo, himnos.transpose from himnos join parrafos on parrafos.himno_id = himnos.id where${widget.type == BuscadorType.Coros ? ' himnos.id > 517 and' : widget.type == BuscadorType.Himnos ? ' himnos.id <= 517 and' : ''} ($queryTitulo or $queryParrafo) group by himnos.id order by himnos.id ASC");

    List<Map<String, dynamic>> favoritosQuery = await DB.rawQuery('select * from favoritos');
    Map<int, bool> favoritos = {};
    for (dynamic favorito in favoritosQuery) {
      favoritos[favorito['himno_id']] = true;
    }
    List<Map<String, dynamic>> descargasQuery = await DB.rawQuery('select * from descargados');
    Map<int, bool> descargas = {};
    for (dynamic descarga in descargasQuery) {
      descargas[descarga['himno_id']] = true;
    }
    for (dynamic himno in data) {
      result.add(Himno(
        numero: himno['id'],
        titulo: himno['titulo'],
        transpose: himno['transpose'] ?? 0,
        descargado: descargas.containsKey(himno['id']),
        favorito: favoritos.containsKey(himno['id']),
      ));
    }
    himnos = result;
    setState(() => cargando = false);
    return null;
  }

  @override
  void dispose() async {
    super.dispose();
  }

  Widget materialLayout(BuildContext context) {
    final tema = TemaModel.of(context);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          onChanged: fetchHimnos,
          style: tema.getScaffoldTextStyle(context).copyWith(
                fontSize: 20.0,
                fontWeight: FontWeight.w500,
              ),
          decoration: InputDecoration(filled: true, fillColor: Theme.of(context).canvasColor),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 100),
            curve: Curves.easeInOutSine,
            height: cargando ? 4.0 : 0.0,
            child: LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryIconTheme.color == Colors.black ? Colors.black : Theme.of(context).primaryColor),
              backgroundColor: Colors.white,
            ),
          ),
        ),
      ),
      body: widget.type == BuscadorType.Himnos
          ? Scroller(
              cargando: cargando,
              himnos: himnos,
              buscador: true,
              mensaje: 'No se han encontrado coincidencias',
            )
          : CorosScroller(
              himnos: himnos,
              buscador: true,
              mensaje: 'No se han encontrado coincidencias',
            ),
    );
  }

  Widget cupertinoLayout(BuildContext context) {
    final TemaModel tema = ScopedModel.of<TemaModel>(context);
    return CupertinoPageScaffold(
      backgroundColor: ScopedModel.of<TemaModel>(context).getScaffoldBackgroundColor(),
      navigationBar: CupertinoNavigationBar(
          backgroundColor: ScopedModel.of<TemaModel>(context).getTabBackgroundColor(),
          middle: CupertinoTextField(
            autofocus: true,
            onChanged: fetchHimnos,
            cursorColor: Colors.black,
            style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                  color: WidgetsBinding.instance.window.platformBrightness == Brightness.dark
                      ? Colors.black
                      : (ScopedModel.of<TemaModel>(context).brightness == Brightness.light ? null : Colors.black),
                  fontFamily: ScopedModel.of<TemaModel>(context).font,
                ),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(50.0), color: Colors.white),
            suffix: cargando
                ? ColorFiltered(
                    colorFilter: ColorFilter.mode(
                        Colors.white, WidgetsBinding.instance.window.platformBrightness == Brightness.dark ? BlendMode.difference : BlendMode.darken),
                    child: Container(margin: EdgeInsets.only(right: 10.0), child: CupertinoActivityIndicator()),
                  )
                : null,
          )),
      child: widget.type == BuscadorType.Himnos
          ? ScopedModel<TemaModel>(
              model: tema,
              child: Scroller(
                cargando: cargando,
                himnos: himnos,
                buscador: true,
                iPhoneX: MediaQuery.of(context).size.width >= 812.0 || MediaQuery.of(context).size.height >= 812.0,
                mensaje: 'No se han encontrado coincidencias',
              ),
            )
          : ScopedModel<TemaModel>(
              model: tema,
              child: CorosScroller(
                himnos: himnos,
                buscador: true,
                iPhoneX: MediaQuery.of(context).size.width >= 812.0 || MediaQuery.of(context).size.height >= 812.0,
                mensaje: 'No se han encontrado coincidencias',
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAndroid() ? materialLayout(context) : cupertinoLayout(context);
  }
}
