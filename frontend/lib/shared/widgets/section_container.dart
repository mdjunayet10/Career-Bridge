import 'package:flutter/material.dart';

class SectionContainer extends StatelessWidget {
  const SectionContainer({
    required this.child,
    super.key,
    this.maxWidth = 1180,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 72),
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}
