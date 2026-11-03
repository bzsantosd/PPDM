import 'package:flutter/material.dart';
import '../models/local.dart';
import '../services/local_service.dart';
import '../widgets/local_form_bottom_sheet.dart';
import 'detalhes_screen.dart';

class ResultadosScreen extends StatefulWidget {
  final String cidade;
  final String pesquisa;

  const ResultadosScreen({
    super.key,
    required this.cidade,
    required this.pesquisa,
  });

  @override
  State<ResultadosScreen> createState() => _ResultadosScreenState();
}

class _ResultadosScreenState extends State<ResultadosScreen> {
  late String _cidadeFiltro;
  late String _categoriaFiltro;
  late TextEditingController _pesquisaController;
  bool _somenteFavoritos = false;

  final List<String> _cidades = ['Todas', 'São Paulo', 'Campinas', 'Jundiaí'];
  final List<String> _categorias = ['Todos', 'Academia', 'Restaurante', 'Café', 'Parque', 'Farmácia', 'Outros'];

  @override
  void initState() {
    super.initState();
    _cidadeFiltro = widget.cidade;
    _categoriaFiltro = 'Todos';
    _pesquisaController = TextEditingController(text: widget.pesquisa);
  }

  List<Local> _filtrarLocais(List<Local> locais) {
    return locais.where((local) {
      final correspondeCidade = _cidadeFiltro == 'Todas' || local.cidade == _cidadeFiltro;
      final correspondeCategoria = _categoriaFiltro == 'Todos' || local.categoria == _categoriaFiltro;
      final termo = _pesquisaController.text.toLowerCase();
      final correspondeTexto = local.nome.toLowerCase().contains(termo) ||
          local.categoria.toLowerCase().contains(termo);
      final correspondeFavorito = !_somenteFavoritos || local.favorito;

      return correspondeCidade && correspondeCategoria && correspondeTexto && correspondeFavorito;
    }).toList();
  }

  void _abrirFormulario([Local? local]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => LocalFormBottomSheet(
        local: local,
        cidadePadrao: _cidadeFiltro != 'Todas' ? _cidadeFiltro : 'São Paulo',
      ),
    );
  }

  Future<void> _confirmarExclusao(Local local) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir local?'),
          content: Text('Deseja excluir "${local.nome}"? Essa ação não pode ser desfeita.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmou == true) {
      try {
        await LocalService().excluir(local.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Local excluído com sucesso!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados'),
        actions: [
          IconButton(
            icon: Icon(_somenteFavoritos ? Icons.favorite : Icons.favorite_border),
            color: _somenteFavoritos ? Colors.red : null,
            onPressed: () => setState(() => _somenteFavoritos = !_somenteFavoritos),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _pesquisaController,
              decoration: const InputDecoration(
                labelText: 'Pesquisar',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _cidadeFiltro,
                    decoration: const InputDecoration(labelText: 'Cidade'),
                    items: _cidades.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) => setState(() => _cidadeFiltro = val!),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _categoriaFiltro,
                    decoration: const InputDecoration(labelText: 'Categoria'),
                    items: _categorias.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                    onChanged: (val) => setState(() => _categoriaFiltro = val!),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<List<Local>>(
              stream: LocalService().listarLocais(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Erro ao carregar locais do Firestore.'));
                }

                final todosLocais = snapshot.data ?? [];
                final locaisFiltrados = _filtrarLocais(todosLocais);

                if (locaisFiltrados.isEmpty) {
                  return const Center(child: Text('Nenhum local encontrado.'));
                }

                return ListView.builder(
                  itemCount: locaisFiltrados.length,
                  itemBuilder: (context, index) {
                    final local = locaisFiltrados[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        title: Text(local.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${local.categoria} • ${local.cidade}\n${local.distancia} km • Avaliação: ${local.avaliacao}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                local.favorito ? Icons.favorite : Icons.favorite_border,
                                color: local.favorito ? Colors.red : null,
                              ),
                              onPressed: () => LocalService().alterarFavorito(local.id, !local.favorito),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _abrirFormulario(local),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmarExclusao(local),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetalhesScreen(local: local),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}