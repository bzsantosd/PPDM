import 'package:flutter/material.dart';
import 'resultados_screen.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  String _cidadeSelecionada = 'São Paulo';
  final TextEditingController _searchCtrl = TextEditingController();

  final List<String> _cidades = ['São Paulo', 'Campinas', 'Jundiaí'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explorar Mapa')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.location_city),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _cidadeSelecionada,
                    items: _cidades.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => _cidadeSelecionada = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: 'O que você procura?',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.lightBlue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueAccent),
                ),
                child: Stack(
                  children: const [
                    Center(child: Text('Representação visual do Mapa', style: TextStyle(color: Colors.grey))),
                    Positioned(top: 50, left: 60, child: Icon(Icons.location_on, color: Colors.red, size: 40)),
                    Positioned(top: 120, right: 80, child: Icon(Icons.location_on, color: Colors.red, size: 40)),
                    Positioned(bottom: 100, left: 120, child: Icon(Icons.location_on, color: Colors.red, size: 40)),
                    Positioned(bottom: 40, right: 50, child: Icon(Icons.location_on, color: Colors.red, size: 40)),
                    Positioned(top: 200, left: 200, child: Icon(Icons.location_on, color: Colors.red, size: 40)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ResultadosScreen(
                        cidadeInicial: _cidadeSelecionada,
                        pesquisaInicial: _searchCtrl.text,
                      ),
                    ),
                  );
                },
                child: const Text('Buscar Resultados'),
              ),
            )
          ],
        ),
      ),
    );
  }
}