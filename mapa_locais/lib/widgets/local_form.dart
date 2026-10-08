import 'package:flutter/material.dart';
import '../models/local.dart';

class LocalFormModal extends StatefulWidget {
  final Local? localParaEditar;
  final Function(Local) onSalvar;

  const LocalFormModal({super.key, this.localParaEditar, required this.onSalvar});

  @override
  State<LocalFormModal> createState() => _LocalFormModalState();
}

class _LocalFormModalState extends State<LocalFormModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeCtrl;
  late TextEditingController _avaliacaoCtrl;
  late TextEditingController _distanciaCtrl;
  late TextEditingController _horarioCtrl;
  late TextEditingController _descricaoCtrl;

  String _cidadeSelecionada = 'São Paulo';
  String _categoriaSelecionada = 'Academia';

  final List<String> _cidades = ['São Paulo', 'Campinas', 'Jundiaí'];
  final List<String> _categorias = ['Academia', 'Restaurante', 'Parque', 'Café', 'Outros'];

  @override
  void initState() {
    super.initState();
    final l = widget.localParaEditar;
    _nomeCtrl = TextEditingController(text: l?.nome ?? '');
    _avaliacaoCtrl = TextEditingController(text: l?.avaliacao.toString() ?? '4.5');
    _distanciaCtrl = TextEditingController(text: l?.distancia.toString() ?? '1.0');
    _horarioCtrl = TextEditingController(text: l?.horario ?? '08:00 - 18:00');
    _descricaoCtrl = TextEditingController(text: l?.descricao ?? '');
    
    if (l != null) {
      if (_cidades.contains(l.cidade)) _cidadeSelecionada = l.cidade;
      if (_categorias.contains(l.categoria)) _categoriaSelecionada = l.categoria;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16, right: 16, top: 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.localParaEditar == null ? 'Novo Local' : 'Editar Local', 
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _nomeCtrl,
                decoration: const InputDecoration(labelText: 'Nome do Local'),
                validator: (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
              ),
              DropdownButtonFormField<String>(
                value: _cidadeSelecionada,
                decoration: const InputDecoration(labelText: 'Cidade'),
                items: _cidades.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _cidadeSelecionada = v!),
              ),
              DropdownButtonFormField<String>(
                value: _categoriaSelecionada,
                decoration: const InputDecoration(labelText: 'Categoria'),
                items: _categorias.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _categoriaSelecionada = v!),
              ),
              TextFormField(
                controller: _horarioCtrl,
                decoration: const InputDecoration(labelText: 'Horário de Funcionamento'),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _avaliacaoCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Avaliação (0-5)'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _distanciaCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Distância (km)'),
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _descricaoCtrl,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 2,
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final novoLocal = Local(
                      id: widget.localParaEditar?.id ?? '',
                      nome: _nomeCtrl.text,
                      categoria: _categoriaSelecionada,
                      cidade: _cidadeSelecionada,
                      avaliacao: double.tryParse(_avaliacaoCtrl.text) ?? 0,
                      distancia: double.tryParse(_distanciaCtrl.text) ?? 0,
                      horario: _horarioCtrl.text,
                      descricao: _descricaoCtrl.text,
                      favorito: widget.localParaEditar?.favorito ?? false,
                    );
                    widget.onSalvar(novoLocal);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Salvar'),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}