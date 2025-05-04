import 'package:Himnario/helpers/isAndroid.dart';
import 'package:Himnario/helpers/smallDevice.dart';
import 'package:Himnario/models/tema.dart';
import 'package:flutter/material.dart';

class VoicesProgressBar extends StatefulWidget {
  final double currentProgress;
  final int duration;
  final Function onSelected;
  final Function onDragStart;

  VoicesProgressBar({
    required this.currentProgress,
    required this.duration,
    required this.onSelected,
    required this.onDragStart,
  });

  @override
  _VoicesProgressBarState createState() => _VoicesProgressBarState();
}

class _VoicesProgressBarState extends State<VoicesProgressBar> {
  late bool dragging;
  late double draggingProgress;

  @override
  void initState() {
    super.initState();
    dragging = false;
    draggingProgress = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragDown: (DragDownDetails details) {
        widget.onDragStart();
        double nextProgress = (details.globalPosition.dx - 10.0) / (MediaQuery.of(context).size.width - 10.0);
        if (nextProgress <= 0.0)
          nextProgress = 0.0;
        else if (nextProgress >= 1.0) nextProgress = 1.0;
        print('onHorizontalDragStart');
        setState(() {
          draggingProgress = nextProgress;
          dragging = true;
        });
      },
      onHorizontalDragCancel: () {
        setState(() {
          dragging = false;
        });
        widget.onSelected(draggingProgress);
      },
      onHorizontalDragStart: (DragStartDetails details) {
        double nextProgress = (details.globalPosition.dx - 10.0) / (MediaQuery.of(context).size.width - 10.0);
        if (nextProgress <= 0.0)
          nextProgress = 0.0;
        else if (nextProgress >= 1.0) nextProgress = 1.0;
        print('onHorizontalDragStart');
        setState(() {
          draggingProgress = nextProgress;
          dragging = true;
        });
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        double nextProgress = (details.globalPosition.dx - 10.0) / (MediaQuery.of(context).size.width - 10.0);
        if (nextProgress <= 0.0)
          nextProgress = 0.0;
        else if (nextProgress >= 1.0) nextProgress = 1.0;
        setState(() => draggingProgress = nextProgress);
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        print('onHorizontalDragEnd');
        // double nextProgress = (details.globalPosition.dx - 10.0)/(MediaQuery.of(context).size.width - 10.0);
        setState(() {
          dragging = false;
        });
        widget.onSelected(draggingProgress);
      },
      child: CustomPaint(
        painter: CustomSlider(
          progress: dragging ? draggingProgress : widget.currentProgress,
          dragging: dragging,
          duration: widget.duration,
          context: context,
        ),
        child: Container(
          // color: Theme.of(context).primaryColor,
          height: 30.0,
          width: MediaQuery.of(context).size.width - 20.0,
        ),
      ),
    );
  }
}

class CustomSlider extends CustomPainter {
  double progress;
  bool dragging;
  int duration;
  BuildContext context;

  CustomSlider({
    required this.progress,
    required this.context,
    required this.dragging,
    required this.duration,
  }) {
    duration = (duration.isNaN || duration == double.infinity) ? 0 : duration;
    progress = progress.isNaN || progress == double.infinity ? 0.0 : progress;
    // primaryColorPaint = Paint()
    //   ..color = Colors.black
    //   ..strokeWidth = 10.0;
    // secondaryColorPaint = Paint()
    //   ..color = Colors.grey
    //   ..strokeWidth = 10.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    double currentProgress = size.width * progress;
    double position = size.height * 0.65;

    final tema = TemaModel.of(context);
    Color lineColor = tema.brightness == Brightness.dark ? Colors.white : Colors.black;
    Color textColor = tema.brightness == Brightness.dark ? Colors.white : Colors.black;
    Color textBackgroundColor = tema.brightness == Brightness.dark ? Colors.black : Colors.white;

    TextPainter text = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      text: TextSpan(
        text: '${(duration * progress / 1000).floor()}s',
        style: TextStyle(
          color: textColor,
          fontSize: 40.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    Paint primaryColorPaint = Paint()
      ..color = lineColor
      ..strokeWidth = 10.0;
    Paint secondaryColorPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 10.0;

    canvas.drawLine(Offset(0.0, position), Offset(currentProgress, position), primaryColorPaint);
    canvas.drawLine(Offset(currentProgress, position), Offset(size.width, position), secondaryColorPaint);

    if (dragging) {
      if (!isAndroid() || smallDevice(context))
        currentProgress = currentProgress > size.width - 90.0 ? size.width - 90.0 : currentProgress;
      else
        currentProgress = currentProgress > size.width - 160.0 ? size.width - 160.0 : currentProgress;
      double height = 50.0;
      double radius = 70.0;
      canvas.drawLine(
          Offset(currentProgress, position + 5.0),
          Offset(currentProgress, -height),
          Paint()
            ..color = lineColor
            ..strokeWidth = 6.0);
      canvas.skew(-0.2, 0.0);
      canvas.drawOval(
          Rect.fromPoints(Offset(currentProgress - 15.0, -(height - radius / 2)), Offset(currentProgress + radius * 1.2, -(height + radius * 0.78))),
          primaryColorPaint);
      canvas.drawOval(
          Rect.fromPoints(
              Offset(currentProgress - radius * 0.1, -(height - radius * 0.35)), Offset(currentProgress + radius * 1.1, -(height + radius * 0.65))),
          Paint()..color = textBackgroundColor);
      canvas.skew(0.2, 0.0);
      text.layout(maxWidth: 100.0, minWidth: 100.0);
      text.paint(canvas, Offset(currentProgress + radius * -0.05, -(height + radius * 0.47)));
    }
  }

  @override
  bool shouldRepaint(CustomSlider oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.dragging != dragging;
  }
}
