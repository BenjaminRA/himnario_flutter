import 'package:flutter/widgets.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/material.dart';

class TemaModel extends Model {
  Color _mainColor = Color(3438868728);
  Color _mainColorContrast = Colors.black;
  Brightness _brightness = Brightness.light;
  String _font = 'Merriweather';

  Color get mainColor => _mainColor;
  Color get mainColorContrast => _mainColorContrast;
  Brightness get brightness => _brightness;
  String get font => _font;

  static TemaModel of(BuildContext context, {bool rebuildOnChange = true}) => ScopedModel.of<TemaModel>(context, rebuildOnChange: rebuildOnChange);

  void setMainColor(Color color) {
    _mainColor = color;
    _mainColorContrast = (color.red * 0.299 + color.green * 0.587 + color.blue * 0.114) > 172 ? Colors.black : Colors.white;
    notifyListeners();
  }

  void setFont(String font) {
    _font = font;
    notifyListeners();
  }

  void setBrightness(Brightness brightness) {
    _brightness = brightness;
    notifyListeners();
  }

  Color getTabBackgroundColor() => _brightness == Brightness.light ? _mainColor : Color.fromRGBO(33, 33, 33, 0.7176470588235294);
  Color getScaffoldBackgroundColor() => _brightness == Brightness.light ? Colors.white : Colors.black;
  Color getTabTextColor() => _brightness == Brightness.light ? _mainColorContrast : Colors.white;
  Color getScaffoldTextColor() => _brightness == Brightness.light ? Colors.black : Colors.white;
  Color getAccentColor() => _mainColor;
  Color getAccentColorText() => _mainColorContrast;
  Color getScaffoldAccentColor() => mainColorContrast == Colors.white && brightness == Brightness.dark
      ? Colors.white
      : mainColorContrast == Colors.black && brightness == Brightness.light
          ? Colors.black
          : getAccentColor();

  TextStyle getScaffoldTextStyle(context) => DefaultTextStyle.of(context).style.copyWith(
        color: getScaffoldTextColor(),
        fontFamily: font,
      );

  TextStyle getButtonTextStyle(context) => DefaultTextStyle.of(context).style.copyWith(
        color: getAccentColor(),
        fontFamily: font,
      );
}

Color getColorShade(Color color, double shade) {
  if (shade < 0.0 || shade > 1.0) {
    throw ArgumentError('Shade must be between 0.0 and 1.0');
  }

  shade = 1 - shade; // Invert the shade value to get the desired effect

  int red = (color.red + (255 - color.red) * shade).toInt();
  int green = (color.green + (255 - color.green) * shade).toInt();
  int blue = (color.blue + (255 - color.blue) * shade).toInt();

  return Color.fromARGB(color.alpha, red, green, blue);
}
