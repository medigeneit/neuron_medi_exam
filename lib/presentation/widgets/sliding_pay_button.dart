import 'package:flutter/material.dart';

class SlidingButton extends StatefulWidget {
  final List<Color> gradientColors;
  final double totalAmount;
  final VoidCallback onPaymentInitiated;

  const SlidingButton({
    required this.gradientColors,
    required this.totalAmount,
    required this.onPaymentInitiated,
  });

  @override
  _SlidingButtonState createState() => _SlidingButtonState();
}

class _SlidingButtonState extends State<SlidingButton> {
  double _dragPosition = 0;
  bool _paymentInitiated = false;

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_paymentInitiated) return;

    setState(() {
      _dragPosition += details.delta.dx;
      _dragPosition = _dragPosition.clamp(0, 200); // Max drag distance
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_paymentInitiated) return;

    if (_dragPosition > 150) { // Threshold for payment initiation
      setState(() {
        _paymentInitiated = true;
      });
      widget.onPaymentInitiated();

      // Reset after delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _dragPosition = 0;
            _paymentInitiated = false;
          });
        }
      });
    } else {
      // Return to start
      setState(() {
        _dragPosition = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.grey[200],
      ),
      child: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                colors: widget.gradientColors,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Center(
              child: Text(
                _paymentInitiated ? 'Processing...' : 'Swipe to Pay ৳${widget.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          // Slider
          AnimatedPositioned(
            duration: const Duration(milliseconds: 100),
            left: _dragPosition,
            child: GestureDetector(
              onHorizontalDragUpdate: _onHorizontalDragUpdate,
              onHorizontalDragEnd: _onHorizontalDragEnd,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: widget.gradientColors[0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}