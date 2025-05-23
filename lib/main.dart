import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Himnario/helpers/isAndroid.dart';
import 'package:Himnario/models/tema.dart';
import 'package:Himnario/views/main/mainPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? mainColor = prefs.getInt('mainColor');
  String font = prefs.getString('font') ?? 'Merriweather';
  bool dark = prefs.getString('brightness') == Brightness.dark.toString() ? true : false;
  // String fontFamily = prefs.getString('fuente') ?? 'Merriweather';
  if (['Raleway', '.SF Pro Text'].contains(font)) font = 'Merriweather';

  String alignment = prefs.getString('alignment') ?? 'Izquierda';

  TemaModel tema = TemaModel()
    ..setMainColor(mainColor != null ? Color(mainColor) : Colors.black)
    ..setFont(font)
    ..setBrightness(dark ? Brightness.dark : Brightness.light)
    ..setAlignment(TemaAlignment.values.firstWhere((e) => e.name == alignment));

  runApp(ScopedModel<TemaModel>(
    model: tema,
    child: MyApp(),
  ));
}

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

class MyApp extends StatelessWidget {
  // final TemaModel tema;

  // MyApp({required this.tema});

  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TemaModel tema = TemaModel.of(context, rebuildOnChange: true);

    return isAndroid()
        ? MaterialApp(
            // debugShowCheckedModeBanner: false,
            // showSemanticsDebugger: false,
            theme: ThemeData(
              // primaryColor: tema.getAccentColor(),
              appBarTheme: AppBarTheme(
                color: tema.getAccentColor(),
                foregroundColor: tema.getAccentColorText(),
                scrolledUnderElevation: 0.0,
              ),
              primaryColor: tema.getAccentColor(),
              fontFamily: tema.font,
              // scaffoldBackgroundColor: ,
              // drawerTheme: DrawerThemeData(
              //     backgroundColor: tema.getScaffoldBackgroundColor(),
              // ),
              // listTileTheme: ListTileThemeData(tileColor: getColorShade(tema.getAccentColor(), 0.05)),
              // scaffoldBackgroundColor: getColorShade(tema.getAccentColor(), 0.02),
              textSelectionTheme: TextSelectionThemeData(
                // selectionColor: tema.getAccentColor(),
                selectionHandleColor: tema.getScaffoldAccentColor(),
                // cursorColor: tema.getAccentColor(),
              ),
              scaffoldBackgroundColor: tema.getScaffoldBackgroundColor(),
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                backgroundColor: tema.getAccentColor(),
                selectedItemColor: tema.getAccentColorText(),
                selectedIconTheme: IconThemeData(opacity: 1.0),
                unselectedItemColor: tema.getAccentColorText().withOpacity(0.6),
                unselectedIconTheme: IconThemeData(size: 20.0, opacity: 0.7),
              ),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                foregroundColor: tema.getAccentColorText(),
                backgroundColor: tema.getAccentColor(),
              ),
              // listTileTheme: ListTileThemeData(
              //   iconColor: tema.getScaffoldTextColor(),
              //   textColor: tema.getScaffoldTextColor(),
              //   // selectedColor: tema.getScaffoldTextColor(),
              //   tileColor: tema.getListTileColor(),
              //   selectedTileColor: tema.getScaffoldAccentColor(),
              // ),
              drawerTheme: DrawerThemeData(
                backgroundColor: tema.getScaffoldBackgroundColor(),
              ),
              snackBarTheme: SnackBarThemeData(
                backgroundColor: tema.getAccentColor(),
                actionBackgroundColor: tema.getAccentColor(),
                actionTextColor: tema.getAccentColorText(),
                closeIconColor: tema.getAccentColorText(),
                contentTextStyle: TextStyle(
                  fontFamily: tema.font,
                  color: tema.getAccentColorText(),
                ),
              ),
              brightness: tema.brightness,
              primarySwatch: MaterialColor(
                tema.getAccentColor().value,
                <int, Color>{
                  50: Color(tema.getAccentColor().value),
                  100: Color(tema.getAccentColor().value),
                  200: Color(tema.getAccentColor().value),
                  300: Color(tema.getAccentColor().value),
                  400: Color(tema.getAccentColor().value),
                  500: Color(tema.getAccentColor().value),
                  600: Color(tema.getAccentColor().value),
                  700: Color(tema.getAccentColor().value),
                  800: Color(tema.getAccentColor().value),
                  900: Color(tema.getAccentColor().value),
                },
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: tema.getAccentColor(),
                  foregroundColor: tema.getAccentColorText(),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                  // backgroundColor: tema.getAccentColor(),
                  foregroundColor: tema.getScaffoldAccentColor(),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: tema.getAccentColor()),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: tema.getScaffoldAccentColor(),
                ),
              ),
            ),
            navigatorObservers: [routeObserver],
            title: 'Himnos y Cánticos del Evangelio',
            home: MainPage(),
          )
        : CupertinoApp(
            // debugShowCheckedModeBanner: false,
            navigatorObservers: [routeObserver],
            theme: CupertinoThemeData(
              primaryColor: tema.getAccentColor(),
              brightness: tema.brightness,
              barBackgroundColor: tema.getAccentColor(),
              scaffoldBackgroundColor: tema.getScaffoldBackgroundColor(),
              textTheme: CupertinoTextThemeData(
                actionTextStyle: TextStyle(fontFamily: tema.font),
                navLargeTitleTextStyle: TextStyle(fontFamily: tema.font),
                navActionTextStyle: TextStyle(fontFamily: tema.font, color: tema.getAccentColorText()),
                dateTimePickerTextStyle: TextStyle(fontFamily: tema.font),
                pickerTextStyle: TextStyle(fontFamily: tema.font, color: tema.getScaffoldTextColor()),
                navTitleTextStyle: TextStyle(
                  fontFamily: tema.font,
                  color: tema.getAccentColorText(),
                ),
                tabLabelTextStyle: TextStyle(fontFamily: tema.font),
                textStyle: TextStyle(fontFamily: tema.font),
              ),
            ),
            title: 'Himnos y Cánticos del Evangelio',
            home: MainPage(),
          );
  }
}
