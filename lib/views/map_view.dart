import 'package:flutter/material.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCFAF2),
        elevation: 0,
        leading: Icon(Icons.menu, color: Colors.grey[800]),
        title: const Text(
          'Oaxaca Reporta',
          style: TextStyle(color: Color(0xFF670024), fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.grey),
            ),
          ),
        ],
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Placeholder para el mapa
          Container(
            color: Colors.grey[300],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map,
                    size: 80,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Mapa Interactivo',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Consulta todos los reportes activos\ny finalizados en la zona',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          // Leyenda flotante
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Densidad de Baches',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildLegendItem(Colors.red, 'Crítico (Alta)'),
                  _buildLegendItem(Colors.pink, 'Moderado'),
                  _buildLegendItem(Colors.grey, 'Baja (Seguro)'),
                ],
              ),
            ),
          ),
          // Botones flotantes
          Positioned(
            right: 16,
            bottom: 100,
            child: Column(
              children: [
                FloatingActionButton(
                  mini: true,
                  onPressed: () {},
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.add, color: Color(0xFF670024)),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  mini: true,
                  onPressed: () {},
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.remove, color: Color(0xFF670024)),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  mini: true,
                  onPressed: () {},
                  backgroundColor: const Color(0xFF670024),
                  child: const Icon(Icons.my_location, color: Colors.white),
                ),
              ],
            ),
          ),
          // Alerta crítica
          Positioned(
            bottom: 100,
            left: 16,
            right: 56,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'SECTOR REFORMA - Alerta Crítica ⚠️',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF670024),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Av. Independencia & Morelos',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '14 baches reportados en los últimos 7 días',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pendiente',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            const Text(
                              '124',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reportes',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            const Text(
                              '14',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
