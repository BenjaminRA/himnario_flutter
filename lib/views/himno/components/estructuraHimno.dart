import 'package:Himnario/helpers/isAndroid.dart';
import 'package:Himnario/models/himnos.dart';
import 'package:Himnario/models/tema.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class HimnoText extends StatelessWidget {
  final TemaAlignment alignment;
  final List<Parrafo> estrofas;
  final double fontSize;

  HimnoText({
    required this.estrofas,
    required this.fontSize,
    this.alignment = TemaAlignment.Izquierda,
  });

  @override
  Widget build(BuildContext context) {
    final tema = TemaModel.of(context);

    TextAlign align;
    switch (alignment) {
      case TemaAlignment.Izquierda:
        align = TextAlign.left;
        break;
      case TemaAlignment.Centro:
        align = TextAlign.center;
        break;
      case TemaAlignment.Derecha:
        align = TextAlign.right;
        break;
      default:
        align = TextAlign.left;
    }
    List<TextSpan> parrafos = [];
    for (Parrafo parrafo in estrofas) {
      if (parrafo.coro)
        parrafos.addAll([
          TextSpan(
            text: 'Coro\n',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w300,
              fontSize: fontSize,
            ),
          ),
          TextSpan(
            text: parrafo.parrafo + '\n\n',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: fontSize,
            ),
          )
        ]);
      else
        parrafos.addAll([
          TextSpan(
            text: '${parrafo.orden}  ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
          TextSpan(
            text: parrafo.parrafo + '\n\n',
            style: TextStyle(
              fontSize: fontSize,
            ),
          )
        ]);
    }

    return isAndroid()
        ? Container(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            child: Center(
              child: RichText(
                textDirection: TextDirection.ltr,
                textAlign: align,
                text: TextSpan(
                  style: TextStyle(
                    color: tema.getScaffoldTextColor(),
                    fontFamily: tema.font,
                  ),
                  children: parrafos,
                ),
              ),
            ),
          )
        : Container(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            child: Center(
              child: RichText(
                textDirection: TextDirection.ltr,
                textAlign: align,
                text: TextSpan(
                  style: TextStyle(
                    color: tema.getScaffoldTextColor(),
                    fontFamily: tema.font,
                  ),
                  children: parrafos,
                ),
              ),
            ),
          );
  }
}
