// import 'package:Himnario/helpers/isAndroid.dart';
// import 'package:Himnario/models/tema.dart';
// import 'package:Himnario/views/coro/coro.dart';
// import 'package:Himnario/views/himno/himno.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

// import 'package:Himnario/models/himnos.dart';
// import 'package:scoped_model/scoped_model.dart';

// class Scroller extends StatefulWidget {
//   final List<Himno> himnos;
//   final bool cargando;
//   final String mensaje;
//   final bool buscador;
//   final bool iPhoneX;
//   final double iPhoneXBottomPadding;

//   Scroller({
//     required this.himnos,
//     required this.cargando,
//     this.mensaje = '',
//     this.iPhoneX = false,
//     this.iPhoneXBottomPadding = 0.0,
//     this.buscador = false,
//   });

//   @override
//   _ScrollerState createState() => _ScrollerState();
// }

// class _ScrollerState extends State<Scroller> {
//   late ScrollController scrollController;
//   bool dragging = false;
//   late double scrollPosition;
//   late double iPhoneXPadding;

//   @override
//   void initState() {
//     super.initState();

//     // iOS specific
//     iPhoneXPadding = widget.iPhoneX ? 20.0 : 0.0;

//     scrollController = ScrollController(initialScrollOffset: 0.0);
//     scrollController.addListener(() {
//       double maxScrollPosition = isAndroid()
//           ? MediaQuery.of(context).size.height - 60 - 130.0
//           : MediaQuery.of(context).size.height - 85.0 - widget.iPhoneXBottomPadding - 72.0 + iPhoneXPadding;
//       double maxScrollExtent = scrollController.position.maxScrollExtent == 0.0 ? 1.0 : scrollController.position.maxScrollExtent;
//       if (!dragging)
//         setState(() {
//           if (isAndroid()) {
//             scrollPosition = 15.0 + ((scrollController.offset / maxScrollExtent) * (maxScrollPosition));
//           } else {
//             scrollPosition = 72.0 + iPhoneXPadding + ((scrollController.offset / maxScrollExtent) * (maxScrollPosition));
//           }
//         });
//     });

//     scrollPosition = isAndroid() ? (105.0 - 90.0) : (72.0 + iPhoneXPadding);
//   }

//   @override
//   void didUpdateWidget(Scroller oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.himnos != widget.himnos && widget.buscador) {
//       scrollPosition = isAndroid() ? (105.0 - 90.0) : (72.0 + iPhoneXPadding);
//     }
//   }

//   Widget materialLayout(BuildContext context) {
//     final TemaModel tema = TemaModel.of(context);
//     int length = widget.himnos.length == 0 ? 1 : widget.himnos.length;
//     if (scrollPosition == double.infinity || scrollPosition == double.nan) {
//       scrollPosition = 105.0 - 90.0;
//     }

//     return Stack(
//       children: <Widget>[
//         widget.himnos.isEmpty
//             ? Container(
//                 child: Center(
//                     child: Text(
//                   widget.mensaje,
//                   textAlign: TextAlign.center,
//                   textScaleFactor: 1.5,
//                   style: tema.getScaffoldTextStyle(context),
//                 )),
//               )
//             : ListView.builder(
//                 key: PageStorageKey('Scroller Tema'),
//                 controller: scrollController,
//                 itemCount: widget.himnos.length,
//                 itemBuilder: (BuildContext context, int index) {
//                   bool selected = (scrollPosition - 15) ~/ ((MediaQuery.of(context).size.height - 129) / length) == index;

//                   Color color = selected && dragging ? tema.getAccentColorText() : tema.getScaffoldTextColor();

//                   return Container(
//                     color: selected && dragging ? tema.getAccentColor() : Theme.of(context).scaffoldBackgroundColor,
//                     child: ListTile(
//                       onTap: () async {
//                         await Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (BuildContext context) => widget.himnos[index].numero <= 517
//                                 ? HimnoPage(
//                                     numero: widget.himnos[index].numero,
//                                     titulo: widget.himnos[index].titulo,
//                                   )
//                                 : CoroPage(
//                                     numero: widget.himnos[index].numero,
//                                     titulo: widget.himnos[index].titulo,
//                                     transpose: widget.himnos[index].transpose,
//                                   ),
//                           ),
//                         );
//                         // scrollPosition = 105.0 - 90.0;
//                       },
//                       leading: widget.himnos[index].favorito
//                           ? Icon(
//                               Icons.star,
//                               color: color,
//                             )
//                           : null,
//                       title: Container(
//                         width: widget.himnos[index].favorito ? MediaQuery.of(context).size.width - 90 : MediaQuery.of(context).size.width - 50,
//                         child: Text(
//                           ((widget.himnos[index].numero > 517 ? '' : '${widget.himnos[index].numero} - ') + '${widget.himnos[index].titulo}'),
//                           softWrap: true,
//                           style: TextStyle(
//                             color: color,
//                             fontFamily: ScopedModel.of<TemaModel>(context).font,
//                           ),
//                         ),
//                       ),
//                       trailing: widget.himnos[index].descargado
//                           ? Icon(
//                               Icons.get_app,
//                               color: color,
//                             )
//                           : null,
//                     ),
//                   );
//                 },
//               ),
//         // We only render the side scrollbar if the list overflows the screen
//         widget.himnos.length * 60.0 > MediaQuery.of(context).size.height
//             ? Align(
//                 alignment: FractionalOffset.centerRight,
//                 child: GestureDetector(
//                     onVerticalDragStart: (DragStartDetails details) {
//                       double position;
//                       if (details.globalPosition.dy > MediaQuery.of(context).size.height - 25.0) {
//                         position = MediaQuery.of(context).size.height - 115.0;
//                       } else if (details.globalPosition.dy < 105) {
//                         position = 15.0;
//                       } else
//                         position = details.globalPosition.dy - 90;
//                       setState(() {
//                         scrollPosition = position;
//                         dragging = true;
//                       });
//                       int currentHimno = ((position - 15) ~/ ((MediaQuery.of(context).size.height - 129) / length) + 1);
//                       if (currentHimno > widget.himnos.length - (MediaQuery.of(context).size.height - 115.0) ~/ 56.0)
//                         scrollController.jumpTo(scrollController.position.maxScrollExtent);
//                       else
//                         scrollController.jumpTo((position - 15) ~/ ((MediaQuery.of(context).size.height - 129) / length) * 56.0);
//                     },
//                     onVerticalDragUpdate: (DragUpdateDetails details) {
//                       double position;
//                       if (details.globalPosition.dy > MediaQuery.of(context).size.height - 25.0) {
//                         position = MediaQuery.of(context).size.height - 115.0;
//                       } else if (details.globalPosition.dy < 105) {
//                         position = 15.0;
//                       } else
//                         position = details.globalPosition.dy - 90;
//                       setState(() {
//                         scrollPosition = position;
//                       });
//                       int currentHimno = ((position - 15) ~/ ((MediaQuery.of(context).size.height - 129) / length) + 1);
//                       if (currentHimno > widget.himnos.length - (MediaQuery.of(context).size.height - 115.0) ~/ 56.0)
//                         scrollController.animateTo(scrollController.position.maxScrollExtent,
//                             curve: Curves.easeInOut, duration: Duration(milliseconds: 200));
//                       else
//                         scrollController.jumpTo((position - 15) ~/ ((MediaQuery.of(context).size.height - 129) / length) * 56.0);
//                     },
//                     onVerticalDragEnd: (DragEndDetails details) {
//                       setState(() {
//                         dragging = false;
//                       });
//                     },
//                     child: Container(
//                       height: double.infinity,
//                       width: 40.0,
//                       child: CustomPaint(
//                         painter: SideScroller(
//                           context,
//                           himnos: widget.himnos,
//                           position: scrollPosition,
//                           dragging: dragging,
//                           numero: dragging ? (scrollPosition - 15) ~/ ((MediaQuery.of(context).size.height - 129) / length) : -1,
//                         ),
//                       ),
//                     )))
//             : Container()
//       ],
//     );
//   }

//   Widget cupertinoLayout(BuildContext context) {
//     final TemaModel tema = TemaModel.of(context);
//     int length = widget.himnos.length == 0 ? 1 : widget.himnos.length;
//     if (scrollPosition == double.infinity || scrollPosition == double.nan) {
//       scrollPosition = 72.0 + iPhoneXPadding;
//     }

//     return Stack(
//       children: <Widget>[
//         widget.himnos.isEmpty
//             ? Container(
//                 child: Center(
//                   child: Text(
//                     widget.mensaje,
//                     textScaleFactor: 1.5,
//                     textAlign: TextAlign.center,
//                     style: tema.getScaffoldTextStyle(context),
//                   ),
//                 ),
//               )
//             : ListView.builder(
//                 key: PageStorageKey('Scroller Tema'),
//                 controller: scrollController,
//                 itemCount: widget.himnos.length,
//                 itemBuilder: (BuildContext context, int index) {
//                   bool selected = (scrollPosition - 72.0 - iPhoneXPadding) ~/
//                           ((MediaQuery.of(context).size.height - 85.0 - widget.iPhoneXBottomPadding - 72.0 - iPhoneXPadding + 0.5) / length) ==
//                       index;

//                   return Container(
//                     color: selected && dragging ? tema.mainColor : tema.getScaffoldBackgroundColor(),
//                     height: 55.0,
//                     child: CupertinoButton(
//                       onPressed: () async {
//                         print(widget.himnos[index].numero > 517);
//                         await Navigator.push(
//                           context,
//                           CupertinoPageRoute(
//                             builder: (BuildContext context) => widget.himnos[index].numero <= 517
//                                 ? ScopedModel<TemaModel>(
//                                     model: tema,
//                                     child: HimnoPage(
//                                       numero: widget.himnos[index].numero,
//                                       titulo: widget.himnos[index].titulo,
//                                     ),
//                                   )
//                                 : ScopedModel<TemaModel>(
//                                     model: tema,
//                                     child: CoroPage(
//                                       numero: widget.himnos[index].numero,
//                                       titulo: widget.himnos[index].titulo,
//                                       transpose: widget.himnos[index].transpose,
//                                     ),
//                                   ),
//                           ),
//                         );
//                         // scrollPosition = 105.0 - 90.0;
//                       },
//                       child: Stack(
//                         children: <Widget>[
//                           Align(
//                               alignment: Alignment.center,
//                               child: Text(
//                                 ((widget.himnos[index].numero > 517 ? '' : '${widget.himnos[index].numero} - ') + '${widget.himnos[index].titulo}'),
//                                 softWrap: true,
//                                 textAlign: TextAlign.start,
//                                 style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
//                                       color: selected && dragging ? tema.mainColorContrast : tema.getScaffoldTextColor(),
//                                       fontFamily: ScopedModel.of<TemaModel>(context).font,
//                                     ),
//                               )),
//                           Align(
//                             alignment: Alignment.center,
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 widget.himnos[index].favorito
//                                     ? Icon(
//                                         Icons.star,
//                                         color: selected && dragging ? tema.mainColorContrast : tema.getScaffoldTextColor(),
//                                       )
//                                     : Container(),
//                                 widget.himnos[index].descargado
//                                     ? Icon(
//                                         Icons.get_app,
//                                         color: selected && dragging ? tema.mainColorContrast : tema.getScaffoldTextColor(),
//                                       )
//                                     : Container()
//                               ],
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//         // We only render the side scrollbar if the list overflows the screen
//         widget.himnos.length * 60.0 > MediaQuery.of(context).size.height
//             ? Align(
//                 alignment: FractionalOffset.centerRight,
//                 child: Container(
//                   transform: Matrix4.translationValues(0.0, (widget.iPhoneX && tema.brightness == Brightness.light ? -20.0 : 0.0), 0.0),
//                   margin: EdgeInsets.only(top: tema.brightness == Brightness.dark ? (widget.iPhoneX ? 70.0 : 65.0) : 0.0),
//                   child: GestureDetector(
//                       onVerticalDragStart: (DragStartDetails details) {
//                         double position;
//                         double bottomPadding = MediaQuery.of(context).size.height - 85.0 - widget.iPhoneXBottomPadding;
//                         double topPadding = 72.0 + iPhoneXPadding;
//                         double tileSize = 55.0;

//                         if (details.globalPosition.dy > bottomPadding + 15.0) {
//                           position = bottomPadding;
//                         } else if (details.globalPosition.dy < topPadding + 15.0) {
//                           position = topPadding;
//                         } else
//                           position = details.globalPosition.dy - 15.0;
//                         setState(() {
//                           scrollPosition = position;
//                           dragging = true;
//                         });

//                         int currentHimno = ((scrollPosition - topPadding) ~/ ((bottomPadding - topPadding + 0.5) / length) + 1);

//                         if (currentHimno > widget.himnos.length - (MediaQuery.of(context).size.height - 115.0) ~/ tileSize)
//                           scrollController.animateTo(scrollController.position.maxScrollExtent,
//                               curve: Curves.easeInOut, duration: Duration(milliseconds: 200));
//                         else
//                           scrollController.jumpTo((scrollPosition - topPadding) ~/ ((bottomPadding - topPadding + 0.5) / length) * tileSize);
//                       },
//                       onVerticalDragUpdate: (DragUpdateDetails details) {
//                         double position;
//                         double bottomPadding = MediaQuery.of(context).size.height - 85.0 - widget.iPhoneXBottomPadding;
//                         double topPadding = 72.0 + iPhoneXPadding;
//                         double tileSize = 55.0;

//                         if (details.globalPosition.dy > bottomPadding + 15.0) {
//                           position = bottomPadding;
//                         } else if (details.globalPosition.dy < topPadding + 15.0) {
//                           position = topPadding;
//                         } else
//                           position = details.globalPosition.dy - 15.0;

//                         setState(() {
//                           scrollPosition = position;
//                         });

//                         int currentHimno = ((scrollPosition - topPadding) ~/ ((bottomPadding - topPadding + 0.5) / length) + 1);

//                         if (currentHimno > widget.himnos.length - (MediaQuery.of(context).size.height - 115.0) ~/ tileSize)
//                           scrollController.animateTo(scrollController.position.maxScrollExtent,
//                               curve: Curves.easeInOut, duration: Duration(milliseconds: 200));
//                         else
//                           scrollController.jumpTo((scrollPosition - topPadding) ~/ ((bottomPadding - topPadding + 0.5) / length) * tileSize);
//                       },
//                       onVerticalDragEnd: (DragEndDetails details) {
//                         setState(() {
//                           dragging = false;
//                         });
//                       },
//                       child: Container(
//                         height: double.infinity,
//                         width: 40.0,
//                         child: Transform.translate(
//                           offset: Offset(0.0, -65.0),
//                           child: CustomPaint(
//                             painter: SideScroller(
//                               context,
//                               himnos: widget.himnos,
//                               position: scrollPosition,
//                               dragging: dragging,
//                               iPhoneXPadding: iPhoneXPadding,
//                               numero: dragging
//                                   ? (scrollPosition - 72.0 - iPhoneXPadding) ~/
//                                       ((MediaQuery.of(context).size.height - 85.0 - widget.iPhoneXBottomPadding - 72.0 - iPhoneXPadding + 0.5) /
//                                           length)
//                                   : -1,
//                             ),
//                           ),
//                         ),
//                       )),
//                 ))
//             : Container()
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return isAndroid() ? materialLayout(context) : cupertinoLayout(context);
//   }
// }

// class SideScroller extends CustomPainter {
//   double position;
//   bool dragging;
//   int numero;
//   List<Himno> himnos;
//   double iPhoneXPadding;
//   late TemaModel tema;

//   late Paint scrollBar;
//   late Color textColor;

//   SideScroller(
//     BuildContext context, {
//     required this.position,
//     required this.dragging,
//     required this.numero,
//     required this.himnos,
//     this.iPhoneXPadding = 0.0,
//   }) {
//     tema = TemaModel.of(context);
//     textColor = tema.getAccentColorText();

//     if (isAndroid()) {
//       scrollBar = Paint()
//         ..color = dragging ? tema.getAccentColor() : Colors.grey.withOpacity(0.5)
//         ..strokeWidth = 10.0
//         ..strokeCap = StrokeCap.round;
//     } else {
//       textColor = tema.brightness == Brightness.light ? Colors.white : tema.getTabTextColor();
//       scrollBar = Paint()
//         ..color = dragging ? tema.getAccentColor() : Colors.grey.withOpacity(0.5)
//         ..strokeWidth = 5.0
//         ..strokeCap = StrokeCap.round;
//     }
//   }

//   @override
//   void paint(Canvas canvas, Size size) {
//     if (isAndroid()) {
//       canvas.drawLine(Offset(size.width - 15, position), Offset(size.width - 15, position + 20), scrollBar);
//     } else {
//       canvas.drawLine(Offset(size.width - 5, position), Offset(size.width - 5, position + 30), scrollBar);
//     }
//     if (dragging) {
//       String text = himnos[numero].numero <= 517 ? himnos[numero].numero.toString() : himnos[numero].titulo[0];
//       double textPosition;

//       if (isAndroid()) {
//         textPosition = position < 90.0 ? 90.0 : position;
//       } else {
//         textPosition = position < 155.0 + iPhoneXPadding ? 155.0 + iPhoneXPadding : position;
//       }

//       for (int i = 0; i < text.length; ++i) canvas.drawCircle(Offset(size.width - 85 - 5 * i, textPosition - 40), 45.0, scrollBar);
//       canvas.drawRect(Rect.fromCircle(center: Offset(size.width - 62, textPosition - 17), radius: 22.0), scrollBar);
//       TextPainter(
//           text: TextSpan(
//               text: text,
//               style: TextStyle(
//                 fontSize: 45.0,
//               )),
//           textDirection: TextDirection.ltr)
//         ..layout()
//         ..paint(canvas, Offset(size.width - (text == "M" ? 132 : 127) - 15 * (text.length - 3), textPosition - 65));
//     }
//   }

//   @override
//   bool shouldRepaint(SideScroller oldDelegate) {
//     return oldDelegate.position != position || oldDelegate.dragging != dragging;
//   }
// }
