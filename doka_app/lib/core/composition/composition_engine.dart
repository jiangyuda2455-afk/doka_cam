import 'dart:math' as math;
import 'dart:ui' show Rect, Offset;
import '../../models/composition_result.dart';

class CompositionEngine {
  double _imageWidth = 1.0;
  double _imageHeight = 1.0;

  void setImageDimensions(double width, double height) {
    _imageWidth = width;
    _imageHeight = height;
  }

  CompositionResult analyze({
    required SceneType sceneType,
    Rect? subjectRect,
    List<Offset> lines = const [],
    CompositionRule? preferredRule,
  }) {
    final rules = _recommendRules(sceneType, subjectRect, lines);
    final activeRule = preferredRule ?? rules.first;
    final idealPosition = _idealSubjectPosition(activeRule, sceneType);
    final alignResult = _calculateAlignment(subjectRect, idealPosition);
    final zoom = _recommendZoom(sceneType, subjectRect);
    final guides = _generateGuides(activeRule, sceneType, subjectRect, idealPosition, alignResult.score);
    final tip = _getTipText(sceneType, activeRule, alignResult.score);

    return CompositionResult(
      sceneType: sceneType,
      recommendedRules: rules,
      activeRule: activeRule,
      subjectRect: subjectRect,
      idealSubjectPosition: idealPosition,
      movementDirection: alignResult.direction,
      movementHint: alignResult.hint,
      recommendedZoom: zoom,
      alignmentScore: alignResult.score,
      alignmentProgress: alignResult.progress,
      guideLines: guides,
      tipText: tip,
    );
  }

  List<CompositionRule> _recommendRules(SceneType sceneType, Rect? subject, List<Offset> lines) {
    switch (sceneType) {
      case SceneType.portrait:
        return [CompositionRule.ruleOfThirds, CompositionRule.center];
      case SceneType.landscape:
        return [CompositionRule.ruleOfThirds, CompositionRule.leadingLines, CompositionRule.goldenRatio];
      case SceneType.architecture:
        return [CompositionRule.symmetric, CompositionRule.frameGuide, CompositionRule.ruleOfThirds];
      case SceneType.food:
        return [CompositionRule.center, CompositionRule.ruleOfThirds];
      case SceneType.street:
        return [CompositionRule.leadingLines, CompositionRule.ruleOfThirds, CompositionRule.diagonal];
      case SceneType.night:
        return [CompositionRule.ruleOfThirds, CompositionRule.center];
      case SceneType.indoor:
        return [CompositionRule.ruleOfThirds, CompositionRule.frameGuide];
      case SceneType.unknown:
        return [CompositionRule.ruleOfThirds, CompositionRule.center];
    }
  }

  Offset? _idealSubjectPosition(CompositionRule rule, SceneType sceneType) {
    final cx = _imageWidth / 2;
    final cy = _imageHeight / 2;
    switch (rule) {
      case CompositionRule.ruleOfThirds:
        return Offset(_imageWidth / 3, _imageHeight / 3);
      case CompositionRule.center:
        return Offset(cx, cy);
      case CompositionRule.symmetric:
        return Offset(cx, cy);
      case CompositionRule.frameGuide:
        return Offset(cx, cy * 0.9);
      case CompositionRule.leadingLines:
        return Offset(cx, _imageHeight / 3);
      case CompositionRule.goldenRatio:
        return Offset(_imageWidth * 0.382, _imageHeight * 0.382);
      case CompositionRule.diagonal:
        return Offset(cx, cy);
    }
  }

  _AlignmentResult _calculateAlignment(Rect? subjectRect, Offset? idealPos) {
    if (subjectRect == null || idealPos == null) {
      return _AlignmentResult(0.0, 0.0, null, null);
    }
    final subjCenter = subjectRect.center;
    final dx = (subjCenter.dx - idealPos.dx).abs() / _imageWidth;
    final dy = (subjCenter.dy - idealPos.dy).abs() / _imageHeight;
    final dist = math.sqrt(dx * dx + dy * dy);
    final score = (1.0 - dist * 2).clamp(0.0, 1.0);
    final progress = (score / 0.85).clamp(0.0, 1.0);

    Offset? movementDir;
    String? hint;
    if (score < 0.85) {
      final moveX = (idealPos.dx - subjCenter.dx);
      final moveY = (idealPos.dy - subjCenter.dy);
      final len = math.sqrt(moveX * moveX + moveY * moveY);
      if (len > 1.0) {
        movementDir = Offset(moveX / len, moveY / len);
        hint = _movementHint(moveX / _imageWidth, moveY / _imageHeight);
      }
    }
    return _AlignmentResult(score, progress, movementDir, hint);
  }

  String _movementHint(double dx, double dy) {
    final h = dx.abs() > 0.05 ? (dx > 0 ? '向右' : '向左') : '';
    final v = dy.abs() > 0.05 ? (dy > 0 ? '向下' : '向上') : '';
    final strength = math.max(dx.abs(), dy.abs());
    final prefix = strength > 0.15 ? '大幅' : '轻微';
    return '$prefix$v$h 移动手机';
  }

  double? _recommendZoom(SceneType sceneType, Rect? subjectRect) {
    if (subjectRect == null) return null;
    final area = (subjectRect.width / _imageWidth) * (subjectRect.height / _imageHeight);
    if (area < 0.05) return 3.0;
    if (area < 0.1) return 2.0;
    if (area < 0.15) return 1.5;
    if (area < 0.25) return 1.0;
    if (area > 0.6) return 0.5;
    return null;
  }

  List<GuideLine> _generateGuides(CompositionRule rule, SceneType sceneType, Rect? subject, Offset? idealPos, double score) {
    final guides = <GuideLine>[];
    final w = _imageWidth;
    final h = _imageHeight;

    switch (rule) {
      case CompositionRule.ruleOfThirds:
        guides.addAll([
          GuideLine(start: Offset(w / 3, 0), end: Offset(w / 3, h)),
          GuideLine(start: Offset(w * 2 / 3, 0), end: Offset(w * 2 / 3, h)),
          GuideLine(start: Offset(0, h / 3), end: Offset(w, h / 3)),
          GuideLine(start: Offset(0, h * 2 / 3), end: Offset(w, h * 2 / 3)),
        ]);
        break;
      case CompositionRule.center:
        guides.add(GuideLine(
          start: Offset(w / 2 - 40, h / 2), end: Offset(w / 2 + 40, h / 2), type: GuidLineType.target,
        ));
        break;
      case CompositionRule.symmetric:
        guides.add(GuideLine(start: Offset(w / 2, 0), end: Offset(w / 2, h)));
        break;
      case CompositionRule.frameGuide:
        guides.addAll([
          GuideLine(start: Offset(w * 0.1, h * 0.1), end: Offset(w * 0.9, h * 0.1), type: GuidLineType.frame),
          GuideLine(start: Offset(w * 0.1, h * 0.9), end: Offset(w * 0.9, h * 0.9), type: GuidLineType.frame),
          GuideLine(start: Offset(w * 0.1, h * 0.1), end: Offset(w * 0.1, h * 0.9), type: GuidLineType.frame),
          GuideLine(start: Offset(w * 0.9, h * 0.1), end: Offset(w * 0.9, h * 0.9), type: GuidLineType.frame),
        ]);
        break;
      case CompositionRule.leadingLines:
        if (sceneType == SceneType.landscape) {
          guides.add(GuideLine(start: Offset(w * 0.3, h), end: Offset(w * 0.5, h * 0.4), type: GuidLineType.arrow));
        } else {
          guides.add(GuideLine(start: Offset(0, h), end: Offset(w / 2, h * 0.4), type: GuidLineType.arrow));
        }
        break;
      case CompositionRule.goldenRatio:
        guides.addAll([
          GuideLine(start: Offset(w * 0.382, 0), end: Offset(w * 0.382, h)),
          GuideLine(start: Offset(0, h * 0.382), end: Offset(w, h * 0.382)),
        ]);
        break;
      case CompositionRule.diagonal:
        guides.addAll([
          GuideLine(start: Offset(0, 0), end: Offset(w, h), type: GuidLineType.arrow),
          GuideLine(start: Offset(w, 0), end: Offset(0, h), type: GuidLineType.arrow),
        ]);
        break;
    }

    return guides;
  }

  String? _getTipText(SceneType sceneType, CompositionRule rule, double score) {
    if (score > 0.85) return null;
    switch (rule) {
      case CompositionRule.ruleOfThirds:
        return '将主体放在网格线交点上';
      case CompositionRule.center:
        return '将主体置于画面正中央';
      case CompositionRule.symmetric:
        return '保持画面左右对称';
      case CompositionRule.frameGuide:
        return '利用前景元素框住主体';
      case CompositionRule.leadingLines:
        return '利用线条引导视线到主体';
      case CompositionRule.goldenRatio:
        return '将主体放在黄金分割点';
      case CompositionRule.diagonal:
        return '沿对角线布局画面元素';
    }
  }
}

class _AlignmentResult {
  final double score;
  final double progress;
  final Offset? direction;
  final String? hint;
  const _AlignmentResult(this.score, this.progress, this.direction, this.hint);
}



