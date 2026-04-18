import 'dart:io';
import 'package:agenda/views/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../config/app_config.dart';
import '../controllers/agendamento_controller.dart';
import 'agendamento_page.dart';
import '../models/agendamento.dart';
import 'package:intl/intl.dart';
import 'settings_page.dart';

class CalendarioPage extends StatefulWidget {

  @override
  _CalendarioPageState createState() => _CalendarioPageState();
}

class _CalendarioPageState extends State<CalendarioPage> {

  double calcularTotalDia() {
    final lista = _getEventos(selecionado ?? hoje);

    double total = 0;

    for (var e in lista) {
      total += double.tryParse(e.valor) ?? 0;
    }

    return total;
  }

  String formatarReal(double valor) {
    return NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    ).format(valor);
  }

  String formatarDataHora(String data, String hora) {
    DateTime dt = DateTime.parse("$data $hora");

    String dia = dt.day.toString().padLeft(2, '0');
    String mes = dt.month.toString().padLeft(2, '0');

    return "$dia/$mes às $hora";
  }

  List<Agendamento> todosAgendamentos = [];

  @override
  void initState() {
    super.initState();
    selecionado = hoje;
    carregar();
  }

  final controller = AgendamentoController();

  DateTime hoje = DateTime.now();
  DateTime? selecionado;

  Map<DateTime, List<Agendamento>> eventos = {};

  void carregar() async {
    final lista = await controller.listar();

    Map<DateTime, List<Agendamento>> temp = {};

    for (var item in lista) {
      DateTime data = DateTime.parse(item.data);
      final dia = DateTime(data.year, data.month, data.day);

      temp.putIfAbsent(dia, () => <Agendamento>[]);
      temp[dia]!.add(item);
    }

    // ordenar por data + hora
    lista.sort((a, b) {
      DateTime aDt = DateTime.parse("${a.data}T${a.hora}");
      DateTime bDt = DateTime.parse("${b.data}T${b.hora}");
      return aDt.compareTo(bDt);
    });

    setState(() {
      eventos = temp;
      todosAgendamentos = lista;
    });
  }

  List<Agendamento> _getEventos(DateTime dia) {
    return eventos[DateTime(dia.year, dia.month, dia.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Agenda"),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsPage()),
              );

              if (result == true) {
                setState(() {});
              }
            },
          ),

          if (AppConfig.logoPath != null)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Image.file(
                File(AppConfig.logoPath!),
                height: 35,
                fit: BoxFit.contain,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'pt_BR',
            firstDay: DateTime.utc(2020),
            lastDay: DateTime.utc(2100),
            focusedDay: hoje,
            selectedDayPredicate: (day) => isSameDay(selecionado, day),
            eventLoader: (day) => _getEventos(day),
            onDaySelected: (selectedDay, _) async {
              setState(() => selecionado = selectedDay);

              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AgendamentoPage(dataSelecionada: selectedDay),
                ),
              );

              if (result == true) carregar();
            },
          ),
          Container(
            margin: EdgeInsets.all(12),
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total do dia", style: TextStyle(fontSize: 16)),
                Text(
                  formatarReal(calcularTotalDia()),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: todosAgendamentos.isEmpty
                ? Center(child: Text("Nenhum agendamento"))
                : ListView(
              children: todosAgendamentos.map((e) {
                return ListTile(
                  title: Text(e.nome),

                  subtitle: Text(
                    "${e.procedimento} | R\$ ${e.valor} | ${e.hora}",
                  ),

                  isThreeLine: true,

                  // ✏️ EDITAR
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AgendamentoPage(
                          dataSelecionada: DateTime.parse(e.data),
                          agendamento: e,
                        ),
                      ),
                    );

                    if (result == true) carregar();
                  },

                  // 🗑️ EXCLUIR
                  onLongPress: () async {
                    bool? confirmar = await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text("Excluir"),
                        content: Text("Deseja excluir este agendamento?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text("Cancelar"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text("Excluir"),
                          ),
                        ],
                      ),
                    );

                    if (confirmar == true) {
                      await controller.excluir(e.id!);
                      carregar();
                    }
                  },
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }
}