import 'package:Himnario/components/corosScroller.dart';
import 'package:Himnario/components/scroller.dart';
import 'package:Himnario/db/db.dart';
import 'package:Himnario/helpers/isAndroid.dart';
import 'package:Himnario/helpers/scrollerBuilder.dart';
import 'package:Himnario/models/tema.dart';
import 'package:Himnario/views/coro/coro.dart';
import 'package:Himnario/views/himno/himno.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';

import 'package:Himnario/models/himnos.dart';

enum BuscadorType { Himnos, Coros, Todos }

class HimnoResult {
  final Himno himno;
  int scoring;

  HimnoResult({
    required this.himno,
    required this.scoring,
  });
}

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
  String _query = '';

  @override
  void initState() {
    super.initState();
    fetchHimnos("");
  }

  Future<Null> fetchHimnos(String query) async {
    setState(() => cargando = true);

    try {
      // Lower case
      query = query.toLowerCase().trim();

      // Eliminamos acentos
      query = query.replaceAll('á', 'a');
      query = query.replaceAll('é', 'e');
      query = query.replaceAll('í', 'i');
      query = query.replaceAll('ó', 'o');
      query = query.replaceAll('ú', 'u');

      Map<int, HimnoResult> result = {};
      String queryTitulo = '';
      String queryParrafo = '';
      List<Map<String, dynamic>> data;

      // Buscamos los que tengan coincidencia 100% con el título
      queryTitulo =
          "REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(himnos.id || ' ' || LOWER(himnos.titulo),'á','a'), 'é','e'),'í','i'),'ó','o'),'ú','u') like '%$query%'";

      data = await DB.rawQuery("""
        SELECT 
          himnos.id, 
          himnos.titulo, 
          himnos.transpose,
          himnos.scroll_speed,
          favoritos.himno_id as favorito,
          descargados.himno_id as descargado
        FROM himnos 
        LEFT JOIN favoritos ON himnos.id = favoritos.himno_id
        LEFT JOIN descargados ON himnos.id = descargados.himno_id
        WHERE ${widget.type == BuscadorType.Coros ? 'himnos.id > 517' : widget.type == BuscadorType.Himnos ? 'himnos.id <= 517' : ''} 
          AND ($queryTitulo) 
        ORDER BY himnos.id ASC
      """);

      for (dynamic himno in data) {
        if (result.containsKey(himno['id'])) {
          result[himno['id']]!.scoring += 5000;
        } else {
          result[himno['id']] = HimnoResult(
            himno: Himno(
              numero: himno['id'],
              titulo: himno['titulo'],
              transpose: himno['transpose'] ?? 0,
              autoScrollSpeed: himno['scroll_speed'] ?? 0,
              descargado: himno['descargado'] == null ? false : true,
              favorito: himno['favorito'] == null ? false : true,
            ),
            scoring: 5000,
          );
        }
      }

      // Buscamos los que tengan coincidencia de palabras en el título
      List<String> palabras = query.split(' ');
      queryTitulo = '';
      for (String palabra in palabras) {
        if (queryTitulo.isEmpty)
          queryTitulo +=
              "REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(himnos.id || ' ' || LOWER(himnos.titulo),'á','a'), 'é','e'),'í','i'),'ó','o'),'ú','u') like '%$palabra%'";
        else
          queryTitulo +=
              " and REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(himnos.id || ' ' || LOWER(himnos.titulo),'á','a'), 'é','e'),'í','i'),'ó','o'),'ú','u') like '%$palabra%'";
      }

      data = await DB.rawQuery("""
        SELECT 
          himnos.id, 
          himnos.titulo, 
          himnos.transpose,
          himnos.scroll_speed,
          favoritos.himno_id as favorito,
          descargados.himno_id as descargado
        FROM himnos 
        LEFT JOIN favoritos ON himnos.id = favoritos.himno_id
        LEFT JOIN descargados ON himnos.id = descargados.himno_id
        WHERE ${widget.type == BuscadorType.Coros ? 'himnos.id > 517' : widget.type == BuscadorType.Himnos ? 'himnos.id <= 517' : ''} 
          AND ($queryTitulo) 
        ORDER BY himnos.id ASC
      """);

      for (dynamic himno in data) {
        int scoring = 0;

        // Revisamos cuantas veces aparece la palabra en el título para asignar el scoring
        for (String palabra in palabras) {
          palabra = palabra.replaceAll(RegExp(r'(á|a)'), '(a|á|Á)');
          palabra = palabra.replaceAll(RegExp(r'(é|e)'), '(e|é|É)');
          palabra = palabra.replaceAll(RegExp(r'(í|i)'), '(i|í|Í)');
          palabra = palabra.replaceAll(RegExp(r'(ó|o)'), '(o|ó|Ó)');
          palabra = palabra.replaceAll(RegExp(r'(ú|u)'), '(u|ú|Ú)');

          final regex = RegExp('$palabra', caseSensitive: false);
          scoring += regex.allMatches(himno['titulo']).length * 250;
        }

        if (result.containsKey(himno['id'])) {
          result[himno['id']]!.scoring += scoring;
        } else {
          result[himno['id']] = HimnoResult(
            himno: Himno(
              numero: himno['id'],
              titulo: himno['titulo'],
              transpose: himno['transpose'] ?? 0,
              autoScrollSpeed: himno['scroll_speed'] ?? 0,
              descargado: himno['descargado'] == null ? false : true,
              favorito: himno['favorito'] == null ? false : true,
            ),
            scoring: scoring,
          );
        }
      }

      // Buscamos los que tengan coincidencia de palabras en el parrafo
      for (String palabra in palabras) {
        if (queryParrafo.isEmpty)
          queryParrafo += " REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LOWER(parrafo),'á','a'), 'é','e'),'í','i'),'ó','o'),'ú','u') like '%$palabra%'";
        else
          queryParrafo +=
              " and REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LOWER(parrafo),'á','a'), 'é','e'),'í','i'),'ó','o'),'ú','u') like '%$palabra%'";
      }

      data = await DB.rawQuery("""
          SELECT 
            himnos.id, 
            himnos.titulo, 
            himnos.transpose,
            himnos.scroll_speed,
            favoritos.himno_id as favorito,
            descargados.himno_id as descargado,
            parrafos.parrafo
          FROM himnos 
          JOIN parrafos ON parrafos.himno_id = himnos.id
          LEFT JOIN favoritos ON himnos.id = favoritos.himno_id
          LEFT JOIN descargados ON himnos.id = descargados.himno_id
          WHERE ${widget.type == BuscadorType.Coros ? 'himnos.id > 517' : widget.type == BuscadorType.Himnos ? 'himnos.id <= 517' : ''} 
            AND ($queryParrafo)
          ORDER BY himnos.id ASC
        """);

      for (dynamic himno in data) {
        int scoring = 0;

        // Revisamos cuantas veces aparece la palabra en el parrafo para asignar el scoring
        for (String palabra in palabras) {
          palabra = palabra.replaceAll(RegExp(r'(á|a)'), '(a|á|Á)');
          palabra = palabra.replaceAll(RegExp(r'(é|e)'), '(e|é|É)');
          palabra = palabra.replaceAll(RegExp(r'(í|i)'), '(i|í|Í)');
          palabra = palabra.replaceAll(RegExp(r'(ó|o)'), '(o|ó|Ó)');
          palabra = palabra.replaceAll(RegExp(r'(ú|u)'), '(u|ú|Ú)');

          final regex = RegExp('$palabra', caseSensitive: false);
          scoring += regex.allMatches(himno['parrafo']).length * 10;
        }

        if (result.containsKey(himno['id'])) {
          result[himno['id']]!.scoring += scoring;
        } else {
          result[himno['id']] = HimnoResult(
            himno: Himno(
              numero: himno['id'],
              titulo: himno['titulo'],
              transpose: himno['transpose'] ?? 0,
              autoScrollSpeed: himno['scroll_speed'] ?? 0,
              descargado: himno['descargado'] == null ? false : true,
              favorito: himno['favorito'] == null ? false : true,
            ),
            scoring: scoring,
          );
        }
      }

      List<HimnoResult> himnosResult = result.values.toList();

      himnosResult.sort((a, b) => b.scoring.compareTo(a.scoring));

      // Para pintar el texto resaltado
      _query = query;
      _query = _query.replaceAll(RegExp(r'(á|a)'), '(a|á|Á)');
      _query = _query.replaceAll(RegExp(r'(é|e)'), '(e|é|É)');
      _query = _query.replaceAll(RegExp(r'(í|i)'), '(i|í|Í)');
      _query = _query.replaceAll(RegExp(r'(ó|o)'), '(o|ó|Ó)');
      _query = _query.replaceAll(RegExp(r'(ú|u)'), '(u|ú|Ú)');

      setState(() {
        himnos = himnosResult.map((item) => item.himno).toList();
        cargando = false;
      });
    } catch (e) {
      print(e);
      setState(() => cargando = true);
    }

    return null;
  }

  @override
  void dispose() async {
    super.dispose();
  }

  Widget highlightedTitle(String title, Color color, String font) {
    final regex = RegExp('(${_query.replaceAll(' ', '|')})', caseSensitive: false);

    List<TextSpan> spans = [];
    int start = 0;

    final matches = regex.allMatches(title);

    for (final match in matches) {
      if (match.start > start) {
        spans.add(TextSpan(
          text: title.substring(start, match.start),
        ));
      }
      spans.add(TextSpan(
        text: match.group(0),
        style: TextStyle(fontWeight: FontWeight.bold),
      ));
      start = match.end;
    }

    if (start < title.length) {
      spans.add(TextSpan(
        text: title.substring(start),
      ));
    }

    if (matches.isEmpty) {
      spans.add(TextSpan(
        children: [
          TextSpan(
            text: ' [en letra]',
            style: TextStyle(fontSize: 12.0, color: color, fontStyle: FontStyle.italic),
          ),
          // WidgetSpan(
          //   child: Icon(
          //     Icons.lyrics,
          //     size: 16.0,
          //     color: color,
          //   ),
          // ),
          // TextSpan(
          //   text: ' 🎶',
          // ),
        ],
      ));
    }

    return Text.rich(
      TextSpan(
        children: spans,
      ),
      softWrap: true,
      textAlign: TextAlign.start,
      style: TextStyle(
        color: color,
        fontFamily: font,
      ),
    );
  }

  Widget materialLayout(BuildContext context) {
    final tema = TemaModel.of(context);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          onChanged: fetchHimnos,
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w500,
            color: tema.getScaffoldTextColor(),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: tema.getScaffoldBackgroundColor(),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: tema.getScaffoldAccentColor(),
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: tema.getScaffoldAccentColor(),
              ),
            ),
          ),
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
      body: Scroller(
        count: himnos.length,
        itemBuilder: (context, index, selected, dragging) {
          return Container(
            color: selected && dragging ? tema.getAccentColor() : tema.getScaffoldBackgroundColor(),
            child: ListTile(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => himnos[index].numero <= 517
                        ? HimnoPage(
                            numero: himnos[index].numero,
                            titulo: himnos[index].titulo,
                          )
                        : CoroPage(
                            numero: himnos[index].numero,
                            titulo: himnos[index].titulo,
                            transpose: himnos[index].transpose,
                            scrollSpeed: himnos[index].autoScrollSpeed,
                          ),
                  ),
                );
                // scrollPosition = 105.0 - 90.0;
              },
              leading: himnos[index].favorito
                  ? Icon(
                      Icons.star,
                      color: selected && dragging ? tema.getAccentColorText() : tema.getScaffoldTextColor(),
                    )
                  : null,
              title: Container(
                width: himnos[index].favorito ? MediaQuery.of(context).size.width - 90 : MediaQuery.of(context).size.width - 50,
                child: highlightedTitle(
                  (himnos[index].numero > 517 ? '' : '${himnos[index].numero} - ') + '${himnos[index].titulo}',
                  selected && dragging ? tema.getAccentColorText() : tema.getScaffoldTextColor(),
                  tema.font,
                ),
              ),
              trailing: himnos[index].descargado
                  ? Icon(
                      Icons.get_app,
                      color: selected && dragging ? tema.getAccentColorText() : tema.getScaffoldTextColor(),
                    )
                  : null,
            ),
          );
        },
        scrollerBubbleText: (index) => himnos[index].numero <= 517 ? himnos[index].numero.toString() : himnos[index].titulo[0],
        buscador: true,
        mensaje: 'No se han encontrado coincidencias',
      ),
    );
  }

  Widget cupertinoLayout(BuildContext context) {
    final TemaModel tema = ScopedModel.of<TemaModel>(context);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: tema.getAccentColor(),
        middle: CupertinoTextField(
          autofocus: true,
          onChanged: fetchHimnos,
          cursorColor: tema.brightness == Brightness.light ? Colors.black : Colors.white,
          style: TextStyle(
            color: tema.brightness == Brightness.light ? Colors.black : Colors.white,
            fontFamily: tema.font,
          ),
          decoration:
              BoxDecoration(borderRadius: BorderRadius.circular(50.0), color: tema.brightness == Brightness.light ? Colors.white : Colors.black),
          suffix: cargando
              ? Container(
                  margin: EdgeInsets.only(right: 10.0),
                  child: CupertinoActivityIndicator(),
                )
              : null,
        ),
      ),
      child: Scroller(
        count: himnos.length,
        itemBuilder: (context, index, selected, dragging) {
          return Container(
            color: selected && dragging ? tema.mainColor : tema.getScaffoldBackgroundColor(),
            height: 55.0,
            child: CupertinoButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (BuildContext context) => himnos[index].numero <= 517
                        ? HimnoPage(
                            numero: himnos[index].numero,
                            titulo: himnos[index].titulo,
                          )
                        : CoroPage(
                            numero: himnos[index].numero,
                            titulo: himnos[index].titulo,
                            transpose: himnos[index].transpose,
                            scrollSpeed: himnos[index].autoScrollSpeed,
                          ),
                  ),
                );
                // scrollPosition = 105.0 - 90.0;
              },
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.center,
                    child: highlightedTitle(
                      (himnos[index].numero > 517 ? '' : '${himnos[index].numero} - ') + '${himnos[index].titulo}',
                      selected && dragging ? tema.getAccentColorText() : tema.getScaffoldTextColor(),
                      tema.font,
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        himnos[index].favorito
                            ? Icon(
                                Icons.star,
                                color: selected && dragging ? tema.getAccentColorText() : tema.getScaffoldTextColor(),
                              )
                            : Container(),
                        himnos[index].descargado
                            ? Icon(
                                Icons.get_app,
                                color: selected && dragging ? tema.getAccentColorText() : tema.getScaffoldTextColor(),
                              )
                            : Container()
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
        scrollerBubbleText: (index) => himnos[index].numero <= 517 ? himnos[index].numero.toString() : himnos[index].titulo[0],
        buscador: true,
        iPhoneX: MediaQuery.of(context).size.width >= 812.0 || MediaQuery.of(context).size.height >= 812.0,
        mensaje: 'No se han encontrado coincidencias',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAndroid() ? materialLayout(context) : cupertinoLayout(context);
  }
}
