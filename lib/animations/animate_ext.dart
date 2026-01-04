import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'animaton_constants.dart';
extension AnimationExtensions on Animate {

  Animate pageEntrance({double delay = 0}) {
    return fade(duration: AnimProps.medium)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad, delay: delay.ms);
  }

  Animate popIn({double delay = 0}) {
    return scale(
      delay: delay.ms,
      duration: AnimProps.fast,
      curve: Curves.elasticOut,
      begin: const Offset(0.5, 0.5),
    ).fadeIn();
  }

  Animate listItem({required int index}) {
    return fade(duration: AnimProps.medium, delay: (index * 100).ms)
        .slideX(begin: -0.1, end: 0, curve: Curves.easeOut);
  }

  Animate shimmerHighlight() {
    return shimmer(duration: 2.seconds, color: Colors.white.withOpacity(0.5));
  }
}