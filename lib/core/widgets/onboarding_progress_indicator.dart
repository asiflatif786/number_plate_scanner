import 'package:flutter/material.dart';

class OnboardingProgressIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> stepLabels;

  const OnboardingProgressIndicator({
    super.key,
    required this.currentStep,
    required this.stepLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(stepLabels.length * 2 - 1, (index) {
          if (index.isOdd) {
            final stepIndex = index ~/ 2;
            return _buildConnectorLine(stepIndex);
          }
          final stepIndex = index ~/ 2;
          return _buildStep(stepIndex + 1);
        }),
      ),
    );
  }

  Widget _buildStep(int step) {
    final isCompleted = step < currentStep;
    final isCurrent = step == currentStep;

    Color circleColor;
    Widget child;

    if (isCompleted) {
      circleColor = const Color(0xFF2E7D32);
      child = const Icon(Icons.check, color: Colors.white, size: 18);
    } else if (isCurrent) {
      circleColor = const Color(0xFF1A237E);
      child = Text(
        '$step',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      );
    } else {
      circleColor = Colors.transparent;
      child = Text(
        '$step',
        style: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      );
    }

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: isCompleted || isCurrent
                    ? circleColor
                    : Colors.grey,
                width: 2,
              ),
            ),
            child: Center(child: child),
          ),
          const SizedBox(height: 4),
          Text(
            stepLabels[step - 1],
            style: TextStyle(
              fontSize: 11,
              fontWeight: isCompleted || isCurrent
                  ? FontWeight.w600
                  : FontWeight.normal,
              color: isCompleted
                  ? const Color(0xFF2E7D32)
                  : isCurrent
                      ? const Color(0xFF1A237E)
                      : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectorLine(int stepIndex) {
    final isCompleted = (stepIndex + 1) < currentStep;

    return SizedBox(
      width: 24,
      child: Center(
        child: Container(
          height: 2,
          color: isCompleted ? const Color(0xFF2E7D32) : Colors.grey[300],
        ),
      ),
    );
  }
}
