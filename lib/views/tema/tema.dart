import 'package:Himnario/components/scroller.dart';
import 'package:Himnario/db/db.dart';
import 'package:Himnario/helpers/isAndroid.dart';
import 'package:Himnario/models/tema.dart';
import 'package:Himnario/views/buscador/buscador.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';

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
  bool cargando = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      routeObserver.subscribe(this, ModalRoute.of(context)!);
    });

    fetchHimnos();
  }

  Future<Null> fetchHimnos() async {
    setState(() => cargando = true);
    himnos = [];

    // Fetching data from database
    List<Map<String, dynamic>> data;
    if (widget.id == 0) {
      data = await DB.rawQuery('select himnos.id, himnos.titulo from himnos where id <= 517 order by himnos.id ASC');
    } else {
      if (widget.subtema) {
        data = await DB.rawQuery(
            'select himnos.id, himnos.titulo from himnos join sub_tema_himnos on sub_tema_himnos.himno_id = himnos.id where sub_tema_himnos.sub_tema_id = ${widget.id} order by himnos.id ASC');
      } else {
        data = await DB.rawQuery(
            'select himnos.id, himnos.titulo from himnos join tema_himnos on himnos.id = tema_himnos.himno_id where tema_himnos.tema_id = ${widget.id} order by himnos.id ASC');
      }
    }

    // Fetching favoritos
    List<Map<String, dynamic>> favoritosQuery = await DB.rawQuery('select * from favoritos');
    Map<int, bool> favoritos = {};
    for (dynamic favorito in favoritosQuery) {
      favoritos[favorito['himno_id']] = true;
    }

    // Fetching descargados
    List<Map<String, dynamic>> descargasQuery = await DB.rawQuery('select * from descargados');
    Map<int, bool> descargas = {};
    for (dynamic descarga in descargasQuery) {
      descargas[descarga['himno_id']] = true;
    }
    for (dynamic himno in data) {
      himnos.add(Himno(
        numero: himno['id'],
        titulo: himno['titulo'],
        descargado: descargas.containsKey(himno['id']),
        favorito: favoritos.containsKey(himno['id']),
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
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 100),
            curve: Curves.easeInOutSine,
            height: cargando ? 4.0 : 0.0,
            child: LinearProgressIndicator(),
          ),
        ),
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
        himnos: himnos,
        cargando: cargando,
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
      child: ScopedModel<TemaModel>(
        model: tema,
        child: Scroller(
          himnos: himnos,
          cargando: cargando,
          iPhoneX: MediaQuery.of(context).size.width >= 812.0 || MediaQuery.of(context).size.height >= 812.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAndroid() ? materialLayout() : cupertinoLayout();
  }
}
