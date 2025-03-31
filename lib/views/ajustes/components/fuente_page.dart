import 'dart:convert';

import 'package:Himnario/helpers/isAndroid.dart';
import 'package:Himnario/models/tema.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FuentesPage extends StatefulWidget {
  @override
  _FuentesPageState createState() => _FuentesPageState();
}

class _FuentesPageState extends State<FuentesPage> {
  List<String> fuentes = [
    'Josefin Sans',
    'Lato',
    'Merriweather',
    'Montserrat',
    'Open Sans',
    'Poppins',
    'Roboto',
    'Roboto Mono',
    'Rubik',
    'Source Sans Pro'
  ];
  SharedPreferences? prefs;

  int? value;
  int? currentValue;

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < fuentes.length; ++i) {
      if (TemaModel.of(context, rebuildOnChange: false).font == fuentes[i]) {
        currentValue = i;
      }
    }

    SharedPreferences.getInstance().then((prefsInstance) => prefs = prefsInstance);
  }

  Widget materialLayout(BuildContext context) {
    List<Widget> botones = [];
    for (int i = 0; i < fuentes.length; ++i) {
      // if (Theme.of(context).textTheme.title.fontFamily == fuentes[i]) {
      //   value = i;
      // }
      botones.add(InkWell(
        onTap: () => setState(() => value = i),
        child: Row(
          children: <Widget>[
            Radio(
              onChanged: (int? e) {
                if (e != null) setState(() => value = e);
              },
              groupValue: value,
              value: i,
            ),
            Text(
              fuentes[i],
              style: TextStyle(fontFamily: fuentes[i]),
            )
          ],
        ),
      ));
    }
    return SimpleDialog(title: Text('Seleccionar Fuente'), children: botones);
  }

  Widget cupertinoLayout(BuildContext context) {
    List<Widget> botones = [];
    for (int i = 0; i < fuentes.length; ++i) {
      botones.add(CupertinoButton(
          onPressed: () => setState(() => value = i),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                fuentes[i],
                style: TextStyle(
                    fontFamily: fuentes[i],
                    color: WidgetsBinding.instance.window.platformBrightness == Brightness.dark ? Colors.white : Colors.black),
              ),
              IgnorePointer(
                child: CupertinoSwitch(
                  onChanged: (e) => e,
                  value: value == null ? currentValue == i : value == i,
                ),
              )
            ],
          )));
    }
    return CupertinoAlertDialog(
      title: Text('Seleccionar Fuente'),
      content: SingleChildScrollView(
        child: Column(
          children: botones,
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            'Cancelar',
            style: TemaModel.of(context).getButtonTextStyle(context),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text(
            'Guardar',
            style: TemaModel.of(context).getButtonTextStyle(context),
          ),
          onPressed: () {
            if (value != null) {
              ScopedModel.of<TemaModel>(context).setFont(fuentes[value!]);
              prefs!.setString('font', fuentes[value!]);
            }
            setState(() {});
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAndroid() ? materialLayout(context) : cupertinoLayout(context);
  }
}
