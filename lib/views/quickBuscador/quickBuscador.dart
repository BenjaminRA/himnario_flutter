import 'dart:async';

import 'package:Himnario/db/db.dart';
import 'package:Himnario/helpers/isAndroid.dart';
import 'package:Himnario/models/tema.dart';
import 'package:Himnario/views/himno/himno.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Himnario/models/himnos.dart';
import 'package:Himnario/components/himno/estructuraHimno.dart';

class QuickBuscador extends StatefulWidget {
  @override
  _QuickBuscadorState createState() => _QuickBuscadorState();
}

class _QuickBuscadorState extends State<QuickBuscador> {
  bool done = false;
  bool cargando = true;
  String path = '';
  String alignment = 'Izquierda';
  Himno himno = Himno(titulo: 'Ingrese un número', numero: -1);
  List<Parrafo> estrofas = [];
  int max = 0;
  double fontSize = 16.0;

  @override
  void initState() {
    super.initState();
    // path = '';
    // max = 0;
    // fontSize = 16.0;
    // done = false;
    // cargando = true;
    // estrofas = List<Parrafo>();
    // himno = Himno(titulo: 'Ingrese un número', numero: -1);

    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        alignment = prefs.getString('alignment') ?? 'Izquierda';
        cargando = false;
      });
    });
  }

  void onChanged(String query) async {
    max = 0;
    setState(() => cargando = true);
    if (query.isNotEmpty) {
      List<Map<String, dynamic>> himnoQuery = await DB.rawQuery('select himnos.id, himnos.titulo from himnos where himnos.id = $query');
      if (himnoQuery.isEmpty || int.parse(query) > 517)
        setState(() {
          estrofas = [];
          himno = Himno(titulo: 'No Encontrado', numero: -2);
          cargando = false;
        });
      else {
        List<Map<String, dynamic>> parrafos = await DB.rawQuery('select * from parrafos where himno_id = $query');
        for (Map<String, dynamic> parrafo in parrafos) {
          for (String linea in parrafo['parrafo'].split('\n')) {
            if (linea.length > max) max = linea.length;
          }
        }
        setState(() {
          himno = Himno(titulo: himnoQuery[0]['titulo'], numero: himnoQuery[0]['id']);
          estrofas = Parrafo.fromJson(parrafos);
          cargando = false;
          fontSize = (MediaQuery.of(context).size.width - 30) / max + 8;
        });
      }
    } else
      setState(() {
        estrofas = [];
        himno = Himno(titulo: 'Ingrese un número', numero: -1);
        cargando = false;
      });
  }

  Widget materialLayout() {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).canvasColor,
              suffix: Container(
                width: MediaQuery.of(context).size.width - 200,
                child: Text(
                  himno.titulo ?? '',
                  textAlign: TextAlign.end,
                  textScaleFactor: 0.9,
                  style: TextStyle(
                    color: TemaModel.of(context).getScaffoldTextColor(),
                    fontFamily: TemaModel.of(context).font,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )),
          style: TextStyle(
            color: TemaModel.of(context).getScaffoldTextColor(),
            fontFamily: TemaModel.of(context).font,
            fontSize: 20.0,
            fontWeight: FontWeight.w500,
          ),
          onSubmitted: himno.numero != -1 && himno.numero > 517
              ? (String query) {
                  setState(() => done = !done);
                }
              : null,
          onChanged: onChanged,
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
        actions: <Widget>[
          IconButton(
            onPressed: himno.numero != -1
                ? () {
                    setState(() => done = !done);
                  }
                : null,
            icon: Icon(Icons.check),
          )
        ],
      ),
      body: (!cargando
          ? estrofas.isNotEmpty
              ? GestureDetector(
                  onTap: () => setState(() => done = !done),
                  child: Container(
                    height: double.infinity,
                    width: double.infinity,
                    color: Colors.transparent,
                    child: Column(
                      children: <Widget>[
                        HimnoText(
                          estrofas: estrofas,
                          fontSize: fontSize,
                          alignment: alignment,
                        )
                      ],
                    ),
                  ),
                )
              : himno.numero == -2
                  ? Center(
                      child: Text(
                        'Himno no encontrado',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Center(
                      child: Text(
                        'Ingrese el número del himno',
                        textAlign: TextAlign.center,
                        textScaleFactor: 1.5,
                      ),
                    )
          : Container()),
    );
  }

  Widget cupertinoLayout() {
    return CupertinoPageScaffold(
      backgroundColor: ScopedModel.of<TemaModel>(context).getScaffoldBackgroundColor(),
      navigationBar: CupertinoNavigationBar(
          // actionsForegroundColor: ScopedModel.of<TemaModel>(context).getTabTextColor(),
          backgroundColor: ScopedModel.of<TemaModel>(context).getTabBackgroundColor(),
          middle: Padding(
            padding: EdgeInsets.only(right: 0.0),
            child: CupertinoTextField(
              autofocus: true,
              keyboardType: TextInputType.number,
              cursorColor: Colors.black,
              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                    color: WidgetsBinding.instance.window.platformBrightness == Brightness.dark
                        ? Colors.black
                        : (ScopedModel.of<TemaModel>(context).brightness == Brightness.light ? null : Colors.black),
                    fontFamily: ScopedModel.of<TemaModel>(context).font,
                  ),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(50.0), color: Colors.white),
              suffix: Container(
                width: MediaQuery.of(context).size.width - 200,
                margin: EdgeInsets.only(right: 6.0),
                child: Text(
                  himno.titulo ?? '',
                  softWrap: false,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: WidgetsBinding.instance.window.platformBrightness == Brightness.dark
                        ? Colors.black
                        : (ScopedModel.of<TemaModel>(context).brightness == Brightness.light
                            ? CupertinoTheme.of(context).textTheme.textStyle.color
                            : Colors.black),
                    fontFamily: ScopedModel.of<TemaModel>(context).font,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              onSubmitted: himno.numero != -1 && himno.numero > 517
                  ? (String query) {
                      setState(() => done = !done);
                    }
                  : null,
              onChanged: onChanged,
            ),
          )),
      child: SafeArea(
        child: (!cargando
            ? estrofas.isNotEmpty
                ? GestureDetector(
                    onTap: () => setState(() => done = !done),
                    child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      color: Colors.transparent,
                      child: Column(
                        children: <Widget>[
                          HimnoText(
                            estrofas: estrofas,
                            fontSize: fontSize,
                            alignment: alignment,
                          )
                        ],
                      ),
                    ),
                  )
                : himno.numero == -2
                    ? Center(
                        child: Text(
                          'Himno no encontrado',
                          textAlign: TextAlign.center,
                          style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                              color: ScopedModel.of<TemaModel>(context).getScaffoldTextColor(), fontFamily: ScopedModel.of<TemaModel>(context).font),
                          textScaleFactor: 1.5,
                        ),
                      )
                    : Center(
                        child: Text(
                          'Ingrese el número del himno',
                          textAlign: TextAlign.center,
                          style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                              color: ScopedModel.of<TemaModel>(context).getScaffoldTextColor(), fontFamily: ScopedModel.of<TemaModel>(context).font),
                          textScaleFactor: 1.5,
                        ),
                      )
            : Container()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return done ? HimnoPage(titulo: himno.titulo, numero: himno.numero) : (isAndroid() ? materialLayout() : cupertinoLayout());
  }
}
