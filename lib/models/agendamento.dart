class Agendamento {
  int? id; // 👈 ADICIONAR ISSO

  String nome;
  String procedimento;
  String valor;
  String data;
  String hora;

  Agendamento({
    this.id, // 👈 ADICIONAR AQUI
    required this.nome,
    required this.procedimento,
    required this.valor,
    required this.data,
    required this.hora,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id, // 👈 IMPORTANTE
      "nome": nome,
      "procedimento": procedimento,
      "valor": valor,
      "data": data,
      "hora": hora,
    };
  }

  factory Agendamento.fromMap(Map<String, dynamic> map) {
    return Agendamento(
      id: map["id"], // 👈 IMPORTANTE
      nome: map["nome"],
      procedimento: map["procedimento"],
      valor: map["valor"].toString(),
      data: map["data"],
      hora: map["hora"],
    );
  }
}