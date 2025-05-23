import 'dart:io';

import 'package:Himnario/components/scroller.dart';
import 'package:Himnario/helpers/isAndroid.dart';
import 'package:Himnario/components/corosScroller.dart';
import 'package:Himnario/helpers/scrollerBuilder.dart';
import 'package:Himnario/models/categorias.dart';
import 'package:Himnario/models/himnos.dart';
import 'package:Himnario/models/layout.dart';
import 'package:Himnario/models/tema.dart';
import 'package:Himnario/views/buscador/buscador.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class CorosTab extends StatefulWidget {
  final List<Himno> coros;
  final Future<void> Function() onRefresh;
  final void Function()? showCupertinoMenu;

  CorosTab({
    required this.coros,
    required this.onRefresh,
    this.showCupertinoMenu,
  });

  @override
  State<CorosTab> createState() => _CorosTabState();
}

class _CorosTabState extends State<CorosTab> {
  List<HimnosListTile> listTiles = [];

  @override
  void didUpdateWidget(CorosTab oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void onTapExpanded(int i) {
    listTiles[i].expanded = !listTiles[i].expanded;

    setState(() {});
  }

  Widget materialTab() {
    return RefreshIndicator(
      color: TemaModel.of(context).getScaffoldAccentColor(),
      onRefresh: widget.onRefresh,
      child: Scroller(
        count: widget.coros.length,
        itemBuilder: scrollerBuilderHimnos(context, widget.coros),
        scrollerBubbleText: (index) => widget.coros[index].numero <= 517 ? widget.coros[index].numero.toString() : widget.coros[index].titulo[0],
        // himnos: widget.coros,
        mensaje: '',
      ),
    );
  }

  Widget cupertinoTab() {
    final tema = TemaModel.of(context);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: tema.getAccentColor(),
        // actionsForegroundColor: tema.getTabTextColor(),
        transitionBetweenRoutes: false,
        leading: CupertinoButton(
          onPressed: widget.showCupertinoMenu,
          padding: EdgeInsets.only(bottom: 2.0),
          child: Icon(
            Icons.menu,
            size: 30.0,
            color: tema.getAccentColorText(),
          ),
        ),
        trailing: CupertinoButton(
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (BuildContext context) =>
                    ScopedModel<TemaModel>(model: tema, child: Buscador(id: 0, subtema: false, type: BuscadorType.Coros)),
              ),
            );
          },
          padding: EdgeInsets.only(bottom: 2.0),
          child: Icon(
            CupertinoIcons.search,
            size: 30.0,
            color: tema.getAccentColorText(),
          ),
        ),
        middle: Text(
          'Coros',
          style: TextStyle(
            color: tema.getAccentColorText(),
            fontFamily: tema.font,
          ),
        ),
      ),
      child: Stack(
        children: <Widget>[
          Scroller(
            // himnos: widget.coros,
            count: widget.coros.length,
            itemBuilder: scrollerBuilderHimnos(context, widget.coros),
            scrollerBubbleText: (index) => widget.coros[index].numero <= 517 ? widget.coros[index].numero.toString() : widget.coros[index].titulo[0],
            mensaje: '',
            iPhoneX: MediaQuery.of(context).size.width >= 812.0 || MediaQuery.of(context).size.height >= 812.0,
            onRefresh: widget.onRefresh,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAndroid() ? materialTab() : cupertinoTab();
  }
}

// Widget getHimnosTab(
//   BuildContext context, {
//   List<Categoria> categorias,
//   Function onRefresh,
//   List<bool> expanded,
// }) {
//   if (onRefresh == null) {
//     onRefresh = () {};
//   }

//   return ;
// }
