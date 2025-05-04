class Himno {
  int numero;
  String titulo;
  int transpose;
  int autoScrollSpeed;
  bool favorito;
  bool descargado;
  // double initFontSize;
  // List<Parrafo> parrafos;

  Himno({
    required this.numero,
    required this.titulo,
    this.favorito = false,
    this.descargado = false,
    this.transpose = 0,
    this.autoScrollSpeed = 0,
    // required this.parrafos,
  });

  static List<Himno> fromJson(List<dynamic> res) {
    List<Himno> himno = [];
    for (var x in res) {
      himno.add(
        Himno(
          numero: x['id'],
          titulo: x['titulo'],
          transpose: x['transpose'] ?? 0,
          autoScrollSpeed: x['scroll_speed'] ?? 0,
        ),
      );
    }
    return himno;
  }
}

class Parrafo {
  // int numero;
  int orden;
  bool coro;
  String parrafo;
  String? acordes;
  String? acordesAmericano;

  Parrafo({
    // required this.numero,
    required this.orden,
    required this.coro,
    required this.parrafo,
    required this.acordes,
    required this.acordesAmericano,
  });

  static List<Parrafo> fromJson(List<dynamic> res) {
    List<Parrafo> parrafos = [];
    int numeroEstrofa = 0;
    for (var x in res) {
      if (x['coro'] == 0) ++numeroEstrofa;
      parrafos.add(Parrafo(
        // numero: x['numero'],
        orden: numeroEstrofa,
        coro: x['coro'] == 1 ? true : false,
        parrafo: x['parrafo'],
        acordes: x['acordes'] ?? null,
        acordesAmericano: Acordes.toAmericano(x['acordes']),
      ));
    }
    return parrafos;
  }
}

abstract class Acordes {
  static Map<String, List<String>> acordes = {
    'latina': ['Do', 'Do#', 'Re', 'Re#', 'Mi', 'Fa', 'Fa#', 'Sol', 'Sol#', 'La', 'La#', 'Si'],
    'americana': ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
  };

  static List<String> transpose(int value, List<String> original) {
    if (value == 0)
      return original;
    else if (value.isNegative) value = 12 + value;

    for (int i = 0; i < original.length; ++i) {
      int acordeStart = original[i].indexOf(RegExp(r'[A-Z]'));
      while (acordeStart != -1) {
        int acordeEnd = original[i].indexOf(' ', acordeStart) == -1 ? original[i].length : original[i].indexOf(' ', acordeStart);
        for (int j = Acordes.acordes['latina']!.length - 1; j >= 0; --j) {
          if (original[i].substring(acordeStart, acordeEnd).indexOf(Acordes.acordes['latina']![j]) != -1) {
            int index = j + value > Acordes.acordes['latina']!.length - 1 ? value - (12 - j) : j + value;
            original[i] = original[i].replaceFirst(Acordes.acordes['latina']![j], Acordes.acordes['latina']![index], acordeStart);
            break;
          }
        }

        acordeEnd = original[i].indexOf(' ', acordeStart) == -1 ? original[i].length : original[i].indexOf(' ', acordeStart);
        acordeStart = original[i].indexOf(RegExp(r'[A-Z]'), acordeEnd);
      }
    }

    return original;
  }

  static String? toAmericano(String? original) {
    if (original == null || original == '') return null;

    String aux = '';
    List<String> lineas = original.split('\n');

    for (int i = 0; i < lineas.length; ++i) {
      int acordeStart = lineas[i].indexOf(RegExp(r'[A-Z]'));
      while (acordeStart != -1) {
        int acordeEnd = lineas[i].indexOf(' ', acordeStart) == -1 ? lineas[i].length : lineas[i].indexOf(' ', acordeStart);
        for (int j = Acordes.acordes['latina']!.length - 1; j >= 0; --j) {
          if (lineas[i].substring(acordeStart, acordeEnd).indexOf(Acordes.acordes['latina']![j]) != -1) {
            lineas[i] = lineas[i].replaceFirst(Acordes.acordes['latina']![j], Acordes.acordes['americana']![j], acordeStart);
            break;
          }
        }
        acordeEnd = lineas[i].indexOf(' ', acordeStart) == -1 ? lineas[i].length : lineas[i].indexOf(' ', acordeStart);
        acordeStart = lineas[i].indexOf(RegExp(r'[A-Z]'), acordeEnd);
      }
    }

    aux = lineas.join('\n');

    return aux;
  }
}
