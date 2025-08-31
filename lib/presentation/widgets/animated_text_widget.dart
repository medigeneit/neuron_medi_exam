import 'package:flutter/material.dart';

enum AnimationType {
  pulse,      // Scale and opacity animation
  colorShift, // Color transition animation
  bounce,     // Bouncing movement animation
  blink,      // Simple blinking opacity animation
  wave,       // Wave-like movement animation
}

class AnimatedText extends StatefulWidget {
  final String text;
  final Color color;
  final double? fontSize;
  final FontWeight fontWeight;
  final double letterSpacing;
  final int maxLines;
  final TextOverflow overflow;
  final AnimationType animationType;
  final Duration duration;
  final List<Color>? colorPalette; // For colorShift animation
  final double intensity; // Controls animation strength (0.0 to 1.0)

  const AnimatedText({
    super.key,
    required this.text,
    required this.color,
    this.fontSize,
    this.fontWeight = FontWeight.w800,
    this.letterSpacing = 0.1,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.animationType = AnimationType.pulse,
    this.duration = const Duration(milliseconds: 1500),
    this.colorPalette,
    this.intensity = 0.3,
  });

  @override
  State<AnimatedText> createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _setupAnimations();
  }

  void _setupAnimations() {
    switch (widget.animationType) {
      case AnimationType.pulse:
        _animation = Tween<double>(
          begin: 1.0 - (widget.intensity * 0.3),
          end: 1.0 + (widget.intensity * 0.2),
        ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
        break;

      case AnimationType.bounce:
        _animation = Tween<double>(
          begin: 0,
          end: widget.intensity * 20,
        ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
        );
        break;

      case AnimationType.wave:
        _animation = Tween<double>(
          begin: -widget.intensity * 10,
          end: widget.intensity * 10,
        ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
        break;

      case AnimationType.blink:
        _animation = Tween<double>(
          begin: 0.3 + (widget.intensity * 0.4),
          end: 1.0,
        ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
        break;

      case AnimationType.colorShift:
        final colors = widget.colorPalette ?? [
          widget.color,
          widget.color.withOpacity(0.7),
          widget.color.withOpacity(0.5),
        ];
        _colorAnimation = ColorTween(begin: colors[0], end: colors[1])
            .chain(CurveTween(curve: Curves.easeInOut))
            .animate(_controller);
        break;
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animationType != widget.animationType ||
        oldWidget.intensity != widget.intensity ||
        oldWidget.duration != widget.duration) {
      _controller.dispose();
      _controller = AnimationController(
        duration: widget.duration,
        vsync: this,
      )..repeat(reverse: true);
      _setupAnimations();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return _buildAnimatedText();
      },
    );
  }

  Widget _buildAnimatedText() {
    final textWidget = Text(
      widget.text,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
      style: TextStyle(
        fontSize: widget.fontSize,
        fontWeight: widget.fontWeight,
        color: _getTextColor(),
        letterSpacing: widget.letterSpacing,
      ),
    );

    switch (widget.animationType) {
      case AnimationType.pulse:
        return Opacity(
          opacity: _animation.value.clamp(0.7, 1.0),
          child: Transform.scale(
            scale: _animation.value,
            child: textWidget,
          ),
        );

      case AnimationType.bounce:
        return Transform.translate(
          offset: Offset(0, -_animation.value),
          child: textWidget,
        );

      case AnimationType.wave:
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: textWidget,
        );

      case AnimationType.blink:
        return Opacity(
          opacity: _animation.value,
          child: textWidget,
        );

      case AnimationType.colorShift:
        return textWidget;
    }
  }

  Color _getTextColor() {
    if (widget.animationType == AnimationType.colorShift) {
      return _colorAnimation.value ?? widget.color;
    }
    return widget.color;
  }
}