import 'package:Himnario/db/db.dart';

void registerVisita(int id) async {
  try {
    await DB.rawInsert('INSERT INTO visitas (himno_id, date) VALUES (?, ?)', arguments: [id, DateTime.now().toIso8601String()]);
  } catch (e) {
    print(e);
  }
}
