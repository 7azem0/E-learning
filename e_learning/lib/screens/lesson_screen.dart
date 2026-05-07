// ignore_for_file: library_prefixes, deprecated_member_use

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:path_provider/path_provider.dart';

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
    if (_tabs.length == 1) return _buildMobileView(_tabs[0].text!);
    return TabBarView(
      controller: _tabController,
      children: _tabs.map((t) => _buildMobileView(t.text!)).toList(),
    );
  }

  Widget _buildMobileView(String type) {
    if (type == 'Video' && widget.videoUrl != null) {
      return _VideoPlayerWidget(url: widget.videoUrl!);
    } else if (type == 'PDF' && widget.pdfUrl != null) {
      return _PdfViewerWidget(url: widget.pdfUrl!);
    }
    return const SizedBox();
  }
}

// ─── PDF VIEWER ──────────────────────────────────────────────────────────────

class _PdfViewerWidget extends StatefulWidget {
  final String url;
  const _PdfViewerWidget({required this.url});

  @override
  State<_PdfViewerWidget> createState() => _PdfViewerWidgetState();
}

class _PdfViewerWidgetState extends State<_PdfViewerWidget> {
  bool _isLoading = true;
  String? _localPath;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.url));
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/lesson.pdf');
        await file.writeAsBytes(response.bodyBytes);
        setState(() {
          _localPath = file.path;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load PDF';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    return PDFView(
      filePath: _localPath!,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: true,
      pageFling: true,
    );
  }
}

// ─── VIDEO PLAYER ────────────────────────────────────────────────────────────

class _VideoPlayerWidget extends StatefulWidget {
  final String url;
  const _VideoPlayerWidget({required this.url});

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.url),
      );
      await _videoController.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
      );
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = 'Error loading video: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    return Chewie(controller: _chewieController!);
  }
}