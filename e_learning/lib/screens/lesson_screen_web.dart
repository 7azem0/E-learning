import 'dart:html' as html;
import 'dart:ui_web' as ui;

void registerViews({String? videoUrl, String? pdfUrl}) {
  if (videoUrl != null) {
    ui.platformViewRegistry.registerViewFactory(
      'video-$videoUrl',
      (int viewId) => html.VideoElement()
        ..src = videoUrl
        ..controls = true
        ..style.width = '100%'
        ..style.height = '100%',
    );
  }
  if (pdfUrl != null) {
    ui.platformViewRegistry.registerViewFactory(
      'pdf-$pdfUrl',
      (int viewId) => html.IFrameElement()
        ..src = pdfUrl
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.border = 'none',
    );
  }
}