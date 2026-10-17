import 'package:flutter/material.dart';

/// A fixed, decorative watermark behind the signed-in application's content.
class PhotoScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  const PhotoScaffold({super.key, this.appBar, required this.body,
    this.bottomNavigationBar, this.backgroundColor});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFFAF7F4),
    appBar: appBar,
    bottomNavigationBar: bottomNavigationBar,
    body: Stack(children: [
      Positioned.fill(child: IgnorePointer(child: ExcludeSemantics(child: Opacity(
        opacity: 0.075,
        child: Image.asset('assets/images/planning.png', fit: BoxFit.cover,
          alignment: Alignment.centerRight),
      )))),
      Positioned.fill(child: IgnorePointer(child: DecoratedBox(decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Colors.white.withValues(alpha: .45), const Color(0xFFFFF2EB).withValues(alpha: .12)]),
      )))),
      Positioned.fill(child: body),
    ]),
  );
}
