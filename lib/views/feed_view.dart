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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NOTICIAS DE REPARACIÓN',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Baches atendidos y publicados por la comunidad',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF670024),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cada publicación muestra ubicación, fotografías y una breve descripción del bache reparado para dar seguimiento a lo que ya fue atendido.',
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
                'Publicaciones verificadas: 1,248',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF670024),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildReportCard(
              title: 'Bache reparado en San Felipe del Agua',
              time: 'Hace 2 horas',
              description: 'Reparación concluida sobre Av. Principal, con nivelación completa y sellado final.',
              image: Icons.location_on,
              location: 'San Felipe del Agua · Av. Principal',
            ),
            const SizedBox(height: 16),
            _buildReportCard(
              title: 'Intervención finalizada en Colonia Reforma',
              time: 'Hace 1 día',
              description: 'Se rehabilitó el tramo reportado y se documentó con fotografías del antes y después.',
              image: Icons.location_on,
              location: 'Colonia Reforma · Calle Heroica Escuela Naval Militar',
            ),
            const SizedBox(height: 16),
            _buildReportCard(
              title: 'Centro Histórico sin bache activo',
              time: 'Hace 2 días',
              description: 'La calle fue reparada y quedó marcada como atendida en el sistema de seguimiento.',
              image: Icons.location_on,
              location: 'Centro Histórico · Calle Macedonio Alcalá',
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
    required String location,
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
          Text(
            location,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF670024),
            ),
          ),
          const SizedBox(height: 8),
          Text(description, style: TextStyle(color: Colors.grey[700])),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 74,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F1EC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: const Center(
                    child: Icon(Icons.photo, color: Color(0xFF670024)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 74,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F1EC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: const Center(
                    child: Icon(Icons.photo_library, color: Color(0xFF670024)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 74,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F1EC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: const Center(
                    child: Icon(Icons.image, color: Color(0xFF670024)),
                  ),
                ),
              ),
            ],
          ),
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
