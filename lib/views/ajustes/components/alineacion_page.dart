import 'package:Himnario/helpers/isAndroid.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlineacionesPage extends StatefulWidget {
  @override
  AlineacionesPageState createState() => AlineacionesPageState();
}

class AlineacionesPageState extends State<AlineacionesPage> {
  List<List<dynamic>> alignments;
  SharedPreferences prefs;
  int value;

  // iOS specific
  int currentValue;

  @override
  void initState() {
    super.initState();
    alignments = [
      ['Izquierda', Icons.format_align_left],
      ['Centro', Icons.format_align_center],
      ['Derecha', Icons.format_align_right]
    ];
    initPrefs();
  }

  void initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {});
  }

  Widget materialLayout(BuildContext context) {
    List<Widget> botones = List<Widget>();
    if (prefs != null)
      for (int i = 0; i < alignments.length; ++i) {
        if (prefs.getString('alignment') == alignments[i][0]) value = i;
        if (prefs.getString('alignment') == null && i == 0) value = i;
        botones.add(InkWell(
          onTap: () {
            prefs.setString('alignment', alignments[i][0]);
            setState(() => value = i);
          },
          child: Row(
            children: <Widget>[
              Radio(
                onChanged: (int e) {
                  prefs.setString('alignment', alignments[i][0]);
                  setState(() => value = e);
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
    List<Widget> botones = List<Widget>();
    if (prefs != null)
      for (int i = 0; i < alignments.length; ++i) {
        if (prefs.getString('alignment') == alignments[i][0]) currentValue = i;
        if (prefs.getString('alignment') == null && i == 0) currentValue = i;

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
                      child: Icon(alignments[i][1],
                          color: WidgetsBinding.instance.window.platformBrightness == Brightness.dark ? Colors.white : Colors.black),
                    ),
                    Text(alignments[i][0],
                        style: TextStyle(color: WidgetsBinding.instance.window.platformBrightness == Brightness.dark ? Colors.white : Colors.black)),
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
        FlatButton(
          child: Text(
            'Cancelar',
            style: TextStyle(color: WidgetsBinding.instance.window.platformBrightness == Brightness.dark ? Colors.white : Colors.black),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        FlatButton(
          child: Text(
            'Guardar',
            style: TextStyle(color: WidgetsBinding.instance.window.platformBrightness == Brightness.dark ? Colors.white : Colors.black),
          ),
          onPressed: () {
            if (value != null) {
              prefs.setString('alignment', alignments[value][0]);
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
