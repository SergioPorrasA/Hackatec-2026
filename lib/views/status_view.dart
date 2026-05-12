import 'package:flutter/material.dart';

class StatusView extends StatefulWidget {
  const StatusView({super.key});

  @override
  State<StatusView> createState() => _StatusViewState();
}

class _StatusViewState extends State<StatusView> {
  int _selectedFilter = 0;
  final List<String> _filters = ['Todos', 'Enviados', 'En Revisión', 'Finalizados'];

  final List<Map<String, String>> _reports = [
    {
      'id': '#OAX-2024-0891',
      'title': 'Fuga de agua',
      'location': 'Calle Macedonio Alcalá',
      'date': '24 May 2024',
      'status': 'Enviado',
    },
    {
      'id': '#OAX-2024-0854',
      'title': 'Bache',
      'location': 'Colonia Reforma',
      'date': '21 May 2024',
      'status': 'En Revisión',
    },
    {
      'id': '#OAX-2024-0722',
      'title': 'Luminaria fundida',
      'location': 'Parque El Llano',
      'date': '15 May 2024',
      'status': 'Finalizado',
    },
    {
      'id': '#OAX-2024-0912',
      'title': 'Recolección Basura',
      'location': 'Centro Histórico',
      'date': '26 May 2024',
      'status': 'En Revisión',
    },
    {
      'id': '#OAX-2024-0935',
      'title': 'Poda de árboles',
      'location': 'Avenida Juárez',
      'date': '28 May 2024',
      'status': 'Enviado',
    },
  ];

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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estado de reportes',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF670024),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Consulta si tu reporte fue enviado, está en revisión o ya quedó finalizado.',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Las tarjetas muestran cada incidencia para que no se pierda el seguimiento.',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(_filters[index]),
                        selected: _selectedFilter == index,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = index;
                          });
                        },
                        backgroundColor: Colors.transparent,
                        selectedColor: const Color(0xFF670024),
                        labelStyle: TextStyle(
                          color: _selectedFilter == index ? Colors.white : Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                        side: BorderSide(
                          color: _selectedFilter == index
                              ? const Color(0xFF670024)
                              : Colors.grey[300]!,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              ..._reports.map((report) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildReportCard(report),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(Map<String, String> report) {
    Color statusColor = _getStatusColor(report['status']!);
    IconData statusIcon = _getStatusIcon(report['status']!);

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                report['id']!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF670024),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(51),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  report['status']!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report['title']!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      report['location']!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Estado actual del sistema de atención municipal',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    report['date']!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'Detalles →',
                  style: TextStyle(
                    color: Color(0xFF670024),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Enviado':
        return Colors.blue;
      case 'En Revisión':
        return Colors.orange;
      case 'Finalizado':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Enviado':
        return Icons.check_circle_outline;
      case 'En Revisión':
        return Icons.hourglass_top;
      case 'Finalizado':
        return Icons.verified;
      default:
        return Icons.help_outline;
    }
  }
}
