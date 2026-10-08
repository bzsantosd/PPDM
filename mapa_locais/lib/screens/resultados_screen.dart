import 'package:flutter/material.dart';
import '../models/local.dart';
import '../services/local_service.dart';
import '../dialogs/confirm_delete.dart';
import '../widgets/local_form.dart';
import 'detalhes_screen.dart';

class ResultadosScreen extends StatefulWidget {
  final String cidadeInicial;
  final String pesquisaInicial;

  const ResultadosScreen({super.key, required this.cidadeInicial, required this.pesquisaInicial});

  @override
  State<ResultadosScreen> createState() => _ResultadosScreenState();
}

class _ResultadosScreenState extends State<ResultadosScreen> {
  final LocalService _service = LocalService();
  late TextEditingController _searchCtrl;
  late String _cidadeFiltro;
  String _categoriaFiltro = 'Todos';

  final List<String> _cidades = ['Todas', 'São Paulo', 'Campinas', 'Jundiaí'];
  final List<String> _categorias = ['Todos', 'Academia', 'Restaurante', 'Parque', 'Café', 'Outros'];

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.pesquisaInicial);
    _cidadeFiltro = widget.cidadeInicial;
  }

  void _abrirFormulario({Local? local}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => LocalFormModal(
        localParaEditar: local,
        onSalvar: (l) async {
          if (local == null) {
            await _service.adicionar(l);
          } else {
            await _service.atualizar(l);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resultados')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Pesquisar local...',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _cidadeFiltro,
                  items: _cidades.map((c) => DropdownMenuItem(value: c, child: Text('Cidade: $c'))).toList(),
                  onChanged: (v) => setState(() => _cidadeFiltro = v!),
                ),
                const SizedBox(width: 15),
                DropdownButton<String>(
                  value: _categoriaFiltro,
                  items: _categorias.map((c) => DropdownMenuItem(value: c, child: Text('Categoria: $c'))).toList(),
                  onChanged: (v) => setState(() => _categoriaFiltro = v!),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Local>>(
              stream: _service.listarLocais(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nenhum local cadastrado.'));
                }

                final locaisFiltrados = snapshot.data!.where((loc) {
                  final matchesCidade = _cidadeFiltro == 'Todas' || loc.cidade == _cidadeFiltro;
                  final matchesCat = _categoriaFiltro == 'Todos' || loc.categoria == _categoriaFiltro;
                  final matchesText = loc.nome.toLowerCase().contains(_searchCtrl.text.toLowerCase()) ||
                      loc.categoria.toLowerCase().contains(_searchCtrl.text.toLowerCase());
                  return matchesCidade && matchesCat && matchesText;
                }).toList();

                return ListView.builder(
                  itemCount: locaisFiltrados.length,
                  itemBuilder: (context, index) {
                    final item = locaisFiltrados[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        title: Text(item.nome),
                        subtitle: Text('${item.categoria} • ${item.cidade}\n⭐ ${item.avaliacao} | 📍 ${item.distancia}km'),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _abrirFormulario(local: item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await mostrarConfirmacaoExclusao(context);
                                if (confirm == true) {
                                  await _service.excluir(item.id);
                                }
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => DetalhesScreen(local: item)),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}