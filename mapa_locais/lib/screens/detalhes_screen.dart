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
  late bool _favorito;

  @override
  void initState() {
    super.initState();
    _favorito = widget.local.favorito;
  }

  Future<void> _toggleFavorito() async {
    setState(() {
      _favorito = !_favorito;
    });
    await LocalService().alterarFavorito(widget.local.id, _favorito);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.local.nome),
        actions: [
          IconButton(
            icon: Icon(_favorito ? Icons.favorite : Icons.favorite_border),
            color: _favorito ? Colors.red : null,
            onPressed: _toggleFavorito,
          ),
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
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.store, size: 80, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              widget.local.nome,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Chip(label: Text(widget.local.categoria)),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.location_city),
              title: const Text('Cidade'),
              subtitle: Text(widget.local.cidade),
            ),
            ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: const Text('Avaliação'),
              subtitle: Text('${widget.local.avaliacao} / 5.0'),
            ),
            ListTile(
              leading: const Icon(Icons.navigation),
              title: const Text('Distância'),
              subtitle: Text('${widget.local.distancia} km de você'),
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Horário de funcionamento'),
              subtitle: Text(widget.local.horario),
            ),
            const SizedBox(height: 8),
            const Text(
              'Descrição',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              widget.local.descricao.isEmpty ? 'Sem descrição cadastrada.' : widget.local.descricao,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(45),
              ),
              icon: const Icon(Icons.map),
              label: const Text('Ver no mapa'),
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }
}