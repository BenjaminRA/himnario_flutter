import 'package:shared_preferences/shared_preferences.dart';

class VoicesApi {
  static String _base = 'http://api-himnario-legacy.songbooksofpraise.com:8085';

  static String voicesAvailable() => _base + '/disponibles';
  static String voiceAvailable(int number) => _base + '/himno/$number/Soprano/disponible';
  static String getVoice(int number, String voice) => _base + '/himno/$number/$voice';
  static String getVoiceDuration(int number, String voice) => _base + '/himno/$number/$voice/duracion';
}

class SheetsApi {
  static String _base = 'http://api-himnario-legacy.songbooksofpraise.com:8085';

  static Future<String> sheetAvailable(int number) async {
    String endpoint = await SharedPreferences.getInstance().then((prefs) {
      if (prefs.getBool('dev_mode') == true) {
        return 'partitura_con_acordes';
      }

      return 'partitura';
    }).catchError((_) => 'partitura');

    return _base + '/$endpoint/$number/disponible';
  }

  static Future<String> getSheet(int number) async {
    String endpoint = await SharedPreferences.getInstance().then((prefs) {
      if (prefs.getBool('dev_mode') == true) {
        return 'partitura_con_acordes';
      }

      return 'partitura';
    }).catchError((_) => 'partitura');

    return _base + '/$endpoint/$number';
  }
}

class DatabaseApi {
  static String _base = 'http://api-himnario-legacy.songbooksofpraise.com:8085';

  static String getDb() => _base + '/db';
  static String checkUpdates() => _base + '/updates';
  static String getAnuncios() => _base + '/anuncios';
}
