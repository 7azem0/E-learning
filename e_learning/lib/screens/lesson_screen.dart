// ignore_for_file: library_prefixes, deprecated_member_use

import 'dart:io';
import 'package:flutter/foundation.dart';
import '../services/authentication_service.dart';
import '../services/discussion_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:path_provider/path_provider.dart';

import 'lesson_screen_stub.dart'
    if (dart.library.html) 'lesson_screen_web.dart' as webHelper;

class LessonScreen extends StatefulWidget {
  final String courseId;
  final String sectionId;
  final String lessonId;
  final String title;
  final String description;
  final String? pdfUrl;
  final String? videoUrl;
  final Color courseColor;

  const LessonScreen({
    super.key,
    required this.courseId,
    required this.sectionId,
    required this.lessonId,
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
    _tabs.add(const Tab(text: 'Discussion'));
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
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
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
              child: Text(
                widget.description,
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
          Expanded(
            child: _tabs.length == 1
                ? _buildContent(_tabs[0].text!)
                : TabBarView(
                    controller: _tabController,
                    children: _tabs.map((t) => _buildContent(t.text!)).toList(),
                  ),
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
    } else if (type == 'Discussion') {
      return _LessonDiscussion(
        courseId: widget.courseId,
        sectionId: widget.sectionId,
        lessonId: widget.lessonId,
        courseColor: widget.courseColor,
      );
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hourglass_empty, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No content uploaded yet',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _LessonDiscussion extends StatefulWidget {
  final String courseId;
  final String sectionId;
  final String lessonId;
  final Color courseColor;

  const _LessonDiscussion({
    required this.courseId,
    required this.sectionId,
    required this.lessonId,
    required this.courseColor,
  });

  @override
  State<_LessonDiscussion> createState() => _LessonDiscussionState();
}

class _LessonDiscussionState extends State<_LessonDiscussion> {
  final TextEditingController _commentController = TextEditingController();
  bool _posting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService().currentUser;

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<LessonComment>>(
            stream: DiscussionService().getComments(
              courseId: widget.courseId,
              sectionId: widget.sectionId,
              lessonId: widget.lessonId,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final comments = snapshot.data ?? [];
              if (comments.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.forum_outlined,
                          size: 56,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No questions yet',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Start the lesson discussion with a comment or question.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: comments.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  final canDelete =
                      currentUser != null &&
                      (currentUser.uid == comment.userId ||
                          currentUser.isAdmin);
                  return _CommentTile(
                    comment: comment,
                    courseColor: widget.courseColor,
                    canDelete: canDelete,
                    onDelete: () => _deleteComment(comment.id),
                  );
                },
              );
            },
          ),
        ),
        _Composer(
          controller: _commentController,
          courseColor: widget.courseColor,
          posting: _posting,
          onSend: _postComment,
        ),
      ],
    );
  }

  Future<void> _postComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _posting) return;

    setState(() => _posting = true);
    final result = await DiscussionService().addComment(
      courseId: widget.courseId,
      sectionId: widget.sectionId,
      lessonId: widget.lessonId,
      text: text,
    );
    if (mounted) setState(() => _posting = false);

    if (result == 'Success') {
      _commentController.clear();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result), backgroundColor: Colors.red.shade400),
      );
    }
  }

  Future<void> _deleteComment(String commentId) async {
    final result = await DiscussionService().deleteComment(
      courseId: widget.courseId,
      sectionId: widget.sectionId,
      lessonId: widget.lessonId,
      commentId: commentId,
    );

    if (result != 'Success' && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result), backgroundColor: Colors.red.shade400),
      );
    }
  }
}

class _CommentTile extends StatelessWidget {
  final LessonComment comment;
  final Color courseColor;
  final bool canDelete;
  final VoidCallback onDelete;

  const _CommentTile({
    required this.comment,
    required this.courseColor,
    required this.canDelete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = comment.isAdmin ? courseColor : Colors.blueGrey;
    final initials = comment.userName.trim().isEmpty
        ? '?'
        : comment.userName.trim()[0].toUpperCase();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: badgeColor.withOpacity(0.12),
            child: Text(initials, style: TextStyle(color: badgeColor)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      comment.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    _RoleBadge(
                      label: comment.isAdmin ? 'Instructor' : 'Student',
                      color: badgeColor,
                      icon: comment.isAdmin
                          ? Icons.workspace_premium
                          : Icons.school_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(comment.text, style: const TextStyle(height: 1.35)),
              ],
            ),
          ),
          if (canDelete)
            IconButton(
              tooltip: 'Delete comment',
              icon: Icon(Icons.delete_outline, color: Colors.red.shade300),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _RoleBadge({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final Color courseColor;
  final bool posting;
  final VoidCallback onSend;

  const _Composer({
    required this.controller,
    required this.courseColor,
    required this.posting,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText: 'Ask a question or add a comment',
                  prefixIcon: Icon(Icons.chat_bubble_outline),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filled(
              tooltip: 'Post comment',
              style: IconButton.styleFrom(
                backgroundColor: courseColor,
                foregroundColor: Colors.white,
              ),
              onPressed: posting ? null : onSend,
              icon: posting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
