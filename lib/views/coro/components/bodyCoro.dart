import 'package:Himnario/models/himnos.dart';
import 'package:flutter/material.dart';

import './estructura_Coro.dart';

class BodyCoro extends StatefulWidget {
  final String alignment;
  final double initFontSizePortrait;
  final double initFontSizeLandscape;
  final List<Parrafo> estrofas;
  final bool acordes;
  final double animation;
  final String notation;
  final ScrollController scrollController;
  final Function stopScroll;

  BodyCoro({
    this.estrofas,
    this.alignment,
    this.acordes,
    this.animation,
    this.notation,
    this.scrollController,
    this.stopScroll,
    this.initFontSizeLandscape,
    this.initFontSizePortrait,
  });

  @override
  _BodyCoroState createState() => _BodyCoroState();
}

class _BodyCoroState extends State<BodyCoro> {
  double fontSizePortrait;
  double initFontSizePortrait;
  double fontSizeLandscape;
  double initFontSizeLandscape;

  @override
  void initState() {
    super.initState();
    // Portrait Font Size
    initFontSizePortrait = widget.initFontSizePortrait;
    fontSizePortrait = initFontSizePortrait;

    // Landscape Font Size
    initFontSizeLandscape = widget.initFontSizeLandscape;
    fontSizeLandscape = initFontSizeLandscape;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        key: Key('GestureDetector-Coro'),
        onScaleUpdate: MediaQuery.of(context).orientation == Orientation.portrait
            ? (ScaleUpdateDetails details) {
                double newFontSize = initFontSizePortrait * details.scale;
                setState(() => fontSizePortrait = newFontSize < 10.0 ? 10.0 : newFontSize);
              }
            : (ScaleUpdateDetails details) {
                double newFontSize = initFontSizeLandscape * details.scale;
                setState(() => fontSizeLandscape = newFontSize < 10.0 ? 10.0 : newFontSize);
              },
        onScaleEnd: MediaQuery.of(context).orientation == Orientation.portrait
            ? (ScaleEndDetails details) {
                initFontSizePortrait = fontSizePortrait;
              }
            : (ScaleEndDetails details) {
                initFontSizeLandscape = fontSizeLandscape;
              },
        onTapDown: (TapDownDetails details) => widget.stopScroll(),
        onHorizontalDragDown: (DragDownDetails details) => widget.stopScroll(),
        onVerticalDragDown: (DragDownDetails details) => widget.stopScroll(),
        child: Container(
          child: (widget.estrofas.isNotEmpty
              ? ListView(
                  controller: widget.scrollController,
                  physics: BouncingScrollPhysics(),
                  children: <Widget>[
                    CoroText(
                      estrofas: widget.estrofas,
                      fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? fontSizePortrait : fontSizeLandscape,
                      alignment: widget.alignment,
                      acordes: widget.acordes,
                      animation: widget.animation,
                      notation: widget.notation,
                    )
                  ],
                )
              : Center(
                  child: CircularProgressIndicator(),
                )),
        ));
  }
}
