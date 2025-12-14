part of '../daily_news_hbb.dart';

class _CardSurface extends StatelessWidget {
  const _CardSurface({
    required this.radius,
    required this.shadowOpacity,
    required this.shadowBlur,
    required this.shadowOffset,
    required this.onTap,
    required this.child,
    this.color = Colors.white,
  });

  final double radius;
  final double shadowOpacity;
  final double shadowBlur;
  final Offset shadowOffset;
  final VoidCallback onTap;
  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius);

    return Material(
      color: color,
      borderRadius: r,
      child: InkWell(
        borderRadius: r,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: r,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(shadowOpacity),
                blurRadius: shadowBlur,
                offset: shadowOffset,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: r,
            child: child,
          ),
        ),
      ),
    );
  }
}
