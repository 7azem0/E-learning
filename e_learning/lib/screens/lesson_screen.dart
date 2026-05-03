// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// Conditional import for web views
import 'lesson_screen_stub.dart'
    if (dart.library.html) 'lesson_screen_web.dart' as webHelper;

class LessonScreen extends StatefulWidget {
  final String title;
  final String description;
  final String? pdfUrl;
  final String? videoUrl;
  final Color courseColor;

  const LessonScreen({
    super.key,
    required this.title,
    required this.description,
    this.pdfUrl,
    this.videoUrl,
    required this.courseColor,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Tab> _tabs = [];

  @override
  void initState() {
    super.initState();
    if (widget.videoUrl != null) _tabs.add(const Tab(text: 'Video'));
    if (widget.pdfUrl != null) _tabs.add(const Tab(text: 'PDF'));
    _tabController = TabController(length: _tabs.length, vsync: this);

    if (kIsWeb) {
      webHelper.registerViews(
        videoUrl: widget.videoUrl,
        pdfUrl: widget.pdfUrl,
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.courseColor,
        foregroundColor: Colors.white,
        title: Text(widget.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        bottom: _tabs.length > 1
            ? TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: _tabs,
              )
            : null,
      ),
      body: Column(
        children: [
          if (widget.description.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: widget.courseColor.withOpacity(0.05),
              child: Text(widget.description,
                  style: TextStyle(color: Colors.grey.shade700)),
            ),
          Expanded(
            child: _tabs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.hourglass_empty,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text('No content uploaded yet',
                            style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  )
                : kIsWeb
                    ? _buildWebContent()
                    : _buildMobileContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildWebContent() {
    if (_tabs.length == 1) return _buildWebView(_tabs[0].text!);
    return TabBarView(
      controller: _tabController,
      children: _tabs.map((t) => _buildWebView(t.text!)).toList(),
    );
  }

  Widget _buildWebView(String type) {
    if (type == 'Video' && widget.videoUrl != null) {
      return HtmlElementView(viewType: 'video-${widget.videoUrl}');
    } else if (type == 'PDF' && widget.pdfUrl != null) {
      return HtmlElementView(viewType: 'pdf-${widget.pdfUrl}');
    }
    return const SizedBox();
  }

  Widget _buildMobileContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (widget.videoUrl != null)
          _ContentTile(
            icon: Icons.video_library_outlined,
            label: 'Watch Video',
            url: widget.videoUrl!,
            color: widget.courseColor,
          ),
        if (widget.pdfUrl != null)
          _ContentTile(
            icon: Icons.picture_as_pdf,
            label: 'View PDF',
            url: widget.pdfUrl!,
            color: widget.courseColor,
          ),
      ],
    );
  }
}

class _ContentTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;
  final Color color;

  const _ContentTile({
    required this.icon,
    required this.label,
    required this.url,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Icon(Icons.open_in_new, color: color),
        onTap: () async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
      ),
    );
  }
}