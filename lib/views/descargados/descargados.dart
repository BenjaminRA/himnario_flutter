import 'package:Himnario/components/scroller.dart';
import 'package:Himnario/db/db.dart';
import 'package:Himnario/helpers/isAndroid.dart';
import 'package:Himnario/main.dart';
import 'package:Himnario/models/tema.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sqflite/sqflite.dart';

import 'package:Himnario/models/himnos.dart';

class DescargadosPage extends StatefulWidget {
  @override
  _DescargadosPageState createState() => _DescargadosPageState();
}

class _DescargadosPageState extends State<DescargadosPage> with RouteAware {
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

    List<Map<String, dynamic>> data =
        await DB.rawQuery('select * from himnos join descargados on descargados.himno_id = himnos.id order by himnos.id ASC');
    List<Map<String, dynamic>> favoritosQuery = await DB.rawQuery('select * from favoritos');

    Map<int, bool> favoritos = {};
    for (dynamic favorito in favoritosQuery) {
      favoritos[favorito['himno_id']] = true;
    }
    for (dynamic himno in data) {
      himnos.add(
        Himno(
          numero: himno['id'],
          titulo: himno['titulo'],
          transpose: himno['transpose'],
          descargado: true,
          favorito: favoritos.containsKey(himno['id']),
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
        title: Text('Himnos Descargados'),
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
        mensaje: 'No has descargado ningún himno\n para escuchar la melodia sin conexión',
      ),
    );
  }

  Widget cupertinoLayout(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: ScopedModel.of<TemaModel>(context).getScaffoldBackgroundColor(),
      navigationBar: CupertinoNavigationBar(
        // actionsForegroundColor: ScopedModel.of<TemaModel>(context).getTabTextColor(),
        backgroundColor: ScopedModel.of<TemaModel>(context).getTabBackgroundColor(),
        middle: Text('Himnos Descargados',
            style: CupertinoTheme.of(context)
                .textTheme
                .textStyle
                .copyWith(color: ScopedModel.of<TemaModel>(context).getTabTextColor(), fontFamily: ScopedModel.of<TemaModel>(context).font)),
      ),
      child: Scroller(
        himnos: himnos,
        cargando: cargando,
        iPhoneX: MediaQuery.of(context).size.width >= 812.0 || MediaQuery.of(context).size.height >= 812.0,
        mensaje: 'No has descargado ningún himno\n para escuchar la melodia sin conexión',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAndroid() ? materialLayout(context) : cupertinoLayout(context);
  }
}
