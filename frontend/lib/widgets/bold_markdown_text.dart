import 'package:flutter/material.dart';

final RegExp _boldPattern = RegExp(r'\*\*(.+?)\*\*');

/// Splits `**bold**` markdown out of [text] into spans so it renders as
/// actual bold text instead of literal asterisks. Gemini/AI responses come
/// back with this markdown; nothing on the client was parsing it.
List<InlineSpan> parseBoldMarkdown(String text, TextStyle style) {
  final boldStyle = style.copyWith(fontWeight: FontWeight.bold);
  final spans = <InlineSpan>[];
  var start = 0;
  for (final match in _boldPattern.allMatches(text)) {
    if (match.start > start) {
      spans.add(TextSpan(text: text.substring(start, match.start), style: style));
    }
    spans.add(TextSpan(text: match.group(1), style: boldStyle));
    start = match.end;
  }
  if (start < text.length) {
    spans.add(TextSpan(text: text.substring(start), style: style));
  }
  return spans;
}

/// A [Text] drop-in that renders `**bold**` markdown segments as bold.
class BoldMarkdownText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextOverflow? overflow;
  final int? maxLines;

  const BoldMarkdownText(
    this.text, {
    super.key,
    required this.style,
    this.overflow,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(children: parseBoldMarkdown(text, style)),
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}
