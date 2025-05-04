import 'package:Himnario/components/scroller.dart';
import 'package:Himnario/db/db.dart';
import 'package:Himnario/helpers/isAndroid.dart';
import 'package:Himnario/helpers/scrollerBuilder.dart';
import 'package:Himnario/models/tema.dart';
import 'package:Himnario/views/buscador/buscador.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:Himnario/models/himnos.dart';

import '../../main.dart';

class TemaPage extends StatefulWidget {
  final int id;
  final bool subtema;
  final String tema;

  TemaPage({
    required this.id,
    this.subtema = false,
    required this.tema,
  });

  @override
  _TemaPageState createState() => _TemaPageState();
}

class _TemaPageState extends State<TemaPage> with RouteAware {
  List<Himno> himnos = [];
  bool cargando = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      routeObserver.subscribe(this, ModalRoute.of(context)!);
    });

    fetchHimnos();
  }

  Future<Null> fetchHimnos() async {
    // setState(() => cargando = true);
    // himnos = [];

    // Fetching data from database
    List<Map<String, dynamic>> data;
    if (widget.id == 0) {
      data = await DB.rawQuery('''
        SELECT 
          himnos.id, 
          himnos.titulo,
          favoritos.himno_id as favorito,
          descargados.himno_id as descargado
        FROM himnos
        LEFT JOIN favoritos ON himnos.id = favoritos.himno_id
        LEFT JOIN descargados ON himnos.id = descargados.himno_id
        WHERE id <= 517 
        order by himnos.id ASC
      ''');
    } else {
      if (widget.subtema) {
        data = await DB.rawQuery('''
          SELECT 
            himnos.id, 
            himnos.titulo,
            favoritos.himno_id as favorito,
            descargados.himno_id as descargado
          FROM himnos 
          JOIN sub_tema_himnos on sub_tema_himnos.himno_id = himnos.id 
          LEFT JOIN favoritos ON himnos.id = favoritos.himno_id
          LEFT JOIN descargados ON himnos.id = descargados.himno_id
          WHERE sub_tema_himnos.sub_tema_id = ${widget.id} 
          ORDER BY himnos.id ASC''');
      } else {
        data = await DB.rawQuery('''
          SELECT 
            himnos.id, 
            himnos.titulo,
            favoritos.himno_id as favorito,
            descargados.himno_id as descargado
          FROM himnos 
          JOIN tema_himnos on himnos.id = tema_himnos.himno_id 
          LEFT JOIN favoritos ON himnos.id = favoritos.himno_id
          LEFT JOIN descargados ON himnos.id = descargados.himno_id
          WHERE tema_himnos.tema_id = ${widget.id} 
          ORDER BY himnos.id ASC''');
      }
    }

    himnos = [];

    for (dynamic himno in data) {
      himnos.add(Himno(
        numero: himno['id'],
        titulo: himno['titulo'],
        favorito: himno['favorito'] == null ? false : true,
        descargado: himno['descargado'] == null ? false : true,
      ));
    }
    setState(() => cargando = false);
    return null;
  }

  @override
  void dispose() {
    super.dispose();
    routeObserver.unsubscribe(this);
  }

  @override
  void didPopNext() {
    super.didPopNext();
    print('didPopNext');
    fetchHimnos();
  }

  Widget materialLayout() {
    return Scaffold(
      appBar: AppBar(
        title: Tooltip(
          message: widget.tema,
          child: Container(
            width: double.infinity,
            child: Text(
              widget.tema,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        // bottom: PreferredSize(
        //   preferredSize: Size.fromHeight(4.0),
        //   child: AnimatedContainer(
        //     duration: Duration(milliseconds: 100),
        //     curve: Curves.easeInOutSine,
        //     height: cargando ? 4.0 : 0.0,
        //     child: LinearProgressIndicator(),
        //   ),
        // ),
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => Buscador(
                    id: widget.id,
                    subtema: widget.subtema,
                    type: BuscadorType.Himnos,
                  ),
                ),
              );
            },
            icon: Icon(Icons.search),
          ),
        ],
      ),
      body: Scroller(
        count: himnos.length,
        itemBuilder: scrollerBuilderHimnos(context, himnos),
        scrollerBubbleText: (index) => himnos[index].numero <= 517 ? himnos[index].numero.toString() : himnos[index].titulo[0],
      ),
    );
  }

  Widget cupertinoLayout() {
    final TemaModel tema = TemaModel.of(context);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: tema.getAccentColor(),
        middle: Text(
          widget.tema,
          style: TextStyle(
            color: tema.getAccentColorText(),
            fontFamily: tema.font,
          ),
        ),
      ),
      child: Scroller(
        count: himnos.length,
        itemBuilder: scrollerBuilderHimnos(context, himnos),
        scrollerBubbleText: (index) => himnos[index].numero <= 517 ? himnos[index].numero.toString() : himnos[index].titulo[0],
        iPhoneX: MediaQuery.of(context).size.width >= 812.0 || MediaQuery.of(context).size.height >= 812.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAndroid() ? materialLayout() : cupertinoLayout();
  }
}
