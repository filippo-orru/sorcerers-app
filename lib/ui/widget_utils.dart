import 'package:flutter/material.dart';

class MaxWidth extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const MaxWidth({super.key, required this.child, this.maxWidth = 600});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

class MenuWithBack extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final void Function(BuildContext) onBack;

  const MenuWithBack({
    super.key,
    required this.title,
    required this.children,
    void Function(BuildContext)? onBack,
  }) : onBack = onBack ?? _defaultOnBack;

  static void _defaultOnBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MaxWidth(
            maxWidth: 400 + 48 * 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: Center(
                          child: IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () => onBack(context),
                          ),
                        ),
                      ),
                      Text(
                        title,
                        style: TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 48),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: children,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget Function(Widget?, List<Widget>) layoutWithBackground(BuildContext context) {
  return (currentChild, previousChildren) {
    return Stack(
      children: [
        Container(
          key: ValueKey("background"),
          color: Theme.of(context).colorScheme.surface,
        ),
        ...previousChildren,
        if (currentChild != null) currentChild,
      ],
    );
  };
}
