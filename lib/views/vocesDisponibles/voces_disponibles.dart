import 'package:Himnario/components/scroller.dart';
import 'package:Himnario/db/db.dart';
import 'package:Himnario/helpers/isAndroid.dart';
import 'package:Himnario/helpers/scrollerBuilder.dart';
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

    List<Map<String, dynamic>> data = await DB.rawQuery('''
      SELECT 
        himnos.id, 
        himnos.titulo,
        favoritos.himno_id as favorito,
        descargados.himno_id as descargado
      FROM himnos 
      LEFT JOIN favoritos ON himnos.id = favoritos.himno_id
      LEFT JOIN descargados ON himnos.id = descargados.himno_id
      WHERE himnos.id IN ${(res.body.replaceFirst('[', '(')).replaceFirst(']', ')')} 
      GROUP BY himnos.id 
      ORDER BY himnos.id ASC
    ''');

    for (dynamic himno in data) {
      himnos.add(Himno(
        numero: himno['id'],
        titulo: himno['titulo'],
        favorito: himno['favorito'] != null,
        descargado: himno['descargado'] != null,
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
        count: himnos.length,
        itemBuilder: scrollerBuilderHimnos(context, himnos),
        scrollerBubbleText: (index) => himnos[index].numero <= 517 ? himnos[index].numero.toString() : himnos[index].titulo[0],
      ),
    );
  }

  Widget cupertinoLayout(BuildContext context) {
    final tema = TemaModel.of(context);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: tema.getAccentColor(),
        middle: Text(
          'Voces Disponibles',
          style: TextStyle(
            color: tema.getAccentColorText(),
            fontFamily: tema.font,
          ),
        ),
      ),
      child: cargando
          ? Center(
              child: CupertinoActivityIndicator(),
            )
          : Scroller(
              count: himnos.length,
              itemBuilder: scrollerBuilderHimnos(context, himnos),
              scrollerBubbleText: (index) => himnos[index].numero <= 517 ? himnos[index].numero.toString() : himnos[index].titulo[0],
              iPhoneX: MediaQuery.of(context).size.width >= 812.0 || MediaQuery.of(context).size.height >= 812.0,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAndroid() ? materialLayout(context) : cupertinoLayout(context);
  }
}
