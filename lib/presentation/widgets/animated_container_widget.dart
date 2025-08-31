import 'package:flutter/material.dart';

enum ContainerAnimationType {
  pulse,      // Scale and opacity animation
  colorShift, // Color transition animation
  bounce,     // Bouncing movement animation
  rotate,     // Rotation animation
  borderPulse, // Border width animation
}

class AnimatedCircleContainer extends StatefulWidget {
  final Widget? child;
  final Color? color;
  final Color? borderColor;
  final double? size;
  final double? borderWidth;
  final EdgeInsets? padding;
  final BoxShape shape;
  final ContainerAnimationType animationType;
  final Duration duration;
  final List<Color>? colorPalette;
  final double intensity;
  final Curve curve;

  const AnimatedCircleContainer({
    super.key,
    this.child,
    this.color,
    this.borderColor,
    this.size,
    this.borderWidth = 0,
    this.padding,
    this.shape = BoxShape.circle,
    this.animationType = ContainerAnimationType.pulse,
    this.duration = const Duration(milliseconds: 1500),
    this.colorPalette,
    this.intensity = 0.3,
    this.curve = Curves.easeInOut,
  });

  @override
  State<AnimatedCircleContainer> createState() => _AnimatedCircleContainerState();
}

class _AnimatedCircleContainerState extends State<AnimatedCircleContainer>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _borderAnimation;
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
    final curve = CurvedAnimation(parent: _controller, curve: widget.curve);

    switch (widget.animationType) {
      case ContainerAnimationType.pulse:
        _scaleAnimation = Tween<double>(
          begin: 1.0 - (widget.intensity * 0.2),
          end: 1.0 + (widget.intensity * 0.2),
        ).animate(curve);
        break;

      case ContainerAnimationType.bounce:
        _bounceAnimation = Tween<double>(
          begin: 0,
          end: widget.intensity * 15,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.elasticOut,
        ));
        break;

      case ContainerAnimationType.rotate:
        _rotateAnimation = Tween<double>(
          begin: 0,
          end: widget.intensity * 2 * 3.14159, // Full rotation in radians
        ).animate(curve);
        break;

      case ContainerAnimationType.borderPulse:
        _borderAnimation = Tween<double>(
          begin: widget.borderWidth ?? 0,
          end: (widget.borderWidth ?? 0) + (widget.intensity * 4),
        ).animate(curve);
        break;

      case ContainerAnimationType.colorShift:
        final colors = widget.colorPalette ?? [
          widget.color ?? Colors.blue,
          widget.color?.withOpacity(0.7) ?? Colors.blue.withOpacity(0.7),
          widget.color?.withOpacity(0.5) ?? Colors.blue.withOpacity(0.5),
        ];
        _colorAnimation = ColorTween(begin: colors[0], end: colors[1])
            .chain(CurveTween(curve: widget.curve))
            .animate(_controller);
        break;
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedCircleContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animationType != widget.animationType ||
        oldWidget.intensity != widget.intensity ||
        oldWidget.duration != widget.duration ||
        oldWidget.curve != widget.curve) {
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

  Color _getContainerColor() {
    if (widget.animationType == ContainerAnimationType.colorShift) {
      return _colorAnimation.value ?? widget.color ?? Colors.transparent;
    }
    return widget.color ?? Colors.transparent;
  }

  double _getBorderWidth() {
    if (widget.animationType == ContainerAnimationType.borderPulse) {
      return _borderAnimation.value;
    }
    return widget.borderWidth ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return _buildAnimatedContainer();
      },
    );
  }

  Widget _buildAnimatedContainer() {
    Widget container = Container(
      width: widget.size,
      height: widget.size,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: _getContainerColor(),
        shape: widget.shape,
        border: widget.borderColor != null
            ? Border.all(
          color: widget.borderColor!,
          width: _getBorderWidth(),
        )
            : null,
      ),
      child: widget.child,
    );

    switch (widget.animationType) {
      case ContainerAnimationType.pulse:
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: container,
        );

      case ContainerAnimationType.bounce:
        return Transform.translate(
          offset: Offset(0, -_bounceAnimation.value),
          child: container,
        );

      case ContainerAnimationType.rotate:
        return Transform.rotate(
          angle: _rotateAnimation.value,
          child: container,
        );

      case ContainerAnimationType.borderPulse:
      case ContainerAnimationType.colorShift:
        return container;
    }
  }
}