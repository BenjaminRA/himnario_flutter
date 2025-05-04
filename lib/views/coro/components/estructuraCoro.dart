import 'package:Himnario/helpers/isAndroid.dart';
import 'package:Himnario/models/himnos.dart';
import 'package:Himnario/models/tema.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class CoroText extends StatelessWidget {
  final TemaAlignment alignment;
  final List<Parrafo> estrofas;
  final double fontSize;
  final bool acordes;
  final double animation;
  final TemaNotation notation;
  Map<String, double> fontFamilies = {
    "Josefin Sans": -1.0,
    "Lato": 1.0,
    "Merriweather": 0.8,
    "Montserrat": 0.5,
    "Open Sans": 0.1,
    "Poppins": 1.7,
    "Raleway": 0.5,
    "Roboto": 0.3,
    "Roboto Mono": -4.5,
    "Rubik": 1.2,
    "Source Sans Pro": 0.7,
  };

  CoroText({
    this.alignment = TemaAlignment.Izquierda,
    required this.estrofas,
    required this.fontSize,
    required this.acordes,
    required this.animation,
    required this.notation,
  });

  @override
  Widget build(BuildContext context) {
    final tema = ScopedModel.of<TemaModel>(context);

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
      List<String> lineasAcordes = parrafo.acordes != null && parrafo.acordes!.isNotEmpty
          ? notation == TemaNotation.Americana
              ? Acordes.toAmericano(parrafo.acordes!)!.split('\n')
              : parrafo.acordes!.split('\n')
          : [];

      List<String> lineasParrafos = parrafo.parrafo.split('\n');

      Color color = tema.getScaffoldTextColor();

      if (parrafo.coro) {
        parrafos.add(
          TextSpan(
            text: 'Coro\n',
            style: isAndroid()
                ? TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w300,
                    fontSize: fontSize,
                  )
                : TextStyle(
                    color: tema.getScaffoldTextColor(),
                    fontStyle: FontStyle.italic,
                    fontFamily: tema.font,
                    fontWeight: FontWeight.w300,
                    fontSize: fontSize,
                  ),
          ),
        );

        for (int i = 0; i < lineasParrafos.length; ++i) {
          parrafos.addAll(
            [
              lineasAcordes.isEmpty || i >= lineasAcordes.length || lineasAcordes[i] == ''
                  ? TextSpan()
                  : TextSpan(
                      text: lineasAcordes[i] + '\n',
                      style: TextStyle(
                        fontSize: animation * fontSize,
                        // height: Theme.of(context).textTheme.body1.height,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        wordSpacing: fontFamilies[DefaultTextStyle.of(context).style.fontFamily],
                        color: Color.fromRGBO(color.red, color.green, color.blue, animation),
                        fontFamily: !isAndroid() ? ScopedModel.of<TemaModel>(context).font : null,
                      ),
                    ),
              TextSpan(
                text: lineasParrafos[i] + (i == lineasParrafos.length - 1 ? '\n\n' : '\n'),
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: fontSize,
                  color: tema.getScaffoldTextColor(),
                ),
              ),
            ],
          );
        }
      } else {
        for (int i = 0; i < lineasParrafos.length; ++i) {
          parrafos.addAll(
            [
              lineasAcordes.isEmpty || i >= lineasAcordes.length || lineasAcordes[i] == ''
                  ? TextSpan()
                  : TextSpan(
                      text: lineasAcordes[i] + '\n',
                      style: TextStyle(
                        wordSpacing: fontFamilies[DefaultTextStyle.of(context).style.fontFamily],
                        fontSize: animation * fontSize,
                        fontWeight: FontWeight.bold,
                        fontFamily: !isAndroid() ? ScopedModel.of<TemaModel>(context).font : null,
                        color: Color.fromRGBO(color.red, color.green, color.blue, animation),
                      ),
                    ),
              TextSpan(
                text: lineasParrafos[i] + (i == lineasParrafos.length - 1 ? '\n\n' : '\n'),
                style: TextStyle(fontSize: fontSize),
              ),
            ],
          );
        }
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      child: Center(
        child: RichText(
          textDirection: TextDirection.ltr,
          textAlign: align,
          text: TextSpan(
            style: isAndroid()
                ? DefaultTextStyle.of(context).style
                : DefaultTextStyle.of(context).style.copyWith(
                      fontFamily: tema.font,
                      color: tema.getScaffoldTextColor(),
                    ),
            children: parrafos,
          ),
        ),
      ),
    );
  }
}
