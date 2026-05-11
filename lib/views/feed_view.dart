import 'package:flutter/material.dart';

class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,children: [
            Text(
              'ACTUALIZACIONES CIVILES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Mural de Transformación',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF670024),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Visualiza el progreso de nuestra ciudad. Cada reporte finalizado representa una calle más segura para las familias oaxaqueñas.',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Total: 1,248 reparaciones',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF670024),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildReportCard(
              title: 'San Felipe del Agua - Av. Principal',
              time: 'Hace 2 horas',
              description: 'Se concluyó la rehabilitación integral del tramo afectado por filtraciones.',
              image: Icons.check_circle,
            ),
            const SizedBox(height: 16),
            _buildReportCard(
              title: 'Colonia Reforma',
              time: 'Hace 1 día',
              description: 'Intervención rápida en Calle Heróica Escuela Naval Militar.',
              image: Icons.construction,
            ),
            const SizedBox(height: 16),
            _buildReportCard(
              title: 'Centro Histórico',
              time: 'Hace 2 días',
              description: 'Calle Macedonio Alcalá - Nivelación de grietas.',
              image: Icons.done_all,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard({
    required String title,
    required String time,
    required String description,
    required IconData image,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(image, color: const Color(0xFF670024)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(time, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(description, style: TextStyle(color: Colors.grey[700])),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {},
            child: const Text(
              'Ver detalles →',
              style: TextStyle(
                color: Color(0xFF670024),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
