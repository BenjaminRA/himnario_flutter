import 'package:Himnario/helpers/isAndroid.dart';
import 'package:Himnario/models/tema.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class BotonVoz extends StatelessWidget {
  final bool activo;
  final String voz;
  final void Function() onPressed;
  final Color mainColor;
  final Color mainColorContrast;

  BotonVoz({
    required this.voz,
    this.activo = false,
    required this.onPressed,
    required this.mainColor,
    required this.mainColorContrast,
  });

  Widget materialLayout(BuildContext context) {
    return !activo
        ? OutlinedButton(
            // style: ButtonStyle(
            //   backgroundColor: WidgetStatePropertyAll(TemaModel.of(context).getAccentColor()),
            // ),
            child: Text(
              voz,
              // style: TextStyle(
              //   fontFamily: !isAndroid() ? ScopedModel.of<TemaModel>(context).font : null,
              //   color: TemaModel.of(context).getAccentColorText(),
              // ),
            ),
            onPressed: onPressed,
          )
        : ElevatedButton(
            // style: ButtonStyle(
            //   backgroundColor: WidgetStatePropertyAll(TemaModel.of(context).getAccentColor()),
            // ),
            child: Text(
              voz,
              // style: TextStyle(
              //   fontFamily: !isAndroid() ? ScopedModel.of<TemaModel>(context).font : null,
              //   color: TemaModel.of(context).getAccentColorText(),
              // ),
            ),
            onPressed: onPressed,
          );
  }

  Widget cupertinoLayout(BuildContext context) {
    return ScopedModelDescendant(
      builder: (BuildContext context, Widget? child, TemaModel tema) => !activo
          ? Container(
              height: 40.0,
              width: 120.0,
              margin: EdgeInsets.symmetric(vertical: 5.0),
              child: CupertinoButton(
                color: CupertinoTheme.of(context).scaffoldBackgroundColor,
                padding: EdgeInsets.symmetric(horizontal: 0.0),
                child: Text(
                  voz,
                  style: TextStyle(fontFamily: tema.font, color: Colors.black),
                ),
                onPressed: onPressed,
              ),
            )
          : Container(
              height: 40.0,
              width: 120.0,
              margin: EdgeInsets.symmetric(vertical: 5.0),
              child: CupertinoButton(
                color: mainColor,
                padding: EdgeInsets.symmetric(horizontal: 0.0),
                child: Text(
                  voz,
                  style: TextStyle(fontFamily: tema.font, color: mainColorContrast),
                ),
                onPressed: onPressed,
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAndroid() ? materialLayout(context) : cupertinoLayout(context);
  }
}
