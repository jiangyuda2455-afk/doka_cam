import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/composition_result.dart';

class ArOverlayPainter extends CustomPainter {
  final CompositionResult? result;
  final bool showGuides;
  final double animationAlpha;

  ArOverlayPainter({
    this.result,
    this.showGuides = true,
    this.animationAlpha = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!showGuides || result == null) return;
    final r = result!;
    final alpha = animationAlpha;

    _drawSceneLabel(canvas, size, r);
    for (final guide in r.guideLines) {
      _drawGuideLine(canvas, size, guide, r, alpha);
    }
    if (r.idealSubjectPosition != null) _drawTargetMarker(canvas, size, r, alpha);
    if (r.subjectRect != null) _drawSubjectBox(canvas, size, r, alpha);
    _drawAlignmentBar(canvas, size, r, alpha);
    if (r.movementHint != null && !r.isAligned) _drawMovementHint(canvas, size, r, alpha);
    if (r.tipText != null && !r.isAligned) _drawTipText(canvas, size, r, alpha);
    _drawSchemeLabel(canvas, size, r, alpha);
  }

  void _drawSceneLabel(Canvas canvas, Size size, CompositionResult r) {
    _drawLabelBg(canvas, 16, 44, r.sceneLabel, 13);
  }

  void _drawSchemeLabel(Canvas canvas, Size size, CompositionResult r, double alpha) {
    _drawLabelBg(canvas, 16, 78, r.ruleLabel, 11);
  }

  void _drawLabelBg(Canvas canvas, double x, double y, String text, double fontSize) {
    final tp = TextPainter(text: TextSpan(text: text, style: const TextStyle(color: Colors.white, fontSize: 13)),
        textDirection: TextDirection.ltr)..layout();
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x, y, tp.width + 16, 28), const Radius.circular(14)),
      Paint()..color = Colors.black.withValues(alpha: 0.5),
    );
    tp.paint(canvas, Offset(x + 8, y + 6));
  }

  void _drawGuideLine(Canvas canvas, Size size, GuideLine guide, CompositionResult r, double alpha) {
    final color = (r.isAligned ? Colors.green : Colors.white).withValues(alpha: 0.4 * alpha);
    final paint = Paint()..color = color..strokeWidth = 1.0;
    final start = Offset(guide.start.dx * size.width, guide.start.dy * size.height);
    final end = Offset(guide.end.dx * size.width, guide.end.dy * size.height);
    canvas.drawLine(start, end, paint);
    if (guide.type == GuidLineType.arrow) _drawArrowhead(canvas, start, end, paint);
  }

  void _drawArrowhead(Canvas canvas, Offset from, Offset to, Paint paint) {
    final angle = math.atan2(to.dy - from.dy, to.dx - from.dx);
    final path = Path()
      ..moveTo(to.dx, to.dy)
      ..lineTo(to.dx - 10 * math.cos(angle - 0.5), to.dy - 10 * math.sin(angle - 0.5))
      ..lineTo(to.dx - 10 * math.cos(angle + 0.5), to.dy - 10 * math.sin(angle + 0.5))
      ..close();
    canvas.drawPath(path, Paint()..color = paint.color..style = PaintingStyle.fill);
  }

  void _drawTargetMarker(Canvas canvas, Size size, CompositionResult r, double alpha) {
    final cx = r.idealSubjectPosition!.dx * size.width;
    final cy = r.idealSubjectPosition!.dy * size.height;
    final color = Colors.yellow.withValues(alpha: 0.7 * alpha);
    final paint = Paint()..color = color..strokeWidth = 1.5;
    canvas.drawCircle(Offset(cx, cy), 16, Paint()..style = PaintingStyle.stroke..color = color);
    canvas.drawLine(Offset(cx - 20, cy), Offset(cx + 20, cy), paint);
    canvas.drawLine(Offset(cx, cy - 20), Offset(cx, cy + 20), paint);
  }

  void _drawSubjectBox(Canvas canvas, Size size, CompositionResult r, double alpha) {
    final rect = r.subjectRect!;
    final color = (r.isAligned ? Colors.green : Colors.orange).withValues(alpha: 0.6 * alpha);
    canvas.drawRect(
      Rect.fromLTWH(rect.left * size.width, rect.top * size.height, rect.width * size.width, rect.height * size.height),
      Paint()..color = color..strokeWidth = 2.0..style = PaintingStyle.stroke,
    );
  }

  void _drawAlignmentBar(Canvas canvas, Size size, CompositionResult r, double alpha) {
    final bw = size.width * 0.6;
    final x = (size.width - bw) / 2;
    final y = size.height - 100;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, bw, 4), const Radius.circular(2)),
        Paint()..color = Colors.white.withValues(alpha: 0.2 * alpha));
    if (r.alignmentProgress > 0) {
      final pc = r.isAligned ? Colors.green : (r.alignmentProgress > 0.5 ? Colors.orange : Colors.yellow);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, bw * r.alignmentProgress, 4), const Radius.circular(2)),
          Paint()..color = pc.withValues(alpha: 0.8 * alpha));
    }
    final tp = TextPainter(text: TextSpan(text: '%',
        style: const TextStyle(color: Colors.white70, fontSize: 11)), textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, Offset(x + bw + 8, y - 2));
  }

  void _drawMovementHint(Canvas canvas, Size size, CompositionResult r, double alpha) {
    final tp = TextPainter(text: TextSpan(text: r.movementHint ?? '',
        style: TextStyle(color: Colors.yellow.withValues(alpha: 0.9 * alpha), fontSize: 14, fontWeight: FontWeight.w500)),
        textDirection: TextDirection.ltr)..layout();
    final x = (size.width - tp.width) / 2;
    final y = size.height - 70;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x - 8, y - 4, tp.width + 16, tp.height + 8), const Radius.circular(12)),
        Paint()..color = Colors.black.withValues(alpha: 0.5 * alpha));
    tp.paint(canvas, Offset(x, y));
  }

  void _drawTipText(Canvas canvas, Size size, CompositionResult r, double alpha) {
    final tp = TextPainter(text: TextSpan(text: r.tipText ?? '',
        style: TextStyle(color: Colors.white.withValues(alpha: 0.7 * alpha), fontSize: 12)),
        textDirection: TextDirection.ltr)..layout();
    final x = (size.width - tp.width) / 2;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x - 6, 120, tp.width + 12, 24), const Radius.circular(12)),
        Paint()..color = Colors.black.withValues(alpha: 0.4 * alpha));
    tp.paint(canvas, Offset(x, 124));
  }

  @override
  bool shouldRepaint(covariant ArOverlayPainter oldDelegate) => true;
}

