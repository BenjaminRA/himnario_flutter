import 'dart:io';

import 'package:Himnario/components/pageRoute.dart';
import 'package:Himnario/views/buscador/buscador.dart';
import 'package:Himnario/views/quickBuscador/quickBuscador.dart';
import 'package:Himnario/helpers/isAndroid.dart';
import 'package:Himnario/models/categorias.dart';
import 'package:Himnario/models/layout.dart';
import 'package:Himnario/models/tema.dart';
import 'package:Himnario/views/tema/tema.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class HimnosTab extends StatefulWidget {
  final List<Categoria> categorias;
  final Future<void> Function() onRefresh;
  final void Function()? showCupertinoMenu;

  HimnosTab({
    required this.categorias,
    required this.onRefresh,
    this.showCupertinoMenu,
  });

  @override
  State<HimnosTab> createState() => _HimnosTabState();
}

class _HimnosTabState extends State<HimnosTab> {
  List<HimnosListTile> listTiles = [];

  @override
  void didUpdateWidget(HimnosTab oldWidget) {
    final tema = TemaModel.of(context);

    if (widget.categorias.isNotEmpty && listTiles.isEmpty) {
      listTiles = [];

      // Todos
      listTiles.add(
        HimnosListTile(
          title: "Todos",
          page: TemaPage(
            id: 0,
            tema: 'Todos',
          ),
        ),
      );

      for (int i = 0; i < widget.categorias.length; ++i) {
        // Generating tiles
        listTiles.add(
          HimnosListTile(
            title: widget.categorias[i].categoria,
            page: TemaPage(
              id: widget.categorias[i].id,
              tema: widget.categorias[i].categoria,
            ),
            subCategorias: widget.categorias[i].subCategorias
                .map(
                  (e) => HimnosListTile(
                    title: e.subCategoria,
                    page: TemaPage(
                      id: e.id,
                      tema: e.subCategoria,
                      subtema: true,
                    ),
                  ),
                )
                .toList(),
          ),
        );
      }
    }

    super.didUpdateWidget(oldWidget);
  }

  void onTapExpanded(int i) {
    listTiles[i].expanded = !listTiles[i].expanded;

    setState(() {});
  }

  Widget materialTab() {
    final tema = TemaModel.of(context);

    return widget.categorias.isNotEmpty
        ? RefreshIndicator(
            color: TemaModel.of(context).getAccentColor(),
            onRefresh: widget.onRefresh,
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: 80.0),
              itemCount: listTiles.length,
              itemBuilder: (BuildContext context, int index) {
                return listTiles[index].subCategorias.isEmpty
                    ? Card(
                        elevation: 4.0,
                        margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              getPageRoute(listTiles[index].page, tema: tema),
                            );
                          },
                          title: Text(listTiles[index].title),
                        ),
                      )
                    : Card(
                        elevation: 4.0,
                        margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              title: Text(listTiles[index].title),
                              trailing: Icon(listTiles[index].expanded ? Icons.arrow_drop_up : Icons.arrow_drop_down),
                              onTap: () => onTapExpanded(index),
                            ),
                            AnimatedContainer(
                              duration: Duration(milliseconds: 400),
                              curve: Curves.easeInOutSine,
                              height: listTiles[index].expanded ? listTiles[index].subCategorias.length * 48.0 : 0.0,
                              child: AnimatedOpacity(
                                opacity: listTiles[index].expanded ? 1.0 : 0.0,
                                duration: Duration(milliseconds: 400),
                                curve: Curves.easeInOutSine,
                                child: Column(
                                  children: listTiles[index]
                                      .subCategorias
                                      .map(
                                        (subCategoria) => ListTile(
                                          dense: true,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              getPageRoute(subCategoria.page, tema: tema),
                                            );
                                          },
                                          title: Text(subCategoria.title),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
              },
            ),
          )
        : Container();
  }

  Widget cupertinoTab() {
    final tema = ScopedModel.of<TemaModel>(context);

    return CupertinoPageScaffold(
        // backgroundColor: tema.getScaffoldBackgroundColor(),
        navigationBar: CupertinoNavigationBar(
          backgroundColor: tema.getAccentColor(),
          // actionsForegroundColor: tema.getAccentColorText(),
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
                  builder: (BuildContext context) => ScopedModel<TemaModel>(
                    model: tema,
                    child: Buscador(id: 0, subtema: false, type: BuscadorType.Himnos),
                  ),
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
            'Himnos del Evangelio',
            // style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(color: tema.getTabTextColor(), fontFamily: tema.font),
          ),
        ),
        child: SafeArea(
            bottom: true,
            child: Stack(
              children: <Widget>[
                listTiles.isNotEmpty
                    ? CustomScrollView(
                        slivers: <Widget>[
                          CupertinoSliverRefreshControl(
                            onRefresh: widget.onRefresh,
                          ),
                          SliverPadding(
                            padding: EdgeInsets.only(bottom: 90.0),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (BuildContext context, int index) {
                                  return listTiles[index].subCategorias.isEmpty
                                      ? CupertinoButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                builder: (BuildContext context) => ScopedModel<TemaModel>(
                                                  model: tema,
                                                  child: TemaPage(id: index, tema: listTiles[index].title),
                                                ),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            listTiles[index].title,
                                            style: CupertinoTheme.of(context)
                                                .textTheme
                                                .textStyle
                                                .copyWith(color: tema.getScaffoldTextColor(), fontFamily: tema.font),
                                          ),
                                        )
                                      : Column(
                                          children: <Widget>[
                                            CupertinoButton(
                                              child: Stack(
                                                // mainAxisSize: MainAxisSize.max,
                                                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Align(
                                                    alignment: Alignment.center,
                                                    child: Text(listTiles[index].title,
                                                        style: CupertinoTheme.of(context)
                                                            .textTheme
                                                            .textStyle
                                                            .copyWith(color: tema.getScaffoldTextColor(), fontFamily: tema.font)),
                                                  ),
                                                  Align(
                                                    alignment: Alignment.centerRight,
                                                    child: Icon(
                                                      listTiles[index].expanded ? CupertinoIcons.up_arrow : CupertinoIcons.down_arrow,
                                                      color: tema.getScaffoldTextColor(),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              onPressed: () => onTapExpanded(index),
                                            ),
                                            AnimatedContainer(
                                              duration: Duration(milliseconds: 400),
                                              curve: Curves.easeInOutSine,
                                              height: listTiles[index].expanded ? listTiles[index].subCategorias.length * 50.0 : 0.0,
                                              child: AnimatedOpacity(
                                                opacity: listTiles[index].expanded ? 1.0 : 0.0,
                                                duration: Duration(milliseconds: 400),
                                                curve: Curves.easeInOutSine,
                                                child: Column(
                                                  children: listTiles[index]
                                                      .subCategorias
                                                      .map(
                                                        (subCategoria) => CupertinoButton(
                                                          onPressed: () {
                                                            Navigator.push(
                                                              context,
                                                              getPageRoute(subCategoria.page, tema: tema),
                                                            );
                                                          },
                                                          child: Container(
                                                            width: double.infinity,
                                                            child: Text(
                                                              subCategoria.title,
                                                              textAlign: TextAlign.center,
                                                              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                                                                    color: tema.getScaffoldTextColor(),
                                                                    fontFamily: tema.font,
                                                                    fontWeight: FontWeight.w400,
                                                                    fontSize: 15.0,
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                      .toList(),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                },
                                childCount: listTiles.length,
                              ),
                            ),
                          )
                        ],
                      )
                    : Container(),
                Positioned(
                  right: -50.0,
                  bottom: 30.0,
                  child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0), color: tema.getAccentColor()),
                    width: 100.0,
                    height: 54.0,
                    child: Padding(
                        padding: EdgeInsets.only(right: 50.0),
                        child: CupertinoButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (BuildContext context) => QuickBuscador(),
                              ),
                            );
                          },
                          child: Icon(
                            Icons.dialpad,
                            color: tema.getAccentColorText(),
                          ),
                        )),
                  ),
                ),
                // Positioned(
                //   left: -50.0,
                //   bottom: 30.0,
                //   child: AnimatedContainer(
                //     transform: widget.cargando ? Matrix4.translationValues(0.0, 0.0, 0.0) : Matrix4.translationValues(-50.0, 0.0, 0.0),
                //     curve: Curves.easeOutSine,
                //     duration: Duration(milliseconds: 1000),
                //     decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0), color: tema.getAccentColor()),
                //     width: 100.0,
                //     height: 54.0,
                //     child: Padding(
                //         padding: EdgeInsets.only(left: 50.0),
                //         child: ColorFiltered(
                //           colorFilter: ColorFilter.mode(Colors.white,
                //               WidgetsBinding.instance.window.platformBrightness == Brightness.dark ? BlendMode.difference : BlendMode.darken),
                //           child: CupertinoActivityIndicator(
                //             animating: true,
                //           ),
                //         )),
                //   ),
                // ),
              ],
            ))
        // ),
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
