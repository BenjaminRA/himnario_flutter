import 'package:flutter/material.dart';
import '../../models/himnos.dart';

class CoroText extends StatelessWidget {

  CoroText({this.estrofas, this.fontSize, this.alignment = 'Izquierda', this.acordes, this.animation});

  final String alignment;
  final List<Parrafo> estrofas;
  final double fontSize;
  final bool acordes;
  final double animation;

  @override
  Widget build(BuildContext context) {
    TextAlign align;
    switch(alignment) {
      case 'Izquierda': {
        align = TextAlign.left;
      } break;
      case 'Centro': {
        align = TextAlign.center;
      } break;
      case 'Derecha': {
        align = TextAlign.right;
      } break;
      default: {
        align = TextAlign.left;
      } break;
    }
    List<TextSpan> parrafos = List<TextSpan>();
    for(Parrafo parrafo in estrofas) {
      List<String> lineasAcordes = parrafo.acordes.isNotEmpty ? parrafo.acordes.split('\n') : List<String>();
      List<String> lineasParrafos = parrafo.parrafo.split('\n');
      if(parrafo.coro) {
        parrafos.add(
          TextSpan(
            text: 'Coro\n',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w300,
              fontSize: fontSize
            ),
          )
        );
        for (int i = 0; i < lineasParrafos.length; ++i) {
          parrafos.addAll([
            lineasAcordes.isNotEmpty && lineasAcordes[i] != ' ' ? TextSpan(
              text: lineasAcordes[i] + '\n',
              style: TextStyle(
                fontSize: animation*fontSize,
                height: Theme.of(context).textTheme.body1.height,
                fontWeight: FontWeight.bold,
                wordSpacing: (fontSize*(1.4/8.04)-(10.0*(1.4/8.04))+1.6),
                color: Color.fromRGBO(Theme.of(context).accentColor.red, Theme.of(context).accentColor.green, Theme.of(context).accentColor.blue, animation),
              )
            ) : TextSpan(),
            TextSpan(
              text: lineasParrafos[i] + (i == lineasParrafos.length - 1 ? '\n\n' : '\n'),
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: fontSize
              )
            ),
          ]);
        }
      }
      else {
        for (int i = 0; i < lineasParrafos.length; ++i) {
          parrafos.addAll([
            lineasAcordes.isNotEmpty && lineasAcordes[i] != ' ' ? TextSpan(
              text: lineasAcordes[i] + '\n',
              style: TextStyle(
                wordSpacing: (fontSize*(1.4/8.04)-(10.0*(1.4/8.04))+1.6),
                fontSize: animation*fontSize,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(Theme.of(context).accentColor.red, Theme.of(context).accentColor.green, Theme.of(context).accentColor.blue, animation),
              )
            ) : TextSpan(),
            TextSpan(
              text: lineasParrafos[i] + (i == lineasParrafos.length - 1 ? '\n\n' : '\n'),
              style: TextStyle(
                fontSize: fontSize
              )
            ),
          ]);
        }
      }
    }
    // for(Parrafo parrafo in estrofas) {
    //   if(parrafo.coro)
    //     parrafos.addAll([
    //       TextSpan(
    //         text: 'Coro\n',
    //         style: TextStyle(
    //           fontStyle: FontStyle.italic,
    //           fontWeight: FontWeight.w300,
    //           fontSize: fontSize
    //         ),
    //       ),
    //       TextSpan(
    //         text: parrafo.parrafo + '\n\n',
    //         style: TextStyle(
    //           fontStyle: FontStyle.italic,
    //           fontSize: fontSize
    //         )
    //       )
    //     ]);
    //   else
    //     parrafos.addAll([
    //       TextSpan(
    //         text: parrafo.parrafo + '\n\n',
    //         style: TextStyle(
    //           fontSize: fontSize
    //         )
    //       )
    //     ]);
    // }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      child: Center(
        child: RichText(
          textDirection: TextDirection.ltr,
          textAlign: align,
          // softWrap: false,
          // overflow: TextOverflow.fade,
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: parrafos
          ),
        )
      )
    );
  }
}