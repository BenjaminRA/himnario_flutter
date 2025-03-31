import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Himnario/helpers/isAndroid.dart';
import 'package:Himnario/views/main/mainPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  late ThemeData tema;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? mainColor = prefs.getInt('mainColor');
  String? font = prefs.getString('font');
  bool dark = prefs.getString('brightness') == Brightness.dark.toString() ? true : false;
  String fontFamily = prefs.getString('fuente') ?? 'Merriweather';
  if (['Raleway', '.SF Pro Text'].contains(fontFamily)) fontFamily = 'Merriweather';

  if (isAndroid()) {
    String? temaJson = prefs.getString('temaPrincipal');
    if (temaJson == null)
      tema = ThemeData(
        primarySwatch: MaterialColor(Colors.black.value, {
          50: Color.fromRGBO(Colors.black.red, Colors.black.green, Colors.black.blue, .1),
          100: Color.fromRGBO(Colors.black.red, Colors.black.green, Colors.black.blue, .2),
          200: Color.fromRGBO(Colors.black.red, Colors.black.green, Colors.black.blue, .3),
          300: Color.fromRGBO(Colors.black.red, Colors.black.green, Colors.black.blue, .4),
          400: Color.fromRGBO(Colors.black.red, Colors.black.green, Colors.black.blue, .5),
          500: Color.fromRGBO(Colors.black.red, Colors.black.green, Colors.black.blue, .6),
          600: Color.fromRGBO(Colors.black.red, Colors.black.green, Colors.black.blue, .7),
          700: Color.fromRGBO(Colors.black.red, Colors.black.green, Colors.black.blue, .8),
          800: Color.fromRGBO(Colors.black.red, Colors.black.green, Colors.black.blue, .9),
          900: Color.fromRGBO(Colors.black.red, Colors.black.green, Colors.black.blue, 1),
        }),
        fontFamily: prefs.getString('fuente') ?? 'Merriweather',
      );
    else {
      Map<dynamic, dynamic> json = jsonDecode(temaJson);
      tema = ThemeData(
        brightness: dark ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: dark ? Colors.black : null,
        cardColor: dark ? Color.fromRGBO(33, 33, 33, 1) : null,
        primarySwatch: MaterialColor(json['value'], {
          50: Color.fromRGBO(json['red'], json['green'], json['blue'], .1),
          100: Color.fromRGBO(json['red'], json['green'], json['blue'], .2),
          200: Color.fromRGBO(json['red'], json['green'], json['blue'], .3),
          300: Color.fromRGBO(json['red'], json['green'], json['blue'], .4),
          400: Color.fromRGBO(json['red'], json['green'], json['blue'], .5),
          500: Color.fromRGBO(json['red'], json['green'], json['blue'], .6),
          600: Color.fromRGBO(json['red'], json['green'], json['blue'], .7),
          700: Color.fromRGBO(json['red'], json['green'], json['blue'], .8),
          800: Color.fromRGBO(json['red'], json['green'], json['blue'], .9),
          900: Color.fromRGBO(json['red'], json['green'], json['blue'], 1),
        }),
        fontFamily: prefs.getString('fuente') ?? 'Merriweather',
      );

      tema = tema.copyWith(
        colorScheme: tema.colorScheme.copyWith(
          secondary: dark ? Color.fromRGBO(json['red'], json['green'], json['blue'], 1) : null,
        ),
      );
    }
  }

  runApp(
    MyApp(
      tema: tema,
      mainColor: mainColor,
      font: font,
      brightness: dark ? Brightness.dark : Brightness.light,
    ),
  );
}

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

class MyApp extends StatelessWidget {
  MyApp({required this.tema, this.mainColor, this.font, required this.brightness});

  final ThemeData tema;
  final int? mainColor;
  final String? font;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    return isAndroid()
        ? MaterialApp(
            // debugShowCheckedModeBanner: false,
            // showSemanticsDebugger: false,
            navigatorObservers: [routeObserver],
            title: 'Himnos y Cánticos del Evangelio',
            theme: tema,
            home: MainPage(mainColor: mainColor, font: font, brightness: brightness),
          )
        : CupertinoApp(
            // debugShowCheckedModeBanner: false,
            navigatorObservers: [routeObserver],
            theme: CupertinoThemeData(
              primaryColor: Colors.black,
            ),
            title: 'Himnos y Cánticos del Evangelio',
            home: MainPage(mainColor: mainColor, font: font, brightness: brightness),
          );
  }
}
