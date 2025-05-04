import 'package:Himnario/helpers/isAndroid.dart';
import 'package:Himnario/models/tema.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlineacionesPage extends StatefulWidget {
  @override
  AlineacionesPageState createState() => AlineacionesPageState();
}

class AlineacionesPageState extends State<AlineacionesPage> {
  List<List<dynamic>> alignments = [
    ['Izquierda', Icons.format_align_left, TemaAlignment.Izquierda],
    ['Centro', Icons.format_align_center, TemaAlignment.Centro],
    ['Derecha', Icons.format_align_right, TemaAlignment.Derecha],
  ];
  // SharedPreferences? prefs;

  int? value;
  int? currentValue;

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  void initPrefs() async {
    // prefs = await SharedPreferences.getInstance();
    setState(() {});
  }

  Widget materialLayout(BuildContext context) {
    final tema = TemaModel.of(context);

    List<Widget> botones = [];
    for (int i = 0; i < alignments.length; ++i) {
      if (tema.alignment == alignments[i][2]) value = i;
      botones.add(InkWell(
        onTap: () {
          tema.setAlignment(alignments[i][2]);
          // prefs!.setString('alignment', alignments[i][0]);
          setState(() => value = i);
        },
        child: Row(
          children: <Widget>[
            Radio(
              onChanged: (int? e) {
                if (e != null) {
                  tema.setAlignment(alignments[i][2]);
                  // prefs!.setString('alignment', alignments[i][0]);
                  setState(() => value = e);
                }
              },
              groupValue: value,
              value: i,
            ),
            Icon(alignments[i][1]),
            Padding(
              padding: EdgeInsets.only(left: 10.0),
            ),
            Text(alignments[i][0]),
          ],
        ),
      ));
    }

    return SimpleDialog(title: Text('Seleccionar Alineación'), children: botones);
  }

  Widget cupertinoLayout(BuildContext context) {
    final tema = TemaModel.of(context);

    List<Widget> botones = [];

    for (int i = 0; i < alignments.length; ++i) {
      if (tema.alignment == alignments[i][2]) currentValue = i;
      // if (prefs!.getString('alignment') == null && i == 0) currentValue = i;

      botones.add(CupertinoButton(
          onPressed: () => setState(() => value = i),
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
                      alignments[i][1],
                      color: tema.getScaffoldTextColor(),
                    ),
                  ),
                  Text(
                    alignments[i][0],
                    style: TextStyle(
                      color: tema.getScaffoldTextColor(),
                    ),
                  ),
                ],
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
      title: Text('Seleccionar Alineación'),
      content: SingleChildScrollView(
        child: Column(
          children: botones,
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            'Cancelar',
            style: TextStyle(
              color: tema.getScaffoldTextColor(),
              fontFamily: tema.font,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
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
            if (value != null) {
              // prefs!.setString('alignment', alignments[value!][0]);
              tema.setAlignment(alignments[value!][2]);
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
