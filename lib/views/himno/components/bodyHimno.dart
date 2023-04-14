import 'package:Himnario/helpers/isAndroid.dart';
import 'package:Himnario/models/himnos.dart';
import 'package:flutter/material.dart';

import './estructura_himno.dart';

class BodyHimno extends StatefulWidget {
  final String alignment;
  final double initFontSizePortrait;
  final double initFontSizeLandscape;
  final List<Parrafo> estrofas;
  final double switchValue;
  final String tema;
  final String subTema;
  final int temaId;

  BodyHimno({
    this.estrofas,
    this.alignment,
    this.switchValue,
    this.tema,
    this.subTema,
    this.temaId,
    this.initFontSizePortrait,
    this.initFontSizeLandscape,
  });

  @override
  _BodyHimnoState createState() => _BodyHimnoState();
}

class _BodyHimnoState extends State<BodyHimno> {
  ScrollController controller;
  double fontSizePortrait;
  double initFontSizePortrait;
  double fontSizeLandscape;
  double initFontSizeLandscape;

  @override
  void initState() {
    super.initState();
    // Protrait Font Size
    initFontSizePortrait = widget.initFontSizePortrait;
    fontSizePortrait = initFontSizePortrait;

    // Landscape Font Size
    initFontSizeLandscape = widget.initFontSizeLandscape;
    fontSizeLandscape = initFontSizeLandscape;
    controller = ScrollController();
  }

  Widget materialLayout() {
    return Container(
      child: (widget.estrofas.isNotEmpty
          ? ListView(
              controller: controller,
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.only(bottom: 70.0 + widget.switchValue * 130),
              children: <Widget>[
                HimnoText(
                  estrofas: widget.estrofas,
                  fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? fontSizePortrait : fontSizeLandscape,
                  alignment: widget.alignment,
                )
              ],
            )
          : Center(
              child: CircularProgressIndicator(),
            )),
    );
  }

  Widget cupertinoLayout() {
    return Container(
      child: (widget.estrofas.isNotEmpty
          ? ListView(
              physics: BouncingScrollPhysics(),
              children: <Widget>[
                HimnoText(
                  estrofas: widget.estrofas,
                  fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? fontSizePortrait : fontSizeLandscape,
                  alignment: widget.alignment,
                )
              ],
            )
          : Center(
              child: CircularProgressIndicator(),
            )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: Key('GestureDetector-Himno'),
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
      child: isAndroid() ? materialLayout() : cupertinoLayout(),
    );
  }
}
