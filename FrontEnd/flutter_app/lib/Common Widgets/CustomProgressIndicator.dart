import 'package:flutter/material.dart';

// class CustomProgressIndicator extends StatefulWidget {
//   final double value;

//   const CustomProgressIndicator({Key? key, required this.value}) : super(key: key);

//   @override
//   _CustomProgressIndicatorState createState() => _CustomProgressIndicatorState();
// }

// class _CustomProgressIndicatorState extends State<CustomProgressIndicator>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2),
//     )..repeat();
//     _animation = Tween<double>(begin: 0.0, end: 2 * 3.14).animate(_controller);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _animation,
//       builder: (context, child) {
//         return Transform.rotate(
//           angle: _animation.value,
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: const BoxDecoration(
//                   color: Colors.red,
//                   shape: BoxShape.circle,
//                 ),
//               ),
//               Container(
//                 width: 30,
//                 height: 30,
//                 decoration: const BoxDecoration(
//                   color: Colors.yellow,
//                   shape: BoxShape.circle,
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }


class CustomProgressIndicator extends StatefulWidget {
  const CustomProgressIndicator({super.key});

  @override
  _CustomProgressIndicatorState createState() =>
      _CustomProgressIndicatorState();
}

class _CustomProgressIndicatorState extends State<CustomProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContextContext) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(_animation.value * 2 * 3.14),
          alignment: Alignment.center,
          child: Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/IronSightLogo.png'),
              ),
            ),
          ),
        );
      },
    );
  }
}