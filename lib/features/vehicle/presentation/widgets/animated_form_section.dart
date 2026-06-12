import 'package:flutter/material.dart';
import '../../../../core/utils/logger.dart';

class AnimatedFormSection extends StatefulWidget {
  final bool isVisible;
  final Widget child;
  final Duration duration;

  const AnimatedFormSection({
    super.key,
    required this.isVisible,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<AnimatedFormSection> createState() => _AnimatedFormSectionState();
}

class _AnimatedFormSectionState extends State<AnimatedFormSection> {
  @override
  void didUpdateWidget(AnimatedFormSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isVisible != widget.isVisible) {
      AppLogger.debug('AnimatedFormSection',
          'Visibility changed: ${widget.isVisible}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: widget.child,
      secondChild: const SizedBox.shrink(),
      crossFadeState: widget.isVisible
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      duration: widget.duration,
      firstCurve: Curves.easeInOut,
      secondCurve: Curves.easeInOut,
      layoutBuilder: (topChild, topKey, bottomChild, bottomKey) {
        return ClipRect(
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                key: bottomKey,
                left: 0,
                right: 0,
                top: 0,
                child: bottomChild,
              ),
              Positioned(
                key: topKey,
                left: 0,
                right: 0,
                top: 0,
                child: topChild,
              ),
            ],
          ),
        );
      },
    );
  }
}
