import 'package:flutter/material.dart';
import '../controllers/agendamento_controller.dart';
import '../models/agendamento.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

class AgendamentoPage extends StatefulWidget {
  final DateTime dataSelecionada;
  final Agendamento? agendamento; // 👈 NOVO

  AgendamentoPage({
    required this.dataSelecionada,
    this.agendamento,
  });


  @override
  _AgendamentoPageState createState() => _AgendamentoPageState();
}

class _AgendamentoPageState extends State<AgendamentoPage> {

  @override
  void initState() {
    super.initState();

    if (widget.agendamento != null) {
      nomeController.text = widget.agendamento!.nome;
      procedimentoController.text = widget.agendamento!.procedimento;
      valorController.text = widget.agendamento!.valor;

      final partes = widget.agendamento!.hora.split(":");
      horaSelecionada = TimeOfDay(
        hour: int.parse(partes[0]),
        minute: int.parse(partes[1]),
      );
    }
  }

  final controller = AgendamentoController();

  final nomeController = TextEditingController();
  final procedimentoController = TextEditingController();
  final valorController = MoneyMaskedTextController(
    decimalSeparator: ',',
    thousandSeparator: '.',
    leftSymbol: 'R\$ ',
  );

  TimeOfDay? horaSelecionada;

  String formatarData(DateTime data) {
    return "${data.day.toString().padLeft(2, '0')}/"
        "${data.month.toString().padLeft(2, '0')}/"
        "${data.year}";
  }

  String formatarHora(TimeOfDay hora) {
    return "${hora.hour.toString().padLeft(2, '0')}:"
        "${hora.minute.toString().padLeft(2, '0')}";
  }

  void selecionarHora() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) setState(() => horaSelecionada = picked);
  }

  void salvar() async {
    if (horaSelecionada == null) return;

    String data =
        "${widget.dataSelecionada.year}-"
        "${widget.dataSelecionada.month.toString().padLeft(2, '0')}-"
        "${widget.dataSelecionada.day.toString().padLeft(2, '0')}";

    final agendamento = Agendamento(
      id: widget.agendamento?.id, // 👈 IMPORTANTE
      nome: nomeController.text,
      procedimento: procedimentoController.text,
      valor: valorController.numberValue.toString(),
      data: data,
      hora: formatarHora(horaSelecionada!),
    );

    // ✏️ EDITAR OU SALVAR
    if (widget.agendamento != null) {
      await controller.atualizar(agendamento);
    } else {
      bool sucesso = await controller.salvar(agendamento);

      if (!sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Horário já ocupado")),
        );
        return;
      }
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.agendamento == null
              ? "Novo Agendamento"
              : "Editar Agendamento"),
        ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 📅 DATA
              Center(
                child: Text(
                  "Data: ${formatarData(widget.dataSelecionada)}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[800],
                  ),
                ),
              ),

              SizedBox(height: 30),

              // 👤 NOME
              Text("Paciente", style: TextStyle(color: Colors.brown[700])),
              SizedBox(height: 5),
              TextField(
                controller: nomeController,
                decoration: InputDecoration(
                  hintText: "Digite o nome",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // 💉 PROCEDIMENTO
              Text("Procedimento", style: TextStyle(color: Colors.brown[700])),
              SizedBox(height: 5),
              TextField(
                controller: procedimentoController,
                decoration: InputDecoration(
                  hintText: "Ex: Limpeza de pele",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // 💰 VALOR
              Text("Valor", style: TextStyle(color: Colors.brown[700])),
              SizedBox(height: 5),
              TextField(
                controller: valorController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixText: "R\$ ",
                  hintText: "0,00",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              SizedBox(height: 25),

              // ⏰ HORA
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: selecionarHora,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text("Selecionar Hora"),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    horaSelecionada == null
                        ? "--:--"
                        : "${horaSelecionada!.hour.toString().padLeft(2, '0')}:${horaSelecionada!.minute.toString().padLeft(2, '0')}",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),

              SizedBox(height: 30),

              // 💾 BOTÃO SALVAR
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: salvar,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: Color(0xFFD8BFAA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Salvar",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}