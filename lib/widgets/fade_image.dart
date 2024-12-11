import 'package:flutter/material.dart';

class FadeInOutImage extends StatefulWidget {
  final double height;

  const FadeInOutImage({Key? key, required this.height}) : super(key: key);

  @override
  _FadeInOutImageState createState() => _FadeInOutImageState();
}

class _FadeInOutImageState extends State<FadeInOutImage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Image.asset(
        'assets/grey_image.jpeg', // Replace with your image path
        width: MediaQuery.of(context).size.width,
        height: widget.height,
        fit: BoxFit.cover,
      ),
    );
  }
}
