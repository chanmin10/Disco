import 'package:flutter/material.dart';

/// Engine picker reused in the chat toolbar and (later) the settings screen.
/// Internal values: 'general' (Gemini) / 'quick' (Google Translate).
class SegmentedControl extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const SegmentedControl({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _segment(label: 'General', segmentValue: 'general'),
          const SizedBox(width: 2),
          _segment(label: 'Quick', segmentValue: 'quick'),
        ],
      ),
    );
  }

  Widget _segment({required String label, required String segmentValue}) {
    final isSelected = value == segmentValue;
    return GestureDetector(
      onTap: () => onChanged(segmentValue),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? const Color(0xFF1D1D1F) : const Color(0xFF6E6E73),
          ),
        ),
      ),
    );
  }
}
