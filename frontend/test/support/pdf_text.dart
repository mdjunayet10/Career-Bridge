import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

// Decode embedded TrueType glyphs through the PDF's own ToUnicode maps.
// Inspect text operators rather than metadata or widget implementation details.
String extractPdfText(Uint8List bytes) {
  final source = latin1.decode(bytes);
  final objects = <int, String>{
    for (final match in RegExp(r'(\d+)\s+0\s+obj\b(.*?)endobj', dotAll: true)
        .allMatches(source))
      int.parse(match.group(1)!): match.group(2)!,
  };
  final fontMaps = <String, Map<int, int>>{};
  for (final resource
      in RegExp(r'/(F\d+)\s+(\d+)\s+0\s+R').allMatches(source)) {
    final font = objects[int.parse(resource.group(2)!)];
    if (font == null) continue;
    final unicode = RegExp(r'/ToUnicode\s*(\d+)\s+0\s+R').firstMatch(font);
    if (unicode == null) continue;
    final mapStream =
        _decodedStream(objects[int.parse(unicode.group(1)!)] ?? '');
    final mapping = <int, int>{};
    for (final block in RegExp(r'beginbfchar(.*?)endbfchar', dotAll: true)
        .allMatches(mapStream)) {
      for (final pair in RegExp(r'<([0-9A-Fa-f]+)>\s*<([0-9A-Fa-f]+)>')
          .allMatches(block.group(1)!)) {
        mapping[int.parse(pair.group(1)!, radix: 16)] =
            int.parse(pair.group(2)!, radix: 16);
      }
    }
    fontMaps[resource.group(1)!] = mapping;
  }
  final words = <String>[];
  for (final body in objects.values) {
    final content = _decodedStream(body);
    if (!content.contains('TJ')) continue;
    String? currentFont;
    for (final operator
        in RegExp(r'/(F\d+)\s+[-\d.]+\s+Tf|\[(.*?)\]\s*TJ', dotAll: true)
            .allMatches(content)) {
      if (operator.group(1) != null) {
        currentFont = operator.group(1);
        continue;
      }
      final text = StringBuffer();
      for (final token in RegExp(r'\(((?:\\.|[^\\)])*)\)|<([0-9A-Fa-f]+)>')
          .allMatches(operator.group(2)!)) {
        if (token.group(1) != null) {
          text.write(token.group(1)!.replaceAllMapped(
              RegExp(r'\\([\\()])'), (match) => match.group(1)!));
        } else {
          final hex = token.group(2)!;
          for (var index = 0; index + 4 <= hex.length; index += 4) {
            final glyph = int.parse(hex.substring(index, index + 4), radix: 16);
            final code = fontMaps[currentFont]?[glyph];
            if (code != null) text.writeCharCode(code);
          }
        }
      }
      words.add(text.toString());
    }
  }
  return words.join(' ').replaceAll(RegExp(r'\s+'), ' ');
}

String _decodedStream(String body) {
  final match =
      RegExp(r'stream\r?\n(.*?)endstream', dotAll: true).firstMatch(body);
  if (match == null) return '';
  final encoded = latin1.encode(match.group(1)!);
  try {
    return latin1.decode(zlib.decode(encoded));
  } catch (_) {
    return latin1.decode(encoded);
  }
}
