import 'package:Himnario/api/api.dart';
import 'package:Himnario/helpers/isAndroid.dart';
import 'package:Himnario/models/tema.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/tema_page.dart';
import 'components/fuente_page.dart';
import 'components/alineacion_page.dart';
import 'package:path_provider/path_provider.dart';

class AjustesPage extends StatefulWidget {
  @override
  _AjustesPageState createState() => _AjustesPageState();
}

class _AjustesPageState extends State<AjustesPage> {
  SharedPreferences? prefs;
  int downloaded = -1;

  @override
  void initState() {
    super.initState();
    loadThemes();
    checkPartituras().then((ready) {
      if (ready) {
        setState(() => downloaded = 517);
      } else {
        setState(() => downloaded = -1);
      }
    });
  }

  void loadThemes() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {});
  }

  Future<bool> checkPartituras() async {
    setState(() => downloaded = -2);
    String path = (await getApplicationDocumentsDirectory()).path;
    for (int i = 1; i <= 517; ++i) {
      File aux = File(path + '/$i.jpg');
      if (!(await aux.exists())) {
        return false;
      }
    }
    return true;
  }

  Future<void> showDevModePasswordDialog(BuildContext context) async {
    final TextEditingController passwordController = TextEditingController();

    if (isAndroid()) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return _DevModePasswordDialog(
            passwordController: passwordController,
            isAndroid: true,
          );
        },
      );
    } else {
      await showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return _DevModePasswordDialog(
            passwordController: passwordController,
            isAndroid: false,
          );
        },
      );
    }
  }

  void downloadPartituras() async {
    String path = (await getApplicationDocumentsDirectory()).path;
    setState(() => downloaded = 0);
    for (int i = 1; i <= 517; ++i) {
      File aux = File(path + '/$i.jpg');
      if (!(await aux.exists())) {
        http.Response res = await http.get(Uri.parse(await SheetsApi.sheetAvailable(i)));
        if (res.statusCode == 200) {
          http.get(Uri.parse(await SheetsApi.getSheet(i))).then((image) async {
            await aux.writeAsBytes(image.bodyBytes);
            if (mounted) setState(() => downloaded += 1);
          });
        }
      } else {
        if (mounted) setState(() => downloaded += 1);
      }
    }
  }

  Widget materialLayout(BuildContext context) {
    TemaModel tema = ScopedModel.of<TemaModel>(context, rebuildOnChange: true);

    return Scaffold(
      appBar: AppBar(
        title: Text('Ajustes'),
        bottom: PreferredSize(preferredSize: Size.fromHeight(4.0), child: Container()),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.color_lens),
            title: Text('Colores'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => TemasPage(),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.text_fields),
            title: Text('Fuente'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => FuentesPage(),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.format_align_center),
            title: Text('Alineación'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => AlineacionesPage(),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.music_note),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Entrar a partitura por defecto'),
                Text(
                  'Cuando esté disponible',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
            trailing: Switch(
              value: tema.showMusicSheetByDefault,
              onChanged: (bool value) {
                tema.setShowMusicSheetByDefault(value);
              },
            ),
          ),
          ListTile(
            leading: Icon(Icons.music_note),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Activar acordes por defecto'),
                Text(
                  'Cuando esté disponible',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
            trailing: Switch(
              value: tema.showChordsByDefault,
              onChanged: (bool value) {
                tema.setShowChordsByDefault(value);
              },
            ),
          ),
          ListTile(
            leading: downloaded == -2 || (downloaded < 517 && downloaded > -1)
                ? SizedBox(
                    height: 25,
                    width: 25,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                    ),
                  )
                : Icon(downloaded < 517 ? Icons.cloud_download : Icons.cloud_done),
            title: Text((downloaded < 517 && downloaded > -1)
                ? 'Descargando partituras'
                : downloaded <= -1
                    ? 'Descargar todas las partituras'
                    : 'Partituras ya descargadas'),
            trailing: SizedBox(
              height: 30,
              width: 30,
              child: downloaded < 517 && downloaded != -1 && downloaded != -2
                  ? Stack(
                      children: <Widget>[
                        CircularProgressIndicator(
                          strokeWidth: 1.5,
                          value: downloaded / 517,
                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            '${(downloaded / 517 * 100).floor()}%',
                            textScaleFactor: 0.5,
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
            onTap: downloaded < 517 ? downloadPartituras : null,
          ),
          prefs?.getBool('dev_mode') == true
              ? ListTile(
                  leading: Icon(Icons.developer_mode),
                  title: Text('Deshabilitar modo desarrollador'),
                  onTap: () {
                    SharedPreferences.getInstance().then((prefs) {
                      setState(() {
                        prefs.setBool('dev_mode', false);
                      });
                    });
                  },
                )
              : ListTile(
                  leading: Icon(Icons.developer_mode),
                  title: Text('Habilitar modo desarrollador'),
                  onTap: () async {
                    await showDevModePasswordDialog(context);
                    setState(() {});
                  },
                ),
        ],
      ),
    );
  }

  Widget cupertinoLayout(BuildContext context) {
    final TemaModel tema = ScopedModel.of<TemaModel>(context, rebuildOnChange: true);

    List<Widget> botonDescarga = [
      // Expanded(
      //   child: Container(),
      // ),
      downloaded == -2 || (downloaded < 517 && downloaded > -1)
          ? SizedBox(height: 24, width: 24, child: CupertinoActivityIndicator())
          : Icon(
              downloaded < 517 ? Icons.cloud_download : Icons.cloud_done,
              color: tema.getScaffoldTextColor(),
            ),
      SizedBox(
        width: 10.0,
      ),
      Text(
          (downloaded < 517 && downloaded > -1)
              ? 'Descargando partituras'
              : downloaded <= -1
                  ? 'Descargar todas las partituras'
                  : 'Partituras ya descargadas',
          style: CupertinoTheme.of(context)
              .textTheme
              .textStyle
              .copyWith(color: tema.getScaffoldTextColor(), fontFamily: ScopedModel.of<TemaModel>(context, rebuildOnChange: true).font)),
    ];

    if (downloaded < 517 && downloaded != -1 && downloaded != -2) {
      botonDescarga.addAll([
        Padding(
          padding: EdgeInsets.only(left: 20.0),
          child: SizedBox(
            height: 20,
            width: 20,
            child: Stack(
              children: <Widget>[
                // CircularProgressIndicator(
                //   strokeWidth: 1.5,
                //   value: downloaded / 517,
                //   valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                // ),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: LinearProgressIndicator(
                      value: downloaded / 517,
                      backgroundColor: Colors.grey[400],
                      valueColor: AlwaysStoppedAnimation<Color>(tema.getScaffoldTextColor()),
                    )),
                Align(
                  alignment: Alignment.topCenter,
                  child: Text('${(downloaded / 517 * 100).floor()}%',
                      textScaleFactor: 0.5,
                      style: CupertinoTheme.of(context)
                          .textTheme
                          .textStyle
                          .copyWith(color: tema.getScaffoldTextColor(), fontFamily: ScopedModel.of<TemaModel>(context, rebuildOnChange: true).font)),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(),
        ),
      ]);
    } else {
      botonDescarga.add(
        Expanded(
          child: Container(),
        ),
      );
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: tema.getAccentColor(),
        middle: Text(
          'Ajustes',
          style: TextStyle(
            color: tema.getAccentColorText(),
            fontFamily: tema.font,
          ),
        ),
      ),
      child: ListView(
        children: <Widget>[
          CupertinoButton(
            onPressed: () {
              showCupertinoDialog(
                  context: context,
                  builder: (BuildContext context) => ScopedModel<TemaModel>(
                        model: tema,
                        child: TemasPage(),
                      ));
            },
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.color_lens,
                  color: tema.getScaffoldTextColor(),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Text('Colores',
                    style: CupertinoTheme.of(context)
                        .textTheme
                        .textStyle
                        .copyWith(color: tema.getScaffoldTextColor(), fontFamily: ScopedModel.of<TemaModel>(context, rebuildOnChange: true).font)),
              ],
            ),
          ),
          CupertinoButton(
            onPressed: () {
              showCupertinoDialog(
                  context: context,
                  builder: (BuildContext context) => ScopedModel<TemaModel>(
                        model: tema,
                        child: FuentesPage(),
                      ));
            },
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.text_fields,
                  color: tema.getScaffoldTextColor(),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Text('Fuente',
                    style: CupertinoTheme.of(context)
                        .textTheme
                        .textStyle
                        .copyWith(color: tema.getScaffoldTextColor(), fontFamily: ScopedModel.of<TemaModel>(context, rebuildOnChange: true).font)),
              ],
            ),
          ),
          CupertinoButton(
            onPressed: () {
              showCupertinoDialog(
                  context: context,
                  builder: (BuildContext context) => ScopedModel<TemaModel>(
                        model: tema,
                        child: AlineacionesPage(),
                      ));
            },
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.format_align_center,
                  color: tema.getScaffoldTextColor(),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Text('Alineación',
                    style: CupertinoTheme.of(context)
                        .textTheme
                        .textStyle
                        .copyWith(color: tema.getScaffoldTextColor(), fontFamily: ScopedModel.of<TemaModel>(context, rebuildOnChange: true).font)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.music_note,
                  color: tema.getScaffoldTextColor(),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Entrar a partitura por defecto',
                          style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                              color: tema.getScaffoldTextColor(), fontFamily: ScopedModel.of<TemaModel>(context, rebuildOnChange: true).font)),
                      Text('Cuando esté disponible',
                          style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                                color: tema.brightness == Brightness.dark ? CupertinoColors.systemGrey : CupertinoColors.systemGrey2,
                                fontSize: 12,
                                fontFamily: ScopedModel.of<TemaModel>(context, rebuildOnChange: true).font,
                              )),
                    ],
                  ),
                ),
                CupertinoSwitch(
                  value: tema.showMusicSheetByDefault,
                  onChanged: (bool value) {
                    tema.setShowMusicSheetByDefault(value);
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.music_note,
                  color: tema.getScaffoldTextColor(),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Activar acordes por defecto',
                          style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                              color: tema.getScaffoldTextColor(), fontFamily: ScopedModel.of<TemaModel>(context, rebuildOnChange: true).font)),
                      Text('Cuando esté disponible',
                          style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                                color: tema.brightness == Brightness.dark ? CupertinoColors.systemGrey : CupertinoColors.systemGrey2,
                                fontSize: 12,
                                fontFamily: ScopedModel.of<TemaModel>(context, rebuildOnChange: true).font,
                              )),
                    ],
                  ),
                ),
                CupertinoSwitch(
                  value: tema.showChordsByDefault,
                  onChanged: (bool value) {
                    tema.setShowChordsByDefault(value);
                  },
                ),
              ],
            ),
          ),
          CupertinoButton(
            onPressed: downloaded < 517 ? downloadPartituras : null,
            child: Row(children: botonDescarga),
          ),
          prefs?.getBool('dev_mode') == true
              ? CupertinoButton(
                  onPressed: () {
                    SharedPreferences.getInstance().then((prefs) {
                      setState(() {
                        prefs.setBool('dev_mode', false);
                      });
                    });
                  },
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.developer_mode,
                        color: tema.getScaffoldTextColor(),
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Text('Deshabilitar modo desarrollador',
                          style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                              color: tema.getScaffoldTextColor(), fontFamily: ScopedModel.of<TemaModel>(context, rebuildOnChange: true).font)),
                    ],
                  ),
                )
              : CupertinoButton(
                  onPressed: () async {
                    await showDevModePasswordDialog(context);
                    setState(() {});
                  },
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.developer_mode,
                        color: tema.getScaffoldTextColor(),
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Text('Habilitar modo desarrollador',
                          style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                              color: tema.getScaffoldTextColor(), fontFamily: ScopedModel.of<TemaModel>(context, rebuildOnChange: true).font)),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAndroid() ? materialLayout(context) : cupertinoLayout(context);
  }
}

class _DevModePasswordDialog extends StatefulWidget {
  final TextEditingController passwordController;
  final bool isAndroid;

  const _DevModePasswordDialog({
    required this.passwordController,
    required this.isAndroid,
  });

  @override
  _DevModePasswordDialogState createState() => _DevModePasswordDialogState();
}

class _DevModePasswordDialogState extends State<_DevModePasswordDialog> {
  bool incorrectPassword = false;

  Future<void> confirmarHandler() async {
    if (widget.passwordController.text != 'D3VM0D3H1MN4R10') {
      setState(() => incorrectPassword = true);
      return;
    }

    await SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('dev_mode', true);
    });

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isAndroid) {
      return AlertDialog(
        title: Text('Habilitar modo desarrollador'),
        content: TextField(
          controller: widget.passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Contraseña',
            hintText: 'Ingrese la contraseña',
            errorText: incorrectPassword ? 'Contraseña incorrecta' : null,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Confirmar'),
            onPressed: confirmarHandler,
          ),
        ],
      );
    } else {
      final TemaModel tema = ScopedModel.of<TemaModel>(context);

      return CupertinoAlertDialog(
        title: Text('Habilitar modo desarrollador'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (incorrectPassword)
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Contraseña incorrecta',
                  style: TextStyle(color: CupertinoColors.systemRed, fontSize: 13),
                ),
              ),
            Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: CupertinoTextField(
                controller: widget.passwordController,
                obscureText: true,
                placeholder: 'Ingrese la contraseña',
                cursorColor: tema.brightness == Brightness.light ? Colors.black : Colors.white,
                style: TextStyle(
                  color: tema.brightness == Brightness.light ? Colors.black : Colors.white,
                  fontFamily: tema.font,
                ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          CupertinoDialogAction(
            child: Text('Confirmar'),
            isDefaultAction: true,
            onPressed: confirmarHandler,
          ),
        ],
      );
    }
  }
}
