import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectDetails extends StatelessWidget {
  final String title;
  final String description;
  final String? image;
  final List<String>? projectImages;
  final List<String>? techStacks;
  final String? codes;

  const ProjectDetails({
    super.key,
    required this.title,
    required this.description,
    this.image,
    this.projectImages,
    this.techStacks,
    this.codes,
  });

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(color: Colors.black87),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼️ Main Image
            if (image != null && image!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  image!,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 24),

            // 🧾 Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E2C),
              ),
            ),

            const SizedBox(height: 16),

            // 📝 Description
            Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 30),

            // 🧠 Tech Stack Section
            if (techStacks != null && techStacks!.isNotEmpty) ...[
              const Text(
                "Tech Stack",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E2C),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: techStacks!
                    .map(
                      (tech) => Chip(
                    label: Text(
                      tech,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    backgroundColor: Colors.blueAccent,
                  ),
                )
                    .toList(),
              ),
              const SizedBox(height: 30),
            ],

            // 🖼️ Project Images Gallery
            if (projectImages != null && projectImages!.isNotEmpty) ...[
              const Text(
                "Project Gallery",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E2C),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 160,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: projectImages!.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        projectImages![index],
                        width: 220,
                        height: 160,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
            ],

            // 🔗 Codes or Project Link
            if (codes != null && codes!.isNotEmpty) ...[
              const Text(
                "Project Code",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E2C),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _openLink(codes!),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "🔗 View Code Here",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
