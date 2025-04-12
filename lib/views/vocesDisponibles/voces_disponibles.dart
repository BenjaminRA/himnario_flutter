import 'package:Himnario/components/scroller.dart';
import 'package:Himnario/db/db.dart';
import 'package:Himnario/helpers/isAndroid.dart';
import 'package:Himnario/models/tema.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:Himnario/models/himnos.dart';

import '../../api/api.dart';

class DisponiblesPage extends StatefulWidget {
  @override
  _DisponiblesPageState createState() => _DisponiblesPageState();
}

class _DisponiblesPageState extends State<DisponiblesPage> {
  List<Himno> himnos = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    setState(() => cargando = true);
    himnos = [];

    http.Response res = await http.get(Uri.parse(VoicesApi.voicesAvailable()));

    List<Map<String, dynamic>> data = await DB.rawQuery(
        "select himnos.id, himnos.titulo from himnos where himnos.id in ${(res.body.replaceFirst('[', '(')).replaceFirst(']', ')')} group by himnos.id order by himnos.id ASC");

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
      himnos.add(Himno(
        numero: himno['id'],
        titulo: himno['titulo'],
        descargado: descargas.containsKey(himno['id']),
        favorito: favoritos.containsKey(himno['id']),
      ));
    }

    setState(() => cargando = false);
  }

  Widget materialLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voces Disponibles'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 100),
            curve: Curves.easeInOutSine,
            height: cargando ? 4.0 : 0.0,
            child: LinearProgressIndicator(),
          ),
        ),
      ),
      body: Scroller(
        himnos: himnos,
        cargando: cargando,
      ),
    );
  }

  Widget cupertinoLayout(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: ScopedModel.of<TemaModel>(context).getScaffoldBackgroundColor(),
      navigationBar: CupertinoNavigationBar(
        // actionsForegroundColor: ScopedModel.of<TemaModel>(context).getTabTextColor(),
        backgroundColor: ScopedModel.of<TemaModel>(context).getTabBackgroundColor(),
        middle: Text('Voces Disponibles',
            style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                  color: ScopedModel.of<TemaModel>(context).getTabTextColor(),
                  fontFamily: ScopedModel.of<TemaModel>(context).font,
                )),
      ),
      child: cargando
          ? Center(
              child: CupertinoActivityIndicator(),
            )
          : Scroller(
              himnos: himnos,
              cargando: cargando,
              iPhoneX: MediaQuery.of(context).size.width >= 812.0 || MediaQuery.of(context).size.height >= 812.0,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAndroid() ? materialLayout(context) : cupertinoLayout(context);
  }
}
