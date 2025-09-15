import 'package:flutter/widgets.dart';

/// A widget that reports its size after layout via [onChange].
class MeasureSize extends StatefulWidget {
  const MeasureSize({super.key, required this.onChange, required this.child});

  final Widget child;
  final ValueChanged<Size> onChange;

  @override
  State<MeasureSize> createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<MeasureSize> {
  Size? _oldSize;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ro = context.findRenderObject();
      if (ro is RenderBox && ro.attached && ro.hasSize) {
        final size = ro.size;
        if (_oldSize != size) {
          _oldSize = size;
          widget.onChange(size);
        }
      }
    });
    return widget.child;
  }
}
