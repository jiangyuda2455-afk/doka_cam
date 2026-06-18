import 'dart:ui' show Rect, Offset;

enum SceneType {
  portrait,
  landscape,
  architecture,
  food,
  street,
  night,
  indoor,
  unknown,
}

enum CompositionRule {
  ruleOfThirds,
  symmetric,
  frameGuide,
  leadingLines,
  center,
  goldenRatio,
  diagonal,
}

class CompositionResult {
  final SceneType sceneType;
  final List<CompositionRule> recommendedRules;
  final CompositionRule activeRule;
  final Rect? subjectRect;
  final Offset? idealSubjectPosition;
  final Offset? movementDirection;
  final String? movementHint;
  final double? recommendedZoom;
  final double alignmentScore;
  final double alignmentProgress;
  final List<GuideLine> guideLines;
  final String? tipText;

  const CompositionResult({
    required this.sceneType,
    this.recommendedRules = const [],
    this.activeRule = CompositionRule.ruleOfThirds,
    this.subjectRect,
    this.idealSubjectPosition,
    this.movementDirection,
    this.movementHint,
    this.recommendedZoom,
    this.alignmentScore = 0.0,
    this.alignmentProgress = 0.0,
    this.guideLines = const [],
    this.tipText,
  });

  bool get isAligned => alignmentScore > 0.85;
  bool get hasSubject => subjectRect != null;

  String get sceneLabel {
    switch (sceneType) {
      case SceneType.portrait: return '人像';
      case SceneType.landscape: return '风景';
      case SceneType.architecture: return '建筑';
      case SceneType.food: return '美食';
      case SceneType.street: return '街拍';
      case SceneType.night: return '夜景';
      case SceneType.indoor: return '室内';
      case SceneType.unknown: return '自动';
    }
  }

  String get ruleLabel {
    switch (activeRule) {
      case CompositionRule.ruleOfThirds: return '三分法';
      case CompositionRule.symmetric: return '对称构图';
      case CompositionRule.frameGuide: return '框架构图';
      case CompositionRule.leadingLines: return '引导线';
      case CompositionRule.center: return '居中构图';
      case CompositionRule.goldenRatio: return '黄金比例';
      case CompositionRule.diagonal: return '对角线';
    }
  }
}

class GuideLine {
  final Offset start;
  final Offset end;
  final GuidLineType type;

  const GuideLine({
    required this.start,
    required this.end,
    this.type = GuidLineType.grid,
  });
}

enum GuidLineType {
  grid,
  frame,
  arrow,
  target,
  boundingBox,
}
