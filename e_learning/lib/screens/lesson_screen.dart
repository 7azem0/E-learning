// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui;

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
    _tabController =
        TabController(length: _tabs.length, vsync: this);

    // Register iframes for web
    if (kIsWeb) {
      if (widget.videoUrl != null) {
        ui.platformViewRegistry.registerViewFactory(
          'video-${widget.videoUrl}',
          (int viewId) => html.VideoElement()
            ..src = widget.videoUrl!
            ..controls = true
            ..style.width = '100%'
            ..style.height = '100%',
        );
      }
      if (widget.pdfUrl != null) {
        ui.platformViewRegistry.registerViewFactory(
          'pdf-${widget.pdfUrl}',
          (int viewId) => html.IFrameElement()
            ..src = widget.pdfUrl!
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.border = 'none',
        );
      }
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
          // Description
          if (widget.description.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: widget.courseColor.withOpacity(0.05),
              child: Text(widget.description,
                  style: TextStyle(color: Colors.grey.shade700)),
            ),

          // Content
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
                            style:
                                TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  )
                : _tabs.length == 1
                    ? _buildContent(_tabs[0].text!)
                    : TabBarView(
                        controller: _tabController,
                        children: _tabs
                            .map((t) => _buildContent(t.text!))
                            .toList(),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(String type) {
    if (type == 'Video' && widget.videoUrl != null) {
      return HtmlElementView(viewType: 'video-${widget.videoUrl}');
    } else if (type == 'PDF' && widget.pdfUrl != null) {
      return HtmlElementView(viewType: 'pdf-${widget.pdfUrl}');
    }
    return const SizedBox();
  }
}