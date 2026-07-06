import 'package:flutter/material.dart';
import '../../../models/citizen/complaint_tracking_model.dart';
import '../../../theme/citizen/citizen_track_colors.dart';

/// Vertical animated progress tracker.
///
/// Renders each [ComplaintTrackStep] with a connecting line: completed
/// steps are solid green with a check, the current step glows yellow
/// with a pulsing dot, and pending steps stay muted grey. Purely driven
/// by the [steps] list, so it will render correctly once real step data
/// arrives from the backend.
class VerticalStepTracker extends StatelessWidget {
  final List<ComplaintTrackStep> steps;

  const VerticalStepTracker({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;
        return _StepRow(
          step: step,
          isLast: isLast,
        );
      }),
    );
  }
}

class _StepRow extends StatelessWidget {
  final ComplaintTrackStep step;
  final bool isLast;

  const _StepRow({required this.step, required this.isLast});

  Color get _color {
    switch (step.state) {
      case TrackStepState.completed:
        return CitizenTrackColors.success;
      case TrackStepState.current:
        return CitizenTrackColors.primary;
      case TrackStepState.pending:
        return CitizenTrackColors.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    final isCurrent = step.state == TrackStepState.current;
    final isCompleted = step.state == TrackStepState.completed;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              _StepDot(color: color, pulsing: isCurrent, filled: isCompleted || isCurrent),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    color: isCompleted
                        ? CitizenTrackColors.success.withOpacity(0.5)
                        : CitizenTrackColors.divider,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.label,
                    style: TextStyle(
                      color: step.state == TrackStepState.pending
                          ? CitizenTrackColors.textSecondary
                          : CitizenTrackColors.textPrimary,
                      fontWeight:
                      isCurrent ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 13.5,
                    ),
                  ),
                  if (step.timestamp != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      _formatTime(step.timestamp!),
                      style: const TextStyle(
                        color: CitizenTrackColors.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                  if (isCurrent) ...[
                    const SizedBox(height: 4),
                    const Text(
                      'In Progress',
                      style: TextStyle(
                        color: CitizenTrackColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

class _StepDot extends StatefulWidget {
  final Color color;
  final bool pulsing;
  final bool filled;

  const _StepDot({
    required this.color,
    required this.pulsing,
    required this.filled,
  });

  @override
  State<_StepDot> createState() => _StepDotState();
}

class _StepDotState extends State<_StepDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    if (widget.pulsing) _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final glowStrength = widget.pulsing ? 0.25 + (_controller.value * 0.35) : 0.0;
        return Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.filled
                ? widget.color.withOpacity(widget.pulsing ? 0.18 : 0.16)
                : CitizenTrackColors.card,
            border: Border.all(
              color: widget.color,
              width: widget.filled ? 2 : 1.4,
            ),
            boxShadow: widget.pulsing
                ? [CitizenTrackColors.glow(widget.color, opacity: glowStrength)]
                : null,
          ),
          child: Center(
            child: widget.filled && !widget.pulsing
                ? Icon(Icons.check_rounded, size: 14, color: widget.color)
                : Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.filled
                    ? widget.color
                    : CitizenTrackColors.pending,
              ),
            ),
          ),
        );
      },
    );
  }
}
