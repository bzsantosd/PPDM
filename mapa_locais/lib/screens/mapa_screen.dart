import 'package:flutter/material.dart';
import 'resultados_screen.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  String _cidadeSelecionada = 'São Paulo';
  final TextEditingController _pesquisaController = TextEditingController();

  final List<String> _cidades = ['São Paulo', 'Campinas', 'Jundiaí'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Locais'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _cidadeSelecionada,
                  decoration: const InputDecoration(
                    labelText: 'Selecione a Cidade',
                    border: OutlineInputBorder(),
                  ),
                  items: _cidades
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _cidadeSelecionada = val);
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _pesquisaController,
                  decoration: InputDecoration(
                    hintText: 'Pesquisar estabelecimento ou categoria...',
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ResultadosScreen(
                              cidade: _cidadeSelecionada,
                              pesquisa: _pesquisaController.text,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Text(
                      'Representação de Mapa\n(Cidades e Pontos)',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black45, fontSize: 16),
                    ),
                  ),
                  Positioned(
                    top: 50,
                    left: 80,
                    child: _buildMarker('Academia Fitness', Colors.red),
                  ),
                  Positioned(
                    top: 140,
                    right: 60,
                    child: _buildMarker('Café Central', Colors.orange),
                  ),
                  Positioned(
                    bottom: 120,
                    left: 100,
                    child: _buildMarker('Restaurante Sabor', Colors.green),
                  ),
                  Positioned(
                    bottom: 60,
                    right: 120,
                    child: _buildMarker('Parque da Cidade', Colors.purple),
                  ),
                  Positioned(
                    top: 220,
                    left: 150,
                    child: _buildMarker('Farmácia Vida', Colors.blue),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              icon: const Icon(Icons.list),
              label: Text('Ver Resultados em $_cidadeSelecionada'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ResultadosScreen(
                      cidade: _cidadeSelecionada,
                      pesquisa: _pesquisaController.text,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarker(String nome, Color cor) {
    return Column(
      children: [
        Icon(Icons.location_on, color: cor, size: 36),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: const [BoxShadow(blurRadius: 2, color: Colors.black26)],
          ),
          child: Text(
            nome,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}