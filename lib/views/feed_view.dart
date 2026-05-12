import 'package:flutter/material.dart';
import '../services/api_service.dart';

class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  List<Map<String, dynamic>> _posts = [];
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    try {
      final data = await ApiService.getFeedPosts();
      if (!mounted) return;
      setState(() {
        _posts = data;
        _loading = false;
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = 'No se pudo cargar el feed: $error';
      });
    }
  }

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
                _loading ? 'Cargando publicaciones…' : 'Publicaciones verificadas: ${_posts.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF670024),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              )
            else if (_posts.isEmpty)
              const Text('No hay publicaciones en el feed todavía.')
            else
              ..._posts.map((post) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildReportCard(
                    title: (post['title'] as String?) ?? 'Sin título',
                    time: (post['createdAt'] as String?)?.substring(0, 10) ?? 'Reciente',
                    description: (post['description'] as String?) ?? '',
                    image: Icons.location_on,
                    location: (post['locationText'] as String?) ?? 'Sin ubicación',
                    imageUrls: ((post['imageUrls'] as List<dynamic>?) ?? [])
                        .map((e) => e.toString())
                        .toList(),
                  ),
                );
              }),
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
    List<String> imageUrls = const [],
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
          if (imageUrls.isNotEmpty)
            SizedBox(
              height: 84,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: imageUrls.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final rawUrl = imageUrls[index];
                  final fullUrl = rawUrl.startsWith('http')
                      ? rawUrl
                      : '${ApiService.baseUrl}$rawUrl';
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      fullUrl,
                      width: 120,
                      height: 84,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            )
          else
            Container(
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
