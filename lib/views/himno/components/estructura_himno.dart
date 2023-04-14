import 'package:Himnario/helpers/isAndroid.dart';
import 'package:Himnario/models/himnos.dart';
import 'package:Himnario/models/tema.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class HimnoText extends StatelessWidget {
  final String alignment;

  HimnoText({this.estrofas, this.fontSize, this.alignment = 'Izquierda'});

  final List<Parrafo> estrofas;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    TextAlign align;
    switch (alignment) {
      case 'Izquierda':
        align = TextAlign.left;
        break;
      case 'Centro':
        align = TextAlign.center;
        break;
      case 'Derecha':
        align = TextAlign.right;
        break;
      default:
        align = TextAlign.left;
    }
    List<TextSpan> parrafos = List<TextSpan>();
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
                  style: DefaultTextStyle.of(context).style,
                  children: parrafos,
                ),
              ),
            ),
          )
        : ScopedModelDescendant(
            builder: (BuildContext context, Widget child, TemaModel tema) => Container(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
              child: Center(
                child: RichText(
                  textDirection: TextDirection.ltr,
                  textAlign: align,
                  text: TextSpan(
                      style: DefaultTextStyle.of(context)
                          .style
                          .copyWith(color: ScopedModel.of<TemaModel>(context).getScaffoldTextColor(), fontFamily: tema.font),
                      children: parrafos),
                ),
              ),
            ),
          );
  }
}
