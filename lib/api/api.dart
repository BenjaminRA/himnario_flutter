class VoicesApi {
  static String _base = 'http://api-himnario-legacy.songbooksofpraise.com:8085';

  static String voicesAvailable() => _base + '/disponibles';
  static String voiceAvailable(int number) => _base + '/himno/$number/Soprano/disponible';
  static String getVoice(int number, String voice) => _base + '/himno/$number/$voice';
  static String getVoiceDuration(int number, String voice) => _base + '/himno/$number/$voice/duracion';
}

class SheetsApi {
  static String _base = 'http://api-himnario-legacy.songbooksofpraise.com:8085';

  static String sheetAvailable(int number) => _base + '/partitura/$number/disponible';
  static String getSheet(int number) => _base + '/partitura/$number';
}

class DatabaseApi {
  static String _base = 'http://api-himnario-legacy.songbooksofpraise.com:8085';

  static String getDb() => _base + '/db';
  static String checkUpdates() => _base + '/updates';
  static String getAnuncios() => _base + '/anuncios';
}
