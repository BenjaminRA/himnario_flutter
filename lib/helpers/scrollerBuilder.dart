import 'package:Himnario/helpers/isAndroid.dart';
import 'package:Himnario/models/himnos.dart';
import 'package:Himnario/models/tema.dart';
import 'package:Himnario/views/coro/coro.dart';
import 'package:Himnario/views/himno/himno.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Widget Function(BuildContext context, int index, bool selected, bool dragging) scrollerBuilderHimnos(BuildContext context, List<Himno> himnos) {
  final tema = TemaModel.of(context);

  return isAndroid()
      ? (context, index, selected, dragging) {
          return Container(
            color: selected && dragging ? tema.getAccentColor() : Colors.transparent,
            child: ListTile(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => himnos[index].numero <= 517
                        ? HimnoPage(
                            numero: himnos[index].numero,
                            titulo: himnos[index].titulo,
                          )
                        : CoroPage(
                            numero: himnos[index].numero,
                            titulo: himnos[index].titulo,
                            transpose: himnos[index].transpose,
                            scrollSpeed: himnos[index].autoScrollSpeed,
                          ),
                  ),
                );
                // scrollPosition = 105.0 - 90.0;
              },
              leading: himnos[index].favorito
                  ? Icon(
                      Icons.star,
                      color: selected && dragging ? tema.getAccentColorText() : tema.getScaffoldTextColor(),
                    )
                  : null,
              title: Container(
                width: himnos[index].favorito ? MediaQuery.of(context).size.width - 90 : MediaQuery.of(context).size.width - 50,
                child: Text(
                  ((himnos[index].numero > 517 ? '' : '${himnos[index].numero} - ') + '${himnos[index].titulo}'),
                  softWrap: true,
                  style: TextStyle(
                    color: selected && dragging ? tema.getAccentColorText() : tema.getScaffoldTextColor(),
                    fontFamily: tema.font,
                  ),
                ),
              ),
              trailing: himnos[index].descargado
                  ? Icon(
                      Icons.get_app,
                      color: selected && dragging ? tema.getAccentColorText() : tema.getScaffoldTextColor(),
                    )
                  : null,
            ),
          );
        }
      : (context, index, selected, dragging) {
          return Container(
            color: selected && dragging ? tema.mainColor : tema.getScaffoldBackgroundColor(),
            height: 55.0,
            child: CupertinoButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (BuildContext context) => himnos[index].numero <= 517
                        ? HimnoPage(
                            numero: himnos[index].numero,
                            titulo: himnos[index].titulo,
                          )
                        : CoroPage(
                            numero: himnos[index].numero,
                            titulo: himnos[index].titulo,
                            transpose: himnos[index].transpose,
                            scrollSpeed: himnos[index].autoScrollSpeed,
                          ),
                  ),
                );
                // scrollPosition = 105.0 - 90.0;
              },
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      ((himnos[index].numero > 517 ? '' : '${himnos[index].numero} - ') + '${himnos[index].titulo}'),
                      softWrap: true,
                      textAlign: TextAlign.start,
                      style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                            color: selected && dragging ? tema.mainColorContrast : tema.getScaffoldTextColor(),
                            fontFamily: tema.font,
                          ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        himnos[index].favorito
                            ? Icon(
                                Icons.star,
                                color: selected && dragging ? tema.mainColorContrast : tema.getScaffoldTextColor(),
                              )
                            : Container(),
                        himnos[index].descargado
                            ? Icon(
                                Icons.get_app,
                                color: selected && dragging ? tema.mainColorContrast : tema.getScaffoldTextColor(),
                              )
                            : Container()
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        };
}
