import 'dart:convert';

import 'package:Himnario/helpers/isAndroid.dart';
import 'package:Himnario/models/tema.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TemasPage extends StatefulWidget {
  @override
  _TemasPageState createState() => _TemasPageState();
}

class _TemasPageState extends State<TemasPage> {
  // List<String> temasNombre;
  // List<ThemeData> temasTema;
  int? value;
  late Color originalColor;
  late Color pickerColor;

  late bool dark;
  late bool originalDark;

  @override
  void initState() {
    super.initState();

    // Brightness
    dark = TemaModel.of(context, rebuildOnChange: false).brightness == Brightness.dark ? true : false;
    originalDark = dark;

    // Color
    pickerColor = TemaModel.of(context, rebuildOnChange: false).mainColor;
    originalColor = pickerColor;
  }

  Widget materialLayout(BuildContext context) {
    final tema = TemaModel.of(context);

    List<Widget> _buttons = [];
    if (MediaQuery.of(context).size.width > 400)
      _buttons.addAll(
        [
          GestureDetector(
            onTap: () {
              dark = !dark;
              Brightness brightness = dark ? Brightness.dark : Brightness.light;
              tema.setBrightness(brightness);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Checkbox(
                  value: dark,
                  onChanged: (bool? value) {
                    if (value != null) {
                      dark = !dark;
                      Brightness brightness = dark ? Brightness.dark : Brightness.light;
                      tema.setBrightness(brightness);
                    }
                  },
                ),
                Text('Tema Oscuro')
              ],
            ),
          ),
          Divider(),
          TextButton(
            child: Text('Cancelar'),
            onPressed: () {
              tema.setMainColor(originalColor);
              tema.setBrightness(originalDark ? Brightness.dark : Brightness.light);
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Guardar'),
            onPressed: () {
              Brightness brightness = dark ? Brightness.dark : Brightness.light;
              tema.setMainColor(pickerColor);
              tema.setBrightness(brightness);

              // prefs!.setInt('mainColor', pickerColor.value);
              // prefs!.setString('brightness', brightness.toString());
              print((pickerColor.red * 0.299 + pickerColor.green * 0.587 + pickerColor.blue * 0.114));

              setState(() {});
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    else
      _buttons.add(
        Container(
          margin: EdgeInsets.only(right: MediaQuery.of(context).size.width / 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  dark = !dark;
                  Brightness brightness = dark ? Brightness.dark : Brightness.light;
                  tema.setBrightness(brightness);
                },
                child: SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Checkbox(
                        value: dark,
                        onChanged: (bool? value) {
                          dark = !dark;
                          Brightness brightness = dark ? Brightness.dark : Brightness.light;
                          tema.setBrightness(brightness);
                        },
                      ),
                      Text('Tema Oscuro'),
                    ],
                  ),
                ),
              ),
              Container(
                // margin: EdgeInsets.only(left: 20.0),
                child: TextButton(
                  child: Text('Cancelar'),
                  onPressed: () {
                    tema.setMainColor(originalColor);
                    tema.setBrightness(originalDark ? Brightness.dark : Brightness.light);
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Container(
                // margin: EdgeInsets.only(left: 20.0),
                child: TextButton(
                  child: Text('Guardar'),
                  onPressed: () {
                    Brightness brightness = dark ? Brightness.dark : Brightness.light;
                    tema.setMainColor(pickerColor);
                    tema.setBrightness(brightness);

                    // prefs!.setInt('mainColor', pickerColor.value);
                    // prefs!.setString('brightness', brightness.toString());
                    print((pickerColor.red * 0.299 + pickerColor.green * 0.587 + pickerColor.blue * 0.114));

                    setState(() {});
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    return AlertDialog(
      contentPadding: EdgeInsets.all(0.0),
      actions: _buttons,
      content: MaterialPicker(
        pickerColor: pickerColor,
        onColorChanged: (Color color) => setState(() {
          pickerColor = color;
          tema.setMainColor(color);
        }),
      ),
    );
  }

  Widget cupertinoLayout(BuildContext context) {
    final tema = TemaModel.of(context);

    return CupertinoAlertDialog(
      actions: <Widget>[
        Column(
          children: <Widget>[
            CupertinoButton(
              onPressed: () => setState(() {
                dark = !dark;
                Brightness brightness = dark ? Brightness.dark : Brightness.light;
                ScopedModel.of<TemaModel>(context).setBrightness(brightness);
              }),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(right: 10.0),
                        child: Icon(
                          CupertinoIcons.brightness,
                          color: tema.getScaffoldTextColor(),
                        ),
                      ),
                      Text('Tema Oscuro',
                          style: TextStyle(
                            color: tema.getScaffoldTextColor(),
                          )),
                    ],
                  ),
                  IgnorePointer(
                    child: CupertinoSwitch(
                      onChanged: (e) => e,
                      value: dark ?? false,
                    ),
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                TextButton(
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      color: tema.getScaffoldTextColor(),
                      fontFamily: tema.font,
                    ),
                  ),
                  onPressed: () {
                    tema.setMainColor(originalColor);
                    tema.setBrightness(originalDark ? Brightness.dark : Brightness.light);
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(
                    'Guardar',
                    style: TextStyle(
                      color: tema.getScaffoldTextColor(),
                      fontFamily: tema.font,
                    ),
                  ),
                  onPressed: () {
                    Brightness brightness = dark ? Brightness.dark : Brightness.light;
                    tema.setMainColor(pickerColor);
                    tema.setBrightness(brightness);

                    // prefs!.setInt('mainColor', pickerColor.value);
                    // prefs!.setString('brightness', brightness.toString());
                    print((pickerColor.red * 0.299 + pickerColor.green * 0.587 + pickerColor.blue * 0.114));

                    setState(() {});
                    Navigator.of(context).pop();
                  },
                ),
              ],
            )
          ],
        )
      ],
      content: Container(
        height: 440.0,
        child: MaterialPicker(
          pickerColor: pickerColor,
          onColorChanged: (Color color) => setState(() {
            pickerColor = color;
            ScopedModel.of<TemaModel>(context).setMainColor(color);
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAndroid() ? materialLayout(context) : cupertinoLayout(context);
  }
}
