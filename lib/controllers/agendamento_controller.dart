import '../database/database_helper.dart';
import '../models/agendamento.dart';

class AgendamentoController {
  final db = DatabaseHelper.instance;

  // ✅ SALVAR
  Future<bool> salvar(Agendamento agendamento) async {
    try {
      bool existe = await db.horarioExiste(
        agendamento.data,
        agendamento.hora,
      );

      if (existe) return false;

      await db.inserir(agendamento.toMap());
      return true;
    } catch (e) {
      print("Erro ao salvar: $e");
      return false;
    }
  }

  // ✅ LISTAR
  Future<List<Agendamento>> listar() async {
    try {
      final dados = await db.listar();

      List<Agendamento> lista =
      dados.map((e) => Agendamento.fromMap(e)).toList();

      // 🔥 Ordenar por data e hora
      lista.sort((a, b) {
        DateTime dataA = DateTime.parse("${a.data}T${a.hora}");
        DateTime dataB = DateTime.parse("${b.data}T${b.hora}");
        return dataA.compareTo(dataB);
      });

      return lista;
    } catch (e) {
      print("Erro ao listar: $e");
      return [];
    }
  }

  // 🗑️ EXCLUIR (já deixa pronto)
  Future<void> excluir(int id) async {
    try {
      await db.excluir(id);
    } catch (e) {
      print("Erro ao excluir: $e");
    }
  }

  // ✏️ ATUALIZAR (já deixa pronto)
  Future<void> atualizar(Agendamento agendamento) async {
    try {
      await db.atualizar(agendamento.toMap());
    } catch (e) {
      print("Erro ao atualizar: $e");
    }
  }
}