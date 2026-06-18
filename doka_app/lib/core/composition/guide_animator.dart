class GuideAnimator {
  double _currentAlpha = 0.0;
  double _targetAlpha = 0.0;
  double _velocity = 0.0;

  double update(double dt) {
    final diff = _targetAlpha - _currentAlpha;
    final acceleration = diff.abs() > 0.01 ? diff.sign * 8.0 : 0.0;
    _velocity += acceleration * dt;
    _velocity *= 0.85; // damping
    _currentAlpha += _velocity * dt;
    _currentAlpha = _currentAlpha.clamp(0.0, 1.0);
    return _currentAlpha;
  }

  void show() => _targetAlpha = 1.0;
  void hide() => _targetAlpha = 0.0;
  bool get isVisible => _currentAlpha > 0.01;
  bool get isFullyVisible => _currentAlpha > 0.99;
  void reset() { _currentAlpha = 0.0; _targetAlpha = 0.0; _velocity = 0.0; }
}
