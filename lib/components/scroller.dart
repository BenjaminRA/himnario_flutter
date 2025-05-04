import 'package:Himnario/helpers/isAndroid.dart';
import 'package:Himnario/models/tema.dart';
import 'package:Himnario/views/coro/coro.dart';
import 'package:Himnario/views/himno/himno.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:Himnario/models/himnos.dart';
import 'package:scoped_model/scoped_model.dart';

class Scroller extends StatefulWidget {
  final String mensaje;
  final bool buscador;
  final bool iPhoneX;
  final double iPhoneXBottomPadding;

  final int count;
  final Widget Function(BuildContext context, int index, bool selected, bool dragging) itemBuilder;
  final String Function(int index) scrollerBubbleText;

  final Future<void> Function()? onRefresh;

  Scroller({
    this.mensaje = '',
    this.iPhoneX = false,
    this.iPhoneXBottomPadding = 0.0,
    this.buscador = false,

    // Builder
    required this.count,
    required this.itemBuilder,
    required this.scrollerBubbleText,

    // iOS
    this.onRefresh,
  });

  @override
  _ScrollerState createState() => _ScrollerState();
}

class _ScrollerState extends State<Scroller> {
  late ScrollController scrollController;
  bool dragging = false;
  late double scrollPosition;
  late double iPhoneXPadding;

  @override
  void initState() {
    super.initState();

    // iOS specific
    iPhoneXPadding = widget.iPhoneX ? 20.0 : 0.0;

    scrollController = ScrollController(initialScrollOffset: 0.0);
    scrollController.addListener(() {
      double maxScrollPosition = isAndroid()
          ? MediaQuery.of(context).size.height - 60 - 130.0
          : MediaQuery.of(context).size.height - 85.0 - widget.iPhoneXBottomPadding - 72.0 + iPhoneXPadding;
      double maxScrollExtent = scrollController.position.maxScrollExtent == 0.0 ? 1.0 : scrollController.position.maxScrollExtent;
      if (!dragging)
        setState(() {
          if (isAndroid()) {
            scrollPosition = 15.0 + ((scrollController.offset / maxScrollExtent) * (maxScrollPosition));
          } else {
            scrollPosition = 72.0 + iPhoneXPadding + ((scrollController.offset / maxScrollExtent) * (maxScrollPosition));
          }
        });
    });

    scrollPosition = isAndroid() ? (105.0 - 90.0) : (72.0 + iPhoneXPadding);
  }

  @override
  void didUpdateWidget(Scroller oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count != widget.count && widget.buscador) {
      scrollPosition = isAndroid() ? (105.0 - 90.0) : (72.0 + iPhoneXPadding);
    }
  }

  Widget materialLayout(BuildContext context) {
    final TemaModel tema = TemaModel.of(context);
    int length = widget.count == 0 ? 1 : widget.count;
    if (scrollPosition == double.infinity || scrollPosition == double.nan) {
      scrollPosition = 105.0 - 90.0;
    }

    return Stack(
      children: <Widget>[
        widget.count == 0
            ? Container(
                child: Center(
                    child: Text(
                  widget.mensaje,
                  textAlign: TextAlign.center,
                  textScaleFactor: 1.5,
                  style: tema.getScaffoldTextStyle(context),
                )),
              )
            : ListView.builder(
                key: PageStorageKey('Scroller Tema'),
                controller: scrollController,
                itemCount: widget.count,
                itemBuilder: (BuildContext context, int index) {
                  bool selected = (scrollPosition - 15) ~/ ((MediaQuery.of(context).size.height - 129) / length) == index;

                  Color color = selected && dragging ? tema.getAccentColorText() : tema.getScaffoldTextColor();

                  return widget.itemBuilder(context, index, selected, dragging);
                },
              ),
        // We only render the side scrollbar if the list overflows the screen
        widget.count * 60.0 > MediaQuery.of(context).size.height
            ? Align(
                alignment: FractionalOffset.centerRight,
                child: GestureDetector(
                    onVerticalDragStart: (DragStartDetails details) {
                      double position;
                      if (details.globalPosition.dy > MediaQuery.of(context).size.height - 25.0) {
                        position = MediaQuery.of(context).size.height - 115.0;
                      } else if (details.globalPosition.dy < 105) {
                        position = 15.0;
                      } else
                        position = details.globalPosition.dy - 90;
                      setState(() {
                        scrollPosition = position;
                        dragging = true;
                      });
                      int currentHimno = ((position - 15) ~/ ((MediaQuery.of(context).size.height - 129) / length) + 1);
                      if (currentHimno > widget.count - (MediaQuery.of(context).size.height - 115.0) ~/ 56.0)
                        scrollController.jumpTo(scrollController.position.maxScrollExtent);
                      else
                        scrollController.jumpTo((position - 15) ~/ ((MediaQuery.of(context).size.height - 129) / length) * 56.0);
                    },
                    onVerticalDragUpdate: (DragUpdateDetails details) {
                      double position;
                      if (details.globalPosition.dy > MediaQuery.of(context).size.height - 25.0) {
                        position = MediaQuery.of(context).size.height - 115.0;
                      } else if (details.globalPosition.dy < 105) {
                        position = 15.0;
                      } else
                        position = details.globalPosition.dy - 90;
                      setState(() {
                        scrollPosition = position;
                      });
                      int currentHimno = ((position - 15) ~/ ((MediaQuery.of(context).size.height - 129) / length) + 1);
                      if (currentHimno > widget.count - (MediaQuery.of(context).size.height - 115.0) ~/ 56.0)
                        scrollController.animateTo(scrollController.position.maxScrollExtent,
                            curve: Curves.easeInOut, duration: Duration(milliseconds: 200));
                      else
                        scrollController.jumpTo((position - 15) ~/ ((MediaQuery.of(context).size.height - 129) / length) * 56.0);
                    },
                    onVerticalDragEnd: (DragEndDetails details) {
                      setState(() {
                        dragging = false;
                      });
                    },
                    child: Container(
                      height: double.infinity,
                      width: 40.0,
                      child: CustomPaint(
                        painter: SideScroller(
                          context,
                          getBubbleText: widget.scrollerBubbleText,
                          position: scrollPosition,
                          dragging: dragging,
                          numero: dragging ? (scrollPosition - 15) ~/ ((MediaQuery.of(context).size.height - 129) / length) : -1,
                        ),
                      ),
                    )))
            : Container()
      ],
    );
  }

  Widget cupertinoLayout(BuildContext context) {
    final TemaModel tema = TemaModel.of(context);
    int length = widget.count == 0 ? 1 : widget.count;
    if (scrollPosition == double.infinity || scrollPosition == double.nan) {
      scrollPosition = 72.0 + iPhoneXPadding;
    }

    List<Widget> slivers = [];

    if (widget.onRefresh != null) {
      slivers.add(
        CupertinoSliverRefreshControl(
          onRefresh: widget.onRefresh,
        ),
      );
    }

    slivers.add(
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            bool selected = (scrollPosition - 72.0 - iPhoneXPadding) ~/
                    ((MediaQuery.of(context).size.height - 85.0 - widget.iPhoneXBottomPadding - 72.0 - iPhoneXPadding + 0.5) / length) ==
                index;

            return widget.itemBuilder(context, index, selected, dragging);
          },
          childCount: widget.count,
        ),
      ),
    );

    return Stack(
      children: <Widget>[
        widget.count == 0
            ? Container(
                child: Center(
                  child: Text(
                    widget.mensaje,
                    textScaleFactor: 1.5,
                    textAlign: TextAlign.center,
                    style: tema.getScaffoldTextStyle(context),
                  ),
                ),
              )
            : CustomScrollView(
                key: PageStorageKey('Scroller Tema'),
                controller: scrollController,
                slivers: slivers,
              ),
        // We only render the side scrollbar if the list overflows the screen
        widget.count * 60.0 > MediaQuery.of(context).size.height
            ? Align(
                alignment: FractionalOffset.centerRight,
                child: Container(
                  transform: Matrix4.translationValues(0.0, (widget.iPhoneX && tema.brightness == Brightness.light ? -20.0 : 0.0), 0.0),
                  margin: EdgeInsets.only(top: tema.brightness == Brightness.dark ? (widget.iPhoneX ? 70.0 : 65.0) : 0.0),
                  child: GestureDetector(
                      onVerticalDragStart: (DragStartDetails details) {
                        double position;
                        double bottomPadding = MediaQuery.of(context).size.height - 85.0 - widget.iPhoneXBottomPadding;
                        double topPadding = 72.0 + iPhoneXPadding;
                        double tileSize = 55.0;

                        if (details.globalPosition.dy > bottomPadding + 15.0) {
                          position = bottomPadding;
                        } else if (details.globalPosition.dy < topPadding + 15.0) {
                          position = topPadding;
                        } else
                          position = details.globalPosition.dy - 15.0;
                        setState(() {
                          scrollPosition = position;
                          dragging = true;
                        });

                        int currentHimno = ((scrollPosition - topPadding) ~/ ((bottomPadding - topPadding + 0.5) / length) + 1);

                        if (currentHimno > widget.count - (MediaQuery.of(context).size.height - 115.0) ~/ tileSize)
                          scrollController.animateTo(scrollController.position.maxScrollExtent,
                              curve: Curves.easeInOut, duration: Duration(milliseconds: 200));
                        else
                          scrollController.jumpTo((scrollPosition - topPadding) ~/ ((bottomPadding - topPadding + 0.5) / length) * tileSize);
                      },
                      onVerticalDragUpdate: (DragUpdateDetails details) {
                        double position;
                        double bottomPadding = MediaQuery.of(context).size.height - 85.0 - widget.iPhoneXBottomPadding;
                        double topPadding = 72.0 + iPhoneXPadding;
                        double tileSize = 55.0;

                        if (details.globalPosition.dy > bottomPadding + 15.0) {
                          position = bottomPadding;
                        } else if (details.globalPosition.dy < topPadding + 15.0) {
                          position = topPadding;
                        } else
                          position = details.globalPosition.dy - 15.0;

                        setState(() {
                          scrollPosition = position;
                        });

                        int currentHimno = ((scrollPosition - topPadding) ~/ ((bottomPadding - topPadding + 0.5) / length) + 1);

                        if (currentHimno > widget.count - (MediaQuery.of(context).size.height - 115.0) ~/ tileSize)
                          scrollController.animateTo(scrollController.position.maxScrollExtent,
                              curve: Curves.easeInOut, duration: Duration(milliseconds: 200));
                        else
                          scrollController.jumpTo((scrollPosition - topPadding) ~/ ((bottomPadding - topPadding + 0.5) / length) * tileSize);
                      },
                      onVerticalDragEnd: (DragEndDetails details) {
                        setState(() {
                          dragging = false;
                        });
                      },
                      child: Container(
                        height: double.infinity,
                        width: 40.0,
                        child: Transform.translate(
                          offset: Offset(0.0, -65.0),
                          child: CustomPaint(
                            painter: SideScroller(
                              context,
                              getBubbleText: widget.scrollerBubbleText,
                              position: scrollPosition,
                              dragging: dragging,
                              iPhoneXPadding: iPhoneXPadding,
                              numero: dragging
                                  ? (scrollPosition - 72.0 - iPhoneXPadding) ~/
                                      ((MediaQuery.of(context).size.height - 85.0 - widget.iPhoneXBottomPadding - 72.0 - iPhoneXPadding + 0.5) /
                                          length)
                                  : -1,
                            ),
                          ),
                        ),
                      )),
                ))
            : Container()
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAndroid() ? materialLayout(context) : cupertinoLayout(context);
  }
}

class SideScroller extends CustomPainter {
  double position;
  bool dragging;
  int numero;
  double iPhoneXPadding;
  final String Function(int index) getBubbleText;
  late TemaModel tema;

  late Paint scrollBar;
  late Color textColor;

  SideScroller(
    BuildContext context, {
    required this.position,
    required this.dragging,
    required this.numero,
    required this.getBubbleText,
    this.iPhoneXPadding = 0.0,
  }) {
    tema = TemaModel.of(context);
    textColor = tema.getAccentColorText();

    if (isAndroid()) {
      scrollBar = Paint()
        ..color = dragging ? tema.getAccentColor() : Colors.grey.withOpacity(0.5)
        ..strokeWidth = 10.0
        ..strokeCap = StrokeCap.round;
    } else {
      textColor = tema.brightness == Brightness.light ? Colors.white : tema.getTabTextColor();
      scrollBar = Paint()
        ..color = dragging ? tema.getAccentColor() : Colors.grey.withOpacity(0.5)
        ..strokeWidth = 5.0
        ..strokeCap = StrokeCap.round;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (isAndroid()) {
      canvas.drawLine(Offset(size.width - 15, position), Offset(size.width - 15, position + 20), scrollBar);
    } else {
      canvas.drawLine(Offset(size.width - 5, position), Offset(size.width - 5, position + 30), scrollBar);
    }
    if (dragging) {
      String text = getBubbleText(numero);
      double textPosition;

      if (isAndroid()) {
        textPosition = position < 90.0 ? 90.0 : position;
      } else {
        textPosition = position < 155.0 + iPhoneXPadding ? 155.0 + iPhoneXPadding : position;
      }

      for (int i = 0; i < text.length; ++i) canvas.drawCircle(Offset(size.width - 85 - 5 * i, textPosition - 40), 45.0, scrollBar);
      canvas.drawRect(Rect.fromCircle(center: Offset(size.width - 62, textPosition - 17), radius: 22.0), scrollBar);
      TextPainter(
          text: TextSpan(
              text: text,
              style: TextStyle(
                fontSize: 45.0,
              )),
          textDirection: TextDirection.ltr)
        ..layout()
        ..paint(canvas, Offset(size.width - (text == "M" ? 132 : 127) - 15 * (text.length - 3), textPosition - 65));
    }
  }

  @override
  bool shouldRepaint(SideScroller oldDelegate) {
    return oldDelegate.position != position || oldDelegate.dragging != dragging;
  }
}
