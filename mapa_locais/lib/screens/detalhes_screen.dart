import 'package:flutter/material.dart';
import '../models/local.dart';
import '../services/local_service.dart';

class DetalhesScreen extends StatefulWidget {
  final Local local;
  const DetalhesScreen({super.key, required this.local});

  @override
  State<DetalhesScreen> createState() => _DetalhesScreenState();
}

class _DetalhesScreenState extends State<DetalhesScreen> {
  final LocalService _service = LocalService();
  late bool _isFavorito;

  @override
  void initState() {
    super.initState();
    _isFavorito = widget.local.favorito;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.local.nome),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorito ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: () async {
              setState(() {
                _isFavorito = !_isFavorito;
              });
              await _service.alterarFavorito(widget.local.id, _isFavorito);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(_isFavorito ? 'Adicionado aos favoritos' : 'Removido dos favoritos')),
                );
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[300],
              child: const Icon(Icons.store, size: 80, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(widget.local.nome, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('${widget.local.categoria} • ${widget.local.cidade}', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
            const Divider(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(children: [const Icon(Icons.star, color: Colors.amber), Text('${widget.local.avaliacao}')]),
                Column(children: [const Icon(Icons.directions_walk, color: Colors.blue), Text('${widget.local.distancia} km')]),
                Column(children: [const Icon(Icons.access_time, color: Colors.green), Text(widget.local.horario)]),
              ],
            ),
            const Divider(height: 30),
            const Text('Descrição', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(widget.local.descricao, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.map),
                label: const Text('Ver no mapa'),
              ),
            )
          ],
        ),
      ),
    );
  }
}