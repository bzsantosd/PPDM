import 'package:flutter/material.dart';
import '../models/local.dart';
import '../services/local_service.dart';

class LocalFormBottomSheet extends StatefulWidget {
  final Local? local;
  final String? cidadePadrao;

  const LocalFormBottomSheet({super.key, this.local, this.cidadePadrao});

  @override
  State<LocalFormBottomSheet> createState() => _LocalFormBottomSheetState();
}

class _LocalFormBottomSheetState extends State<LocalFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomeController;
  late TextEditingController _avaliacaoController;
  late TextEditingController _distanciaController;
  late TextEditingController _horarioController;
  late TextEditingController _descricaoController;

  late String _categoriaSelecionada;
  late String _cidadeSelecionada;

  final List<String> _cidades = ['São Paulo', 'Campinas', 'Jundiaí'];
  final List<String> _categorias = ['Academia', 'Restaurante', 'Café', 'Parque', 'Farmácia', 'Outros'];

  @override
  void initState() {
    super.initState();
    final l = widget.local;
    _nomeController = TextEditingController(text: l?.nome ?? '');
    _avaliacaoController = TextEditingController(text: l?.avaliacao.toString() ?? '4.5');
    _distanciaController = TextEditingController(text: l?.distancia.toString() ?? '1.0');
    _horarioController = TextEditingController(text: l?.horario ?? '08:00 - 18:00');
    _descricaoController = TextEditingController(text: l?.descricao ?? '');

    _cidadeSelecionada = l?.cidade ?? (widget.cidadePadrao ?? 'São Paulo');
    if (!_cidades.contains(_cidadeSelecionada)) {
      _cidadeSelecionada = 'São Paulo';
    }

    _categoriaSelecionada = l?.categoria ?? 'Restaurante';
    if (!_categorias.contains(_categoriaSelecionada)) {
      _categoriaSelecionada = 'Outros';
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _avaliacaoController.dispose();
    _distanciaController.dispose();
    _horarioController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_formKey.currentState!.validate()) {
      try {
        final novoLocal = Local(
          id: widget.local?.id ?? '',
          nome: _nomeController.text.trim(),
          categoria: _categoriaSelecionada,
          cidade: _cidadeSelecionada,
          avaliacao: double.tryParse(_avaliacaoController.text) ?? 0.0,
          distancia: double.tryParse(_distanciaController.text) ?? 0.0,
          horario: _horarioController.text.trim(),
          descricao: _descricaoController.text.trim(),
          favorito: widget.local?.favorito ?? false,
        );

        if (widget.local == null) {
          await LocalService().adicionar(novoLocal);
        } else {
          await LocalService().atualizar(novoLocal);
        }

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.local == null ? 'Local cadastrado com sucesso!' : 'Local atualizado!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao salvar local: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16,
        left: 16,
        right: 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.local == null ? 'Cadastrar Novo Local' : 'Editar Local',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome do Estabelecimento'),
                validator: (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _cidadeSelecionada,
                      decoration: const InputDecoration(labelText: 'Cidade'),
                      items: _cidades.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setState(() => _cidadeSelecionada = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _categoriaSelecionada,
                      decoration: const InputDecoration(labelText: 'Categoria'),
                      items: _categorias.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                      onChanged: (v) => setState(() => _categoriaSelecionada = v!),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _avaliacaoController,
                      decoration: const InputDecoration(labelText: 'Avaliação (0-5)'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _distanciaController,
                      decoration: const InputDecoration(labelText: 'Distância (km)'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _horarioController,
                decoration: const InputDecoration(labelText: 'Horário de Funcionamento'),
              ),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _salvar,
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(45)),
                child: const Text('Salvar'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}