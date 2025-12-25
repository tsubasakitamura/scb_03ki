import 'package:flutter/material.dart';
import 'package:untitled1/view/screens/bag_manager_screen.dart';

class BagZoomSplash extends StatefulWidget {
  final dynamic bag;

  const BagZoomSplash({Key? key, this.bag}) : super(key: key);

  @override
  _BagZoomSplashState createState() => _BagZoomSplashState();
}

class _BagZoomSplashState extends State<BagZoomSplash>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _scale = Tween<double>(begin: 1.0, end: 20.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInQuart),
    );

    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.linear),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _controller.forward();
      }
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
            const BagManagerScreen(mode: BagMode.master),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  } // <--- initState はここで終わり！

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scale.value,
              child: Opacity(
                opacity: _opacity.value,
                child: Image.asset(
                  'assets/images/bag.PNG',
                  width: 120,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}