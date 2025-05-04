import 'package:Himnario/components/scroller.dart';
import 'package:Himnario/db/db.dart';
import 'package:Himnario/helpers/isAndroid.dart';
import 'package:Himnario/helpers/scrollerBuilder.dart';
import 'package:Himnario/main.dart';
import 'package:Himnario/models/tema.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sqflite/sqflite.dart';

import 'package:Himnario/models/himnos.dart';

class FavoritosPage extends StatefulWidget {
  @override
  _FavoritosPageState createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> with RouteAware {
  List<Himno> himnos = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      routeObserver.subscribe(this, ModalRoute.of(context)!);
    });

    fetchData();
  }

  void fetchData() async {
    setState(() => cargando = true);
    himnos = [];

    List<Map<String, dynamic>> data = await DB.rawQuery('''
          SELECT 
            himnos.id, 
            himnos.titulo,
            himnos.transpose,
            himnos.scroll_speed,
            descargados.himno_id as descargado
          FROM himnos 
          JOIN favoritos ON favoritos.himno_id = himnos.id 
          LEFT JOIN descargados ON himnos.id = descargados.himno_id
          ORDER BY himnos.id ASC
        ''');

    for (dynamic himno in data) {
      himnos.add(
        Himno(
          numero: himno['id'],
          titulo: himno['titulo'],
          transpose: himno['transpose'] ?? 0,
          descargado: himno['descargado'] != null,
          autoScrollSpeed: himno['scroll_speed'] ?? 0,
          favorito: true,
        ),
      );
    }

    setState(() => cargando = false);
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
    fetchData();
  }

  Widget materialLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favoritos'),
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
        mensaje: 'No has agregando ningún himno\n a tu lista de favoritos',
      ),
    );
  }

  Widget cupertinoLayout(BuildContext context) {
    final tema = TemaModel.of(context);

    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          backgroundColor: tema.getAccentColor(),
          middle: Text(
            'Favoritos',
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
          mensaje: 'No has agregando ningún himno\n a tu lista de favoritos',
        ));
  }

  @override
  Widget build(BuildContext context) {
    return isAndroid() ? materialLayout(context) : cupertinoLayout(context);
  }
}
