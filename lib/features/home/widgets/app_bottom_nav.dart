import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<IconData> _icons = [
    Icons.home_rounded,
    Icons.shopping_bag_outlined,
    Icons.assignment_outlined,
    Icons.person_outline,
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width - 40;
    final double tabWidth = width / _icons.length;
    final double targetCenterX = (currentIndex * tabWidth) + (tabWidth / 2);

    return Container(
      height: 75,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: targetCenterX, end: targetCenterX),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        builder: (context, animatedX, child) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              CustomPaint(
                size: Size(width, 75),
                painter: NavBarClipper(
                  centerX: animatedX,
                  backgroundColor: AppColors.primary,
                ),
              ),

              Positioned(
                left: animatedX - 8,
                top: -6,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.iconColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              Positioned.fill(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    _icons.length,
                    (index) => GestureDetector(
                      onTap: () => onTap(index),
                      child: Icon(
                        _icons[index],
                        color: currentIndex == index
                            ? AppColors.iconColor
                            : Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class NavBarClipper extends CustomPainter {
  final double centerX;
  final Color backgroundColor;

  NavBarClipper({
    required this.centerX,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = backgroundColor;
    final path = Path();

    const notchWidth = 17.0;
    const notchDepth = 14.0;
    const borderRadius = 30.0;

    path.moveTo(borderRadius, 0);
    path.lineTo(centerX - notchWidth - 8, 0);

    path.cubicTo(
      centerX - notchWidth,
      0,
      centerX - (notchWidth * 0.5),
      notchDepth,
      centerX,
      notchDepth,
    );

    path.cubicTo(
      centerX + (notchWidth * 0.5),
      notchDepth,
      centerX + notchWidth,
      0,
      centerX + notchWidth + 8,
      0,
    );

    path.lineTo(size.width - borderRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, borderRadius);
    path.lineTo(size.width, size.height - borderRadius);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - borderRadius,
      size.height,
    );
    path.lineTo(borderRadius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - borderRadius);
    path.lineTo(0, borderRadius);
    path.quadraticBezierTo(0, 0, borderRadius, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(NavBarClipper oldDelegate) {
    return oldDelegate.centerX != centerX;
  }
}