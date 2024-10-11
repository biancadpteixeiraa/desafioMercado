class Alimento {
  int? id;
  String nome;
  double preco;

  Alimento({this.id, required this.nome, required this.preco});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'preco': preco,
    };
  }

  factory Alimento.fromMap(Map<String, dynamic> map) {
    return Alimento(
      id: map['id'],
      nome: map['nome'],
      preco: map['preco'].toDouble(),
    );
  }
}
