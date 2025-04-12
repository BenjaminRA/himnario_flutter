class Categoria {
  int id;
  String categoria;
  List<SubCategoria> subCategorias = [];

  Categoria({
    required this.id,
    required this.categoria,
    List<SubCategoria>? subCategorias,
  }) {
    subCategorias = subCategorias ?? [];
  }

  static List<Categoria> fromJson(List<dynamic> res) {
    List<Categoria> categorias = [];
    for (var x in res) {
      categorias.add(Categoria(id: x['id'], categoria: x['tema']));
    }
    return categorias;
  }
}

class SubCategoria {
  int id;
  String subCategoria;
  int? categoriaId;

  SubCategoria({
    required this.id,
    required this.subCategoria,
    this.categoriaId,
  });

  static List<SubCategoria> fromJson(List<dynamic> res) {
    List<SubCategoria> subCategorias = [];
    for (var x in res) {
      subCategorias.add(SubCategoria(id: x['id'], subCategoria: x['sub_tema'], categoriaId: x['tema_id']));
    }
    return subCategorias;
  }
}
