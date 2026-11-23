import 'package:flutter/widgets.dart';

final RegExp rtlPattern = RegExp(r'[\u0590-\u08FF\uFB1D-\uFDFF\uFE70-\uFEFF]');

bool isRtl(String value) => rtlPattern.hasMatch(value);

/// Splits [sentence] so the first occurrence of [term] gets [highlight].
List<InlineSpan> highlightTerm(
  String sentence,
  String term,
  TextStyle? base,
  TextStyle? highlight,
) {
  final needle = term.trim().toLowerCase();
  final lower = sentence.toLowerCase();
  if (needle.isEmpty || lower.length != sentence.length) {
    return [TextSpan(text: sentence, style: base)];
  }
  final index = lower.indexOf(needle);
  if (index < 0) {
    return [TextSpan(text: sentence, style: base)];
  }
  final end = index + needle.length;
  return [
    TextSpan(text: sentence.substring(0, index), style: base),
    TextSpan(text: sentence.substring(index, end), style: highlight),
    TextSpan(text: sentence.substring(end), style: base),
  ];
}
