import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:Himnario/components/pageRoute.dart';
import 'package:Himnario/db/db.dart';
import 'package:Himnario/helpers/isAndroid.dart';
import 'package:Himnario/helpers/showSimpleDialog.dart';
import 'package:Himnario/main.dart';
import 'package:Himnario/models/categorias.dart';
import 'package:Himnario/models/himnos.dart';
import 'package:Himnario/models/layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:launch_app_store/launch_app_store.dart';
import 'package:http/http.dart' as http;

import 'package:Himnario/views/ajustes/ajustes.dart';
import 'package:Himnario/views/buscador/buscador.dart';
import 'package:Himnario/views/descargados/descargados.dart';
import 'package:Himnario/views/favoritos/favoritos.dart';
import 'package:Himnario/views/main/corosTab.dart';
import 'package:Himnario/views/main/himnosTab.dart';
import 'package:Himnario/views/quickBuscador/quickBuscador.dart';
import 'package:Himnario/views/vocesDisponibles/voces_disponibles.dart';

import 'package:Himnario/api/api.dart';
import 'package:Himnario/models/tema.dart';

class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with RouteAware {
  List<Categoria> categorias = [];
  List<Himno> coros = [];
  List<bool> expanded = <bool>[false, false, false, false, false, false];

  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  late SharedPreferences prefs;
  int currentPage = 0;
  bool cargando = false;

  // Android specific
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      routeObserver.subscribe(this, ModalRoute.of(context)!);
    });

    SharedPreferences.getInstance().then((value) {
      prefs = value;
      initDB();
    });
  }

  Future<void> getAnuncios(SharedPreferences prefs) async {
    http.Response request = await http.get(Uri.parse(DatabaseApi.getAnuncios()));
    Map<String, dynamic> json = jsonDecode(request.body);
    List<String>? anuncios = prefs.getStringList('anuncios');

    if (anuncios != null) {
      for (dynamic anuncio in json['anuncios']) {
        if (!anuncios.contains(anuncio['id'].toString())) {
          await showSimpleDialog(
            context,
            title: anuncio['titulo'],
            content: Text(anuncio['contenido']),
            cancel: "No volver a mostrar",
            onCancel: () => anuncios.add(anuncio['id'].toString()),
            confirm: "Cerrar",
          );
        }
      }

      prefs.setStringList('anuncios', anuncios);
    }
  }

  Future<Null> checkUpdates(SharedPreferences prefs) async {
    try {
      // Checking if we have internet connection
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');

        String? date = prefs.getString('latest');
        http.Response res = await http.post(Uri.parse(DatabaseApi.checkUpdates()),
            headers: {'Content-Type': 'application/json'},
            body: utf8.encode(json.encode({'latest': date != null ? date : '2018-08-19 05:01:46.447 +00:00'})));
        List<dynamic> latest = jsonDecode(res.body);

        // Compare latest server update date with local update date
        if (latest.isNotEmpty) if (date == null || date != latest[0]['updatedAt']) {
          if (isAndroid()) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: <Widget>[
                    Icon(
                      Icons.get_app,
                      color: Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.black,
                    ),
                    SizedBox(
                      width: 15.0,
                    ),
                    Text(
                      'Actualizando Base de Datos',
                      style: TextStyle(
                        color: TemaModel.of(context).getAccentColorText(),
                      ),
                    )
                  ],
                ),
                action: SnackBarAction(
                  label: 'Ok',
                  textColor: Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.black,
                  onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                ),
              ),
            );
          }

          setState(() => cargando = true);
          print('descargando');
          http.Response request = await http.get(Uri.parse(DatabaseApi.getDb()));

          // Favoritos
          List<int> favoritos = [];
          // Descargados
          List<List<int>> descargados = [];
          // transpose
          List<Himno> transposedHImnos = [];

          await DB.execute('CREATE TABLE IF NOT EXISTS favoritos(himno_id int, FOREIGN KEY (himno_id) REFERENCES himnos(id))');
          await DB.execute('CREATE TABLE IF NOT EXISTS descargados(himno_id int, duracion int, FOREIGN KEY (himno_id) REFERENCES himnos(id))');

          for (Map<String, dynamic> favorito in (await DB.rawQuery('select * from favoritos'))) {
            favoritos.add(favorito['himno_id']);
          }
          for (Map<String, dynamic> descargado in (await DB.rawQuery('select * from descargados'))) {
            descargados.add([descargado['himno_id'], descargado['duracion']]);
          }
          transposedHImnos = Himno.fromJson((await DB.rawQuery('select * from himnos where transpose != 0')));

          File(await DB.getPath()).deleteSync();
          File(await DB.getPath()).writeAsBytesSync(request.bodyBytes);

          await DB.execute('CREATE TABLE IF NOT EXISTS favoritos(himno_id int, FOREIGN KEY (himno_id) REFERENCES himnos(id))');
          await DB.execute('CREATE TABLE IF NOT EXISTS descargados(himno_id int, duracion int, FOREIGN KEY (himno_id) REFERENCES himnos(id))');
          for (int favorito in favoritos) await DB.rawInsert('insert into favoritos values ($favorito)');
          for (List<int> descargado in descargados) await DB.rawInsert('insert into descargados values (${descargado[0]}, ${descargado[1]})');
          for (Himno himno in transposedHImnos) await DB.rawQuery('update himnos set transpose = ${himno.transpose} where id = ${himno.numero}');

          prefs.setString('latest', latest[0]['updatedAt']);

          if (isAndroid()) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: <Widget>[
                    Icon(
                      Icons.done,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 15.0,
                    ),
                    Text(
                      'Base de Datos Actualizada',
                      style: TextStyle(
                        color: TemaModel.of(context).getAccentColorText(),
                      ),
                    )
                  ],
                ),
                backgroundColor: Colors.green,
                action: SnackBarAction(
                  label: 'Ok',
                  textColor: Colors.white,
                  onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                ),
              ),
            );
          }

          fetchCategorias();
        }
        setState(() => cargando = false);
        print('termino de actualizar');
        return null;
      }
    } catch (e) {
      setState(() => cargando = false);
      print('not connected');
      print(e);
      return null;
    }
  }

  Future<Null> initDB() async {
    await DB.init();
    await fetchCategorias();

    getAnuncios(prefs);
    checkUpdates(prefs);
    return null;
  }

  Future<Null> fetchCategorias([bool refresh = true]) async {
    List<Map<String, dynamic>> temas = await DB.rawQuery('select * from temas');
    categorias = Categoria.fromJson(temas);

    for (Categoria categoria in categorias) {
      List<Map<String, dynamic>> subTemas = await DB.rawQuery('select * from sub_temas where tema_id = ${categoria.id}');
      for (var x in subTemas) {
        categoria.subCategorias.add(SubCategoria(id: x['id'], subCategoria: x['sub_tema'], categoriaId: x['tema_id']));
      }
    }

    List<Map<String, dynamic>> corosQuery = await DB.rawQuery('select * from himnos where id > 517 order by titulo');
    coros = Himno.fromJson(corosQuery);
    List<Map<String, dynamic>> favoritosQuery = await DB.rawQuery('select * from favoritos where himno_id > 517');
    List<dynamic> favoritosList = favoritosQuery.map((f) => f['himno_id']).toList();
    for (Himno coro in coros) {
      coro.favorito = favoritosList.contains(coro.numero);
    }

    setState(() {});

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
    fetchCategorias();
  }

  List<MainMenuTile> mainMenuTiles(BuildContext context) {
    final tema = TemaModel.of(context);

    return [
      MainMenuTile(
        icon: Icon(Icons.favorite),
        title: "Favoritos",
        onTap: () async {
          Navigator.pop(context);
          Navigator.push(context, getPageRoute(FavoritosPage(), tema: tema));
        },
      ),
      MainMenuTile(
        icon: Icon(Icons.get_app),
        title: "Himnos Descargados",
        onTap: () async {
          Navigator.pop(context);
          Navigator.push(context, getPageRoute(DescargadosPage(), tema: tema));
        },
      ),
      MainMenuTile(
        icon: Icon(Icons.record_voice_over),
        title: "Voces Disponibles",
        onTap: () async {
          Navigator.pop(context);
          Navigator.push(context, getPageRoute(DisponiblesPage(), tema: tema));
        },
      ),
      MainMenuTile(
        icon: Icon(Icons.settings),
        title: "Ajustes",
        onTap: () {
          Navigator.pop(context);
          Navigator.push(context, getPageRoute(AjustesPage(), tema: tema));
        },
      ),
      MainMenuTile(
        icon: Icon(Icons.payments),
        title: "Donaciones",
        onTap: () {
          if (!isAndroid()) {
            Navigator.of(context).pop();
          }

          launch(
              'https://www.paypal.com/donate/?business=Y9VB93FT2L67G&no_recurring=0&item_name=Ay%C3%BAdame+a+financiar+la+infraestructura+de+la+aplicaci%C3%B3n+y+a+poder+trabajar+en+nuevos+proyectos+relacionados.&currency_code=USD');
        },
      ),
      MainMenuTile(
        icon: Icon(Icons.feedback),
        title: "Feedback",
        onTap: () {
          if (isAndroid()) {
            LaunchReview.launch();
          } else {
            Navigator.of(context).pop();
            LaunchReview.launch(writeReview: false, iOSAppId: "1444422315");
          }
        },
      ),
      MainMenuTile(
        icon: Icon(Icons.info_outline),
        title: "Políticas de privacidad",
        onTap: () {
          if (!isAndroid()) {
            Navigator.of(context).pop();
          }
          launch('https://sites.google.com/view/himnos-privacy-policy/');
        },
      )
    ];
  }

  Widget materialLayout(BuildContext context) {
    TemaModel tema = TemaModel.of(context);

    List<Widget> drawerList = [
      DrawerHeader(
        decoration: BoxDecoration(color: tema.getAccentColor()),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Himnos y Cánticos del Evangelio',
                textAlign: TextAlign.start,
                style: TextStyle(color: tema.getAccentColorText(), fontSize: 20.0),
              )
            ],
          ),
        ),
      )
    ];

    for (MainMenuTile tile in mainMenuTiles(context)) {
      drawerList.add(
        ListTile(
          leading: tile.icon,
          title: Text(tile.title),
          onTap: tile.onTap as GestureTapCallback?,
        ),
      );
    }

    return Scaffold(
      key: _globalKey,
      drawer: Drawer(
        // backgroundColor: tema.getScaffoldBackgroundColor(),
        child: ListView(
          padding: EdgeInsets.zero,
          children: drawerList,
        ),
      ),
      appBar: AppBar(
        // backgroundColor: tema.getAccentColor(),
        // foregroundColor: tema.getAccentColorText(),
        title: Container(
          width: double.infinity,
          child: Text(
            currentPage == 0 ? 'Himnos del Evangelio' : 'Coros',
            textAlign: TextAlign.center,
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  getPageRoute(Buscador(id: 0, subtema: false, type: currentPage == 0 ? BuscadorType.Himnos : BuscadorType.Coros), tema: tema));
              // MaterialPageRoute(
              //     builder: (BuildContext context) =>
              //         Buscador(id: 0, subtema: false, type: currentPage == 0 ? BuscadorType.Himnos : BuscadorType.Coros)));
            },
            icon: Icon(Icons.search),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 100),
            curve: Curves.easeInOutSine,
            height: cargando || categorias.isEmpty ? 4.0 : 0.0,
            child: LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryIconTheme.color == Colors.black ? Colors.black : Theme.of(context).primaryColor),
              backgroundColor: Colors.white,
            ),
          ),
        ),
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: (int index) => setState(() => currentPage = index),
        children: <Widget>[
          HimnosTab(
            categorias: categorias,
            onRefresh: () => checkUpdates(prefs),
          ),
          CorosTab(
            coros: coros,
            onRefresh: () => checkUpdates(prefs),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPage,
        // backgroundColor: tema.getAccentColor(),
        // Selected
        // selectedItemColor: tema.getAccentColorText(),
        // selectedIconTheme: IconThemeData(opacity: 1.0),

        // Unselected
        // unselectedItemColor: tema.getAccentColorText().withOpacity(0.7),
        // unselectedIconTheme: IconThemeData(size: 20.0, opacity: 0.7),
        type: BottomNavigationBarType.fixed,
        onTap: (int e) {
          pageController.animateToPage(e, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
          setState(() => currentPage = e);
        },
        items: [
          BottomNavigationBarItem(
            // backgroundColor: Theme.of(context).primaryColor,
            icon: Icon(Icons.library_music),
            label: 'Himnos',
          ),
          BottomNavigationBarItem(
            // backgroundColor: Theme.of(context).primaryColor,
            icon: Icon(Icons.music_note),
            label: 'Coros',
          ),
        ],
      ),
      floatingActionButton: currentPage == 0
          ? FloatingActionButton(
              // backgroundColor: getColorShade(tema.getAccentColor(), 0.2),
              // foregroundColor: tema.getAccentColor(),
              // tema.setBrightness(tema.brightness == Brightness.light ? Brightness.dark : Brightness.light);
              onPressed: () {
                Navigator.push(context, getPageRoute(QuickBuscador(), tema: tema));
              },
              child: Icon(Icons.dialpad),
            )
          : null,
    );
  }

  Widget cupertinoLayout(BuildContext context) {
    final tema = TemaModel.of(context);

    void showCupertinoMenu() {
      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
          cancelButton: CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
            ),
          ),
          actions: mainMenuTiles(context)
              .map((e) => CupertinoActionSheetAction(
                    child: Text(e.title, style: TextStyle(color: tema.getScaffoldTextColor())),
                    onPressed: e.onTap as VoidCallback,
                  ))
              .toList(),
        ),
      );
    }

    return Stack(
      children: [
        CupertinoTabScaffold(
          tabBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return HimnosTab(
                categorias: categorias,
                onRefresh: () => checkUpdates(prefs),
                showCupertinoMenu: showCupertinoMenu,
              );
            }

            return CorosTab(
              coros: coros,
              onRefresh: () => checkUpdates(prefs),
              showCupertinoMenu: showCupertinoMenu,
            );
          },
          tabBar: CupertinoTabBar(
            activeColor: tema.getAccentColorText(),
            iconSize: 25.0,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.library_music),
                label: 'Himnos',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.music_note),
                label: 'Coros',
              ),
            ],
          ),
        ),
        Positioned(
          left: -50.0,
          bottom: 80.0,
          child: AnimatedContainer(
            transform: cargando ? Matrix4.translationValues(0.0, 0.0, 0.0) : Matrix4.translationValues(-50.0, 0.0, 0.0),
            curve: Curves.easeOutSine,
            duration: Duration(milliseconds: 1000),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: TemaModel.of(context).getAccentColorText(),
            ),
            width: 100.0,
            height: 54.0,
            child: Padding(
                padding: EdgeInsets.only(left: 50.0),
                child: CupertinoActivityIndicator(
                  animating: true,
                )),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAndroid() ? materialLayout(context) : cupertinoLayout(context);
  }
}
