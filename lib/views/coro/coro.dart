import 'package:Himnario/db/db.dart';
import 'package:Himnario/helpers/isAndroid.dart';
import 'package:Himnario/helpers/smallDevice.dart';
import 'package:Himnario/models/himnos.dart';
import 'package:Himnario/models/tema.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import './components/bodyCoro.dart';

class CoroPage extends StatefulWidget {
  final int numero;
  final String titulo;
  final int transpose;

  CoroPage({
    required this.numero,
    required this.titulo,
    required this.transpose,
  });

  @override
  _CoroPageState createState() => _CoroPageState();
}

class _CoroPageState extends State<CoroPage> with SingleTickerProviderStateMixin {
  List<Parrafo> estrofas = [];
  bool acordesDisponible = false;
  bool cargando = true;
  bool favorito = false;
  bool acordes = false;
  bool transposeMode = false;
  double initFontSizePortrait = 16.0;
  double initFontSizeLandscape = 16.0;
  bool descargado = false;
  int max = 0;
  SharedPreferences? prefs;

  late AnimationController fontController;
  late int transpose;
  late int totalDuration;

  // autoScroll Variables
  ScrollController scrollController = ScrollController();
  bool scrollMode = false;
  bool autoScroll = false;
  int autoScrollRate = 0;

  @override
  void initState() {
    super.initState();

    print(widget.transpose);
    transpose = widget.transpose;

    fontController = AnimationController(vsync: this, duration: Duration(milliseconds: 500), lowerBound: 0.1, upperBound: 1.0)
      ..addListener(() => setState(() {}));

    getHimno();
    WakelockPlus.enable();
  }

  Future<Null> getHimno() async {
    prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> parrafos = await DB.rawQuery('select * from parrafos where himno_id = ${widget.numero}');
    estrofas = Parrafo.fromJson(parrafos);

    for (Parrafo parrafo in estrofas) {
      acordesDisponible = parrafo.acordes != null && parrafo.acordes!.split('\n')[0] != '' && parrafo.acordes != '';
      print(acordesDisponible);
      if (acordesDisponible) {
        parrafo.acordes = Acordes.transpose(transpose, parrafo.acordes!.split('\n')).join('\n');
      }
      for (String linea in parrafo.parrafo.split('\n')) {
        if (linea.length > max) max = linea.length;
      }
    }

    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      initFontSizePortrait = (MediaQuery.of(context).size.width - 30) / max + 8;
      initFontSizeLandscape = (MediaQuery.of(context).size.height - 30) / max + 8;
    } else {
      initFontSizePortrait = (MediaQuery.of(context).size.height - 30) / max + 8;
      initFontSizeLandscape = (MediaQuery.of(context).size.width - 30) / max + 8;
    }

    List<Map<String, dynamic>> favoritosQuery = await DB.rawQuery('select * from favoritos where himno_id = ${widget.numero}');
    List<Map<String, dynamic>> descargadoQuery = await DB.rawQuery('select * from descargados where himno_id = ${widget.numero}');

    setState(() {
      favorito = favoritosQuery.isNotEmpty;
      descargado = descargadoQuery.isNotEmpty;
      totalDuration = descargadoQuery.isNotEmpty ? descargadoQuery[0]['duracion'] : 0;
    });
    return null;
  }

  @override
  void dispose() async {
    super.dispose();
    WakelockPlus.disable();
  }

  void toggleFavorito() async {
    if (favorito) {
      await DB.rawDelete('delete from favoritos where himno_id = ${widget.numero}');
    } else {
      await DB.rawInsert('insert into favoritos values (${widget.numero})');
    }

    setState(() => favorito = !favorito);
  }

  void applyTranspose(int value) async {
    transpose = transpose + value;
    for (Parrafo parrafo in estrofas) {
      parrafo.acordes = Acordes.transpose(value, parrafo.acordes!.split('\n')).join('\n');
    }

    await DB.rawQuery('update himnos set transpose = ${transpose % 12} where id = ${widget.numero}');

    setState(() {});
  }

  void stopScroll() => scrollController.animateTo(scrollController.offset, curve: Curves.linear, duration: Duration(milliseconds: 1));

  void toggleAcordes() {
    acordes = !acordes;
    if (fontController.value == 1.0) {
      fontController.animateTo(0.0, curve: Curves.fastOutSlowIn);
      if (transposeMode) transposeMode = false;
      if (scrollMode) {
        stopScroll();
        autoScroll = false;
        scrollMode = false;
      }
      setState(() {});
    } else {
      fontController.animateTo(1.0, curve: Curves.linearToEaseOut);
    }

    if (!isAndroid()) {
      Navigator.of(context).pop();
    }
  }

  void toggleTransponer() {
    if (!transposeMode) if (fontController.value == 0.1) {
      fontController.animateTo(1.0, curve: Curves.linearToEaseOut);
    }
    ;

    if (scrollMode) {
      stopScroll();
      autoScroll = false;
      scrollMode = false;
    }

    setState(() => transposeMode = !transposeMode);

    if (!isAndroid()) {
      Navigator.of(context).pop();
    }
  }

  void toggleOriginalKey() {
    applyTranspose(-transpose);

    if (!isAndroid()) {
      Navigator.of(context).pop();
    }
  }

  void toggleNotation() {
    String currentNotation = prefs!.getString('notation') ?? 'latina';
    prefs!.setString('notation', currentNotation == 'latina' ? 'americana' : 'latina');

    if (!transposeMode && fontController.value == 0.1) {
      fontController.animateTo(1.0, curve: Curves.linearToEaseOut);
    }
    setState(() {});

    if (!isAndroid()) {
      Navigator.of(context).pop();
    }
  }

  void toggleScrollMode() {
    if (scrollController.position.maxScrollExtent > 0.0) {
      if (!scrollMode && fontController.value == 0.1) {
        fontController.animateTo(1.0, curve: Curves.linearToEaseOut);
      }

      if (transposeMode) {
        transposeMode = false;
      }
      setState(() => scrollMode = !scrollMode);

      if (!isAndroid()) {
        Navigator.of(context).pop();
      }
    }
  }

  Widget renderBody() {
    return Padding(
      padding: EdgeInsets.only(bottom: transposeMode || scrollMode ? 40.0 : 0.0),
      child: BodyCoro(
        scrollController: scrollController,
        stopScroll: () {
          stopScroll();
          setState(() => autoScroll = false);
        },
        alignment: prefs!.getString('alignment') ?? 'Izquierda',
        estrofas: estrofas,
        initFontSizePortrait: initFontSizePortrait,
        initFontSizeLandscape: initFontSizeLandscape,
        acordes: acordes,
        animation: fontController.value,
        notation: prefs!.getString('notation') ?? 'latino',
      ),
    );
  }

  Widget renderTransposingBar() {
    final tema = TemaModel.of(context);

    Widget _materialBar() => ButtonBar(
          alignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            TextButton.icon(
              icon: Icon(
                Icons.arrow_drop_down,
                color: tema.getScaffoldTextColor(),
              ),
              label: Text(
                smallDevice(context) ? '-' : 'Bajar Tono',
                style: TextStyle(color: tema.getAccentColorText()),
              ),
              onPressed: () => applyTranspose(-1),
            ),
            TextButton.icon(
              icon: Icon(
                Icons.arrow_drop_up,
                color: tema.getScaffoldTextColor(),
              ),
              label: Text(
                smallDevice(context) ? '+' : 'Subir Tono',
                style: TextStyle(color: tema.getAccentColorText()),
              ),
              onPressed: () => applyTranspose(1),
            ),
            OutlinedButton(
              child: Text(
                'Ok',
                style: TextStyle(color: tema.getScaffoldTextColor()),
              ),
              onPressed: () => setState(() => transposeMode = !transposeMode),
            )
          ],
        );

    Widget _cupertinoBar() => ButtonBar(
          alignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            CupertinoButton(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.arrow_drop_down,
                    color: tema.getScaffoldTextColor(),
                  ),
                  Text(
                    smallDevice(context) ? '-' : 'Bajar Tono',
                    style: DefaultTextStyle.of(context).style.copyWith(
                          color: tema.getScaffoldTextColor(),
                          fontFamily: tema.font,
                        ),
                  )
                ],
              ),
              onPressed: () => applyTranspose(-1),
            ),
            CupertinoButton(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.arrow_drop_up,
                    color: tema.getScaffoldTextColor(),
                  ),
                  Text(
                    smallDevice(context) ? '+' : 'Subir Tono',
                    style: DefaultTextStyle.of(context).style.copyWith(
                          color: tema.getScaffoldTextColor(),
                          fontFamily: tema.font,
                        ),
                  )
                ],
              ),
              onPressed: () => applyTranspose(1),
            ),
            CupertinoButton(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Text(
                'Ok',
                style: TextStyle(color: tema.getScaffoldTextColor(), fontFamily: tema.font),
              ),
              onPressed: () => setState(() => transposeMode = !transposeMode),
            )
          ],
        );

    return Align(
      alignment: Alignment.bottomCenter,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.fastOutSlowIn,
        height: transposeMode ? 60 : 0.0,
        width: double.infinity,
        decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
              blurRadius: 20.0,
              // spreadRadius: 1.0,
              offset: Offset(0.0, 18.0),
            )
          ],
          color: isAndroid() ? Theme.of(context).scaffoldBackgroundColor : ScopedModel.of<TemaModel>(context).getScaffoldBackgroundColor(),
        ),
        child: isAndroid() ? _materialBar() : _cupertinoBar(),
      ),
    );
  }

  // Auto Scroll Logic

  void autoScrollSpeedDown() {
    autoScrollRate = autoScrollRate > 0 ? autoScrollRate - 1 : 0;
    scrollController.animateTo(scrollController.position.maxScrollExtent,
        curve: Curves.linear,
        duration: Duration(seconds: ((scrollController.position.maxScrollExtent - scrollController.offset) / (5 + 5 * autoScrollRate)).floor()));
    setState(() => autoScroll = true);
  }

  void autoScrollPausePlay() {
    if (autoScroll) {
      stopScroll();
    } else {
      scrollController.animateTo(scrollController.position.maxScrollExtent,
          curve: Curves.linear,
          duration: Duration(seconds: ((scrollController.position.maxScrollExtent - scrollController.offset) / (5 + 5 * autoScrollRate)).floor()));
    }
    setState(() => autoScroll = !autoScroll);
  }

  void autoScrollSpeedUp() {
    ++autoScrollRate;
    scrollController.animateTo(scrollController.position.maxScrollExtent,
        curve: Curves.linear,
        duration: Duration(seconds: ((scrollController.position.maxScrollExtent - scrollController.offset) / (5 + 5 * autoScrollRate)).floor()));
    setState(() => autoScroll = true);
  }

  Widget renderAutoScroll() {
    final tema = TemaModel.of(context);

    return Align(
      alignment: Alignment.bottomCenter,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.fastOutSlowIn,
        height: scrollMode ? 60 : 0.0,
        width: double.infinity,
        decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
              blurRadius: 20.0,
              offset: Offset(0.0, 18.0),
            ),
          ],
          color: tema.getScaffoldBackgroundColor(),
        ),
        child: ButtonBar(
          alignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            TextButton(
              child: Icon(
                Icons.fast_rewind,
                color: tema.getScaffoldTextColor(),
              ),
              onPressed: autoScrollSpeedDown,
            ),
            TextButton(
              child: Row(
                children: <Widget>[
                  Icon(
                    autoScroll ? Icons.pause : Icons.play_arrow,
                    color: tema.getScaffoldTextColor(),
                  ),
                  Text(
                    '${autoScrollRate + 1}x',
                    style: TextStyle(
                      fontFamily: tema.font,
                      color: tema.getScaffoldTextColor(),
                    ),
                  ),
                ],
              ),
              onPressed: autoScrollPausePlay,
            ),
            TextButton(
              child: Icon(
                Icons.fast_forward,
                color: tema.getScaffoldTextColor(),
              ),
              onPressed: autoScrollSpeedUp,
            ),
          ],
        ),
      ),
    );
  }

  Widget materialLayout(BuildContext context) {
    if (prefs != null) {
      return Scaffold(
        appBar: AppBar(
            actions: <Widget>[
              IconButton(
                onPressed: toggleFavorito,
                icon: favorito
                    ? Icon(
                        Icons.star,
                      )
                    : Icon(
                        Icons.star_border,
                      ),
              ),
              PopupMenuButton(
                onSelected: (int e) {
                  switch (e) {
                    case 0:
                      toggleAcordes();
                      break;
                    case 1:
                      toggleTransponer();
                      break;
                    case 2:
                      toggleOriginalKey();
                      break;
                    case 3:
                      toggleNotation();
                      break;
                    case 4:
                      toggleScrollMode();
                      break;
                    default:
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                  PopupMenuItem(
                      value: 0,
                      enabled: acordesDisponible,
                      child: ListTile(
                        leading: Icon(Icons.music_note),
                        title: Text(
                          (fontController.value == 1 ? 'Ocultar' : 'Mostrar') + ' Acordes',
                          style: DefaultTextStyle.of(context).style.copyWith(
                                color: acordesDisponible ? TemaModel.of(context).getScaffoldTextColor() : Colors.grey,
                              ),
                        ),
                      )),
                  PopupMenuItem(
                      value: 1,
                      enabled: acordesDisponible,
                      child: ListTile(
                        leading: Icon(Icons.unfold_more),
                        title: Text(
                          'Transponer',
                          style: DefaultTextStyle.of(context).style.copyWith(
                                color: acordesDisponible ? TemaModel.of(context).getScaffoldTextColor() : Colors.grey,
                              ),
                        ),
                      )),
                  PopupMenuItem(
                      value: 2,
                      enabled: acordesDisponible,
                      child: ListTile(
                        leading: Icon(Icons.undo),
                        title: Text(
                          'Tono Original',
                          style: DefaultTextStyle.of(context).style.copyWith(
                                color: acordesDisponible ? TemaModel.of(context).getScaffoldTextColor() : Colors.grey,
                              ),
                        ),
                      )),
                  PopupMenuItem(
                      value: 3,
                      enabled: acordesDisponible,
                      child: ListTile(
                        leading: Image.asset(
                          'assets/notation.png',
                          color: acordesDisponible ? Colors.grey[600] : Colors.grey[300],
                          width: 20.0,
                        ),
                        title: Text(
                          'Notación ' + (prefs!.getString('notation') == null || prefs!.getString('notation') == 'latina' ? 'americana' : 'latina'),
                          style: DefaultTextStyle.of(context).style.copyWith(
                                color: acordesDisponible ? TemaModel.of(context).getScaffoldTextColor() : Colors.grey,
                              ),
                        ),
                      )),
                  PopupMenuItem(
                      value: 4,
                      enabled: acordesDisponible && scrollController.position.maxScrollExtent > 0.0,
                      child: ListTile(
                        leading: Icon(Icons.expand_more),
                        title: Text(
                          'Scroll Automático',
                          style: DefaultTextStyle.of(context).style.copyWith(
                                color: acordesDisponible && scrollController.position.maxScrollExtent > 0.0
                                    ? TemaModel.of(context).getScaffoldTextColor()
                                    : Colors.grey,
                              ),
                        ),
                      )),
                ],
              )
            ],
            title: Tooltip(
              message: widget.titulo,
              child: Container(
                width: double.infinity,
                child: Text(
                  widget.titulo,
                  textScaleFactor: 0.9,
                ),
              ),
            )),
        body: Stack(
          children: <Widget>[
            renderBody(),
            renderTransposingBar(),
            renderAutoScroll(),
          ],
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(),
      );
    }
  }

  Widget cupertinoLayout(BuildContext context) {
    final tema = TemaModel.of(context);

    return Stack(children: <Widget>[
      CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
            backgroundColor: tema.getAccentColor(),
            middle: Text(
              widget.titulo,
              style: TextStyle(
                color: tema.getAccentColorText(),
                fontFamily: tema.font,
              ),
            ),
            trailing: prefs != null
                ? Transform.translate(
                    offset: Offset(20.0, 0.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        CupertinoButton(
                          onPressed: toggleFavorito,
                          padding: EdgeInsets.only(bottom: 2.0),
                          child: favorito
                              ? Icon(
                                  Icons.star,
                                  size: 30.0,
                                  color: tema.getAccentColorText(),
                                )
                              : Icon(
                                  Icons.star_border,
                                  size: 30.0,
                                  color: tema.getAccentColorText(),
                                ),
                        ),
                        CupertinoButton(
                          disabledColor: Colors.black.withOpacity(0.5),
                          onPressed: acordesDisponible
                              ? () {
                                  showCupertinoModalPopup(
                                      context: context,
                                      builder: (BuildContext context) => CupertinoActionSheet(
                                            // title: Text('Menu'),
                                            cancelButton: CupertinoActionSheetAction(
                                              isDestructiveAction: true,
                                              onPressed: () => Navigator.of(context).pop(),
                                              child: Text('Cancelar'),
                                            ),
                                            actions: <Widget>[
                                              CupertinoActionSheetAction(
                                                onPressed: toggleAcordes,
                                                child: Text(
                                                  (fontController.value == 1 ? 'Ocultar' : 'Mostrar') + ' Acordes',
                                                  style: TextStyle(
                                                    color: tema.getScaffoldTextColor(),
                                                  ),
                                                ),
                                              ),
                                              CupertinoActionSheetAction(
                                                onPressed: toggleTransponer,
                                                child: Text(
                                                  'Transponer',
                                                  style: TextStyle(
                                                    color: tema.getScaffoldTextColor(),
                                                  ),
                                                ),
                                              ),
                                              CupertinoActionSheetAction(
                                                onPressed: toggleOriginalKey,
                                                child: Text(
                                                  'Tono Original',
                                                  style: TextStyle(
                                                    color: tema.getScaffoldTextColor(),
                                                  ),
                                                ),
                                              ),
                                              CupertinoActionSheetAction(
                                                onPressed: toggleNotation,
                                                child: Text(
                                                  'Notación ' +
                                                      (prefs!.getString('notation') == null || prefs!.getString('notation') == 'latina'
                                                          ? 'americana'
                                                          : 'latina'),
                                                  style: TextStyle(
                                                    color: tema.getScaffoldTextColor(),
                                                  ),
                                                ),
                                              ),
                                              CupertinoActionSheetAction(
                                                onPressed: toggleScrollMode,
                                                child: Text(
                                                  'Scroll Automático',
                                                  style: TextStyle(
                                                    color: tema.getScaffoldTextColor(),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ));
                                }
                              : null,
                          padding: EdgeInsets.only(bottom: 2.0),
                          child: Icon(
                            Icons.more_vert,
                            size: 30.0,
                            color: tema.getAccentColorText(),
                          ),
                        ),
                      ],
                    ),
                  )
                : null),
        child: prefs != null
            ? Stack(
                children: <Widget>[
                  renderBody(),
                  renderTransposingBar(),
                  renderAutoScroll(),
                ],
              )
            : Container(),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return isAndroid() ? materialLayout(context) : cupertinoLayout(context);
  }
}
