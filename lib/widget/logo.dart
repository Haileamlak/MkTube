import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Flutter code sample for [RotationTransition].

class MkLogo extends StatefulWidget {
  const MkLogo({super.key});

  @override
  State<MkLogo> createState() => _MkLogoState();
}

/// [AnimationController]s can be created with `vsync: this` because of
/// [TickerProviderStateMixin].
class _MkLogoState extends State<MkLogo> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 5),
    vsync: this,
  )..repeat(reverse: true);
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.linear,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            const Image(
              image: AssetImage("lib/myassets/mklogo1.png"),
              width: 128,
            ),
            RotationTransition(
              turns: _animation,
              child: const Icon(CupertinoIcons.bell),
            )
          ],
        ),
      ),
    );
  }
}
