import 'dart:io';

import 'package:Himnario/components/corosScroller.dart';
import 'package:Himnario/components/scroller.dart';
import 'package:Himnario/db/db.dart';
import 'package:Himnario/helpers/isAndroid.dart';
import 'package:Himnario/helpers/scrollerBuilder.dart';
import 'package:Himnario/main.dart';
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

class HimnoResult extends Himno {
  int numero;
  String titulo;
  int transpose;
  int autoScrollSpeed;
  bool favorito;
  bool descargado;
  DateTime date_visited;
  bool changedDate = false;

  HimnoResult({
    required this.numero,
    required this.titulo,
    this.favorito = false,
    this.descargado = false,
    this.transpose = 0,
    this.autoScrollSpeed = 0,
    required this.date_visited,
  }) : super(
          numero: numero,
          titulo: titulo,
          favorito: favorito,
          descargado: descargado,
          transpose: transpose,
          autoScrollSpeed: autoScrollSpeed,
        );
}

class RecientesPage extends StatefulWidget {
  @override
  _RecientesPageState createState() => _RecientesPageState();
}

class _RecientesPageState extends State<RecientesPage> with RouteAware {
  List<HimnoResult> himnos = [];
  bool cargando = true;
  String path = '';
  Database? db;
  TextEditingController controller = TextEditingController();
  DateTime? _date;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      routeObserver.subscribe(this, ModalRoute.of(context)!);
    });

    fetchHimnos(_date);

    // controller.
  }

  @override
  void didPopNext() {
    super.didPopNext();
    print('didPopNext');
    fetchHimnos(_date);
  }

  Future<Null> fetchHimnos(DateTime? date) async {
    setState(() {
      cargando = true;
      himnos = [];
    });

    List<HimnoResult> _himnos = [];

    List<Map<String, dynamic>> data = await DB.rawQuery('''
          SELECT 
            himnos.id, 
            himnos.titulo,
            himnos.transpose,
            himnos.scroll_speed,
            favoritos.himno_id as favorito,
            descargados.himno_id as descargado,
            visitas.date as date
          FROM visitas
          JOIN himnos ON visitas.himno_id = himnos.id
          LEFT JOIN favoritos ON favoritos.himno_id = himnos.id 
          LEFT JOIN descargados ON himnos.id = descargados.himno_id
          ${date != null ? "WHERE DATE(visitas.date) = DATE('${date.toIso8601String().split('T').first}')" : ''}
          ORDER BY visitas.date DESC
        ''');

    DateTime? lastDate = null;

    for (dynamic himno in data) {
      HimnoResult himnosResult = HimnoResult(
        numero: himno['id'],
        titulo: himno['titulo'],
        transpose: himno['transpose'] ?? 0,
        autoScrollSpeed: himno['scroll_speed'] ?? 0,
        descargado: himno['descargado'] != null,
        favorito: himno['favorito'] != null,
        date_visited: DateTime.parse(himno['date']),
      );

      if (lastDate == null || lastDate.toIso8601String().split('T').first != himnosResult.date_visited.toIso8601String().split('T').first) {
        lastDate = himnosResult.date_visited;
        himnosResult.changedDate = true;
      }

      _himnos.add(himnosResult);
    }

    setState(() {
      cargando = false;
      himnos = _himnos;
    });
  }

  @override
  void dispose() async {
    super.dispose();
    routeObserver.unsubscribe(this);
    controller.dispose();
  }

  Widget buscadorRangoDeFechas(BuildContext context) {
    final tema = TemaModel.of(context);

    if (Platform.isAndroid) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtrar por fecha',
              style: TextStyle(
                color: tema.getScaffoldTextColor(),
              ),
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: controller,
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'DD-MM-YYYY',
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear, color: tema.getScaffoldTextColor()),
                  onPressed: () {
                    controller.clear();
                    _date = null;
                    fetchHimnos(_date);
                  },
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: tema.getScaffoldTextColor(), width: 0.5),
                  borderRadius: BorderRadius.circular(7.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: tema.getScaffoldTextColor(), width: 0.5),
                  borderRadius: BorderRadius.circular(7.0),
                ),
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _date ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: tema.getAccentColor(),
                          onPrimary: Colors.white,
                          surface: tema.getScaffoldBackgroundColor(),
                          onSurface: tema.getScaffoldTextColor(),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );

                if (pickedDate != null) {
                  _date = pickedDate;
                  controller.text =
                      '${pickedDate.day < 10 ? '0' : ''}${pickedDate.day}-${pickedDate.month < 10 ? '0' : ''}${pickedDate.month}-${pickedDate.year}';
                  fetchHimnos(_date);
                }
              },
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      // height: 150.0,
      padding: EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtrar por fecha',
            style: TextStyle(
              color: tema.getScaffoldTextColor(),
            ),
          ),
          SizedBox(height: 10.0),
          CupertinoTextField(
            // padding: EdgeInsets.all(10.0),
            placeholder: 'DD-MM-YYYY',
            clearButtonMode: OverlayVisibilityMode.editing,
            // prefix: Padding(padding: EdgeInsets.only(left: 7.0), child: Icon(Icons.date_range, color: tema.getScaffoldTextColor())),
            cursorColor: tema.brightness == Brightness.light ? Colors.black : Colors.white,
            style: TextStyle(
              color: tema.brightness == Brightness.light ? Colors.black : Colors.white,
              fontFamily: tema.font,
            ),
            readOnly: true,
            onChanged: (value) {
              _date = null;
              fetchHimnos(_date);
            },
            onTap: () {
              DateTime? picked_date;
              showCupertinoModalPopup(
                context: context,
                builder: (_) {
                  return Container(
                    height: 200.0,
                    color: tema.getScaffoldBackgroundColor(),
                    child: Column(
                      children: [
                        Expanded(
                          child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.date,
                            initialDateTime: _date ?? DateTime.now(),
                            dateOrder: DatePickerDateOrder.dmy,
                            onDateTimeChanged: (value) {
                              picked_date = value;
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CupertinoButton(
                              child: Text(
                                'Cancelar',
                                style: TextStyle(
                                  color: tema.getScaffoldTextColor(),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            CupertinoButton(
                              child: Text(
                                'Aceptar',
                                style: TextStyle(
                                  color: tema.getScaffoldTextColor(),
                                ),
                              ),
                              onPressed: () {
                                if (picked_date == null) picked_date = DateTime.now();

                                _date = picked_date;
                                controller.text =
                                    '${picked_date!.day < 10 ? '0' : ''}${picked_date!.day}-${picked_date!.month < 10 ? '0' : ''}${picked_date!.month}-${picked_date!.year}';

                                Navigator.pop(context);
                                // fetchHimnos(_date);
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              );
            },
            controller: controller,
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: tema.getScaffoldBackgroundColor(),
              borderRadius: BorderRadius.circular(7.0),
              border: Border.all(color: tema.getScaffoldTextColor(), width: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget materialLayout(BuildContext context) {
    final tema = TemaModel.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Recientes'),
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
      body: Column(
        children: [
          buscadorRangoDeFechas(context),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Divider(
              thickness: 1.0,
              color: tema.getScaffoldTextColor(),
            ),
          ),
          Expanded(
            child: himnos.isEmpty
                ? Container(
                    child: Center(
                      child: Text(
                        'No has ingresado a ningún himno',
                        textScaleFactor: 1.5,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: himnos.length,
                    itemBuilder: (context, index) {
                      List<Widget> children = [];

                      if (himnos[index].changedDate) {
                        children.addAll([
                          Divider(
                            thickness: 0.5,
                            color: tema.getScaffoldTextColor(),
                          ),
                          Container(
                            padding: EdgeInsets.all(10.0),
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${himnos[index].date_visited.day < 10 ? '0' : ''}${himnos[index].date_visited.day}-${himnos[index].date_visited.month < 10 ? '0' : ''}${himnos[index].date_visited.month}-${himnos[index].date_visited.year}',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 18.0,
                                  ),
                                ),
                                Text(
                                  ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"][himnos[index].date_visited.weekday - 1],
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 18.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            thickness: 0.5,
                            color: tema.getScaffoldTextColor(),
                          ),
                        ]);
                      }

                      children.add(
                        ListTile(
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
                          },
                          leading: himnos[index].favorito
                              ? Icon(
                                  Icons.star,
                                  color: tema.getScaffoldTextColor(),
                                )
                              : null,
                          title: Text(
                            ((himnos[index].numero > 517 ? '' : '${himnos[index].numero} - ') + '${himnos[index].titulo}'),
                          ),
                          subtitle: Text(
                            '${himnos[index].date_visited!.day < 10 ? '0' : ''}${himnos[index].date_visited!.day}-${himnos[index].date_visited!.month < 10 ? '0' : ''}${himnos[index].date_visited!.month}-${himnos[index].date_visited!.year} ${himnos[index].date_visited!.hour < 10 ? '0' : ''}${himnos[index].date_visited!.hour}:${himnos[index].date_visited!.minute < 10 ? '0' : ''}${himnos[index].date_visited!.minute}:${himnos[index].date_visited!.second < 10 ? '0' : ''}${himnos[index].date_visited!.second}',
                            style: TextStyle(
                              color: tema.getScaffoldTextColor().withOpacity(0.5),
                              fontSize: 10.0,
                            ),
                          ),
                          trailing: himnos[index].descargado
                              ? Icon(
                                  Icons.get_app,
                                  color: tema.getScaffoldTextColor(),
                                )
                              : null,
                        ),
                      );

                      return Column(
                        children: children,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget cupertinoLayout(BuildContext context) {
    final tema = TemaModel.of(context);

    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          backgroundColor: tema.getAccentColor(),
          middle: Text(
            'Recientes',
            style: TextStyle(
              color: tema.getAccentColorText(),
              fontFamily: tema.font,
            ),
          ),
        ),
        child: Column(
          children: [
            buscadorRangoDeFechas(context),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Divider(
                thickness: 1.0,
                color: tema.getScaffoldTextColor(),
              ),
            ),
            Expanded(
              child: himnos.isEmpty
                  ? Container(
                      child: Center(
                        child: Text(
                          'No has ingresado a ningún himno',
                          textScaleFactor: 1.5,
                          textAlign: TextAlign.center,
                          style: tema.getScaffoldTextStyle(context),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: himnos.length,
                      itemBuilder: (context, index) {
                        List<Widget> children = [];

                        if (himnos[index].changedDate) {
                          children.addAll([
                            Divider(
                              thickness: 0.5,
                              // indent: 50.0,
                              // endIndent: 150.0,
                              color: tema.getScaffoldTextColor(),
                            ),
                            Container(
                              padding: EdgeInsets.all(10.0),
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${himnos[index].date_visited.day < 10 ? '0' : ''}${himnos[index].date_visited.day}-${himnos[index].date_visited.month < 10 ? '0' : ''}${himnos[index].date_visited.month}-${himnos[index].date_visited.year}',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: tema.getScaffoldTextColor(),
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  Text(
                                    [
                                      "Lunes",
                                      "Martes",
                                      "Miércoles",
                                      "Jueves",
                                      "Viernes",
                                      "Sábado",
                                      "Domingo"
                                    ][himnos[index].date_visited.weekday - 1],
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: tema.getScaffoldTextColor(),
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              thickness: 0.5,
                              // indent: 50.0,
                              // endIndent: 150.0,
                              color: tema.getScaffoldTextColor(),
                            ),
                          ]);
                        }

                        children.add(
                          Container(
                            color: tema.getScaffoldBackgroundColor(),
                            height: 65.0,
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
                                    child: Container(
                                      width: double.infinity,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            ((himnos[index].numero > 517 ? '' : '${himnos[index].numero} - ') + '${himnos[index].titulo}'),
                                            softWrap: true,
                                            textAlign: TextAlign.start,
                                            style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                                                  color: tema.getScaffoldTextColor(),
                                                  fontFamily: tema.font,
                                                ),
                                          ),
                                          Text(
                                            '${himnos[index].date_visited!.day < 10 ? '0' : ''}${himnos[index].date_visited!.day}-${himnos[index].date_visited!.month < 10 ? '0' : ''}${himnos[index].date_visited!.month}-${himnos[index].date_visited!.year} ${himnos[index].date_visited!.hour < 10 ? '0' : ''}${himnos[index].date_visited!.hour}:${himnos[index].date_visited!.minute < 10 ? '0' : ''}${himnos[index].date_visited!.minute}:${himnos[index].date_visited!.second < 10 ? '0' : ''}${himnos[index].date_visited!.second}',
                                            style: TextStyle(
                                              color: getColorShade(tema.getScaffoldTextColor(), 0.5),
                                              fontSize: 10.0,
                                            ),
                                          )
                                        ],
                                      ),
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
                                                color: tema.getScaffoldTextColor(),
                                              )
                                            : Container(),
                                        himnos[index].descargado
                                            ? Icon(
                                                Icons.get_app,
                                                color: tema.getScaffoldTextColor(),
                                              )
                                            : Container()
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );

                        return Column(
                          children: children,
                        );
                      },
                    ),
            ),
            // Expanded(
            //   child: Scroller(
            //     count: himnos.length,
            //     itemBuilder: scrollerBuilderHimnos(context, himnos),
            //     scrollerBubbleText: (index) => himnos[index].numero <= 517 ? himnos[index].numero.toString() : himnos[index].titulo[0],
            //     iPhoneX: MediaQuery.of(context).size.width >= 812.0 || MediaQuery.of(context).size.height >= 812.0,
            //     mensaje: 'No has ingresado a ningún himno',
            //   ),
            // ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return isAndroid() ? materialLayout(context) : cupertinoLayout(context);
  }
}
