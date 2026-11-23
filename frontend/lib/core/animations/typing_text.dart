import 'dart:async';

import 'package:flutter/material.dart';

class TypingText extends StatefulWidget {
  const TypingText({
    required this.values,
    required this.style,
    super.key,
    this.typingDelay = const Duration(milliseconds: 74),
    this.pause = const Duration(milliseconds: 1450),
  });

  final List<String> values;
  final TextStyle style;
  final Duration typingDelay;
  final Duration pause;

  @override
  State<TypingText> createState() => _TypingTextState();
}

class _TypingTextState extends State<TypingText> {
  Timer? _timer;
  int _valueIndex = 0;
  int _characterIndex = 0;
  bool _deleting = false;

  String get _currentValue => widget.values[_valueIndex % widget.values.length];

  @override
  void initState() {
    super.initState();
    _scheduleNext();
  }

  void _scheduleNext([Duration? override]) {
    _timer?.cancel();
    _timer = Timer(override ?? widget.typingDelay, _tick);
  }

  void _tick() {
    if (!mounted || widget.values.isEmpty) return;

    var reachedEnd = false;

    setState(() {
      if (_deleting) {
        _characterIndex -= 1;
        if (_characterIndex <= 0) {
          _characterIndex = 0;
          _deleting = false;
          _valueIndex = (_valueIndex + 1) % widget.values.length;
        }
      } else {
        _characterIndex += 1;
        if (_characterIndex >= _currentValue.length) {
          _characterIndex = _currentValue.length;
          _deleting = true;
          reachedEnd = true;
        }
      }
    });

    _scheduleNext(
      reachedEnd
          ? widget.pause
          : _deleting
              ? Duration(
                  milliseconds:
                      (widget.typingDelay.inMilliseconds * .55).round())
              : widget.typingDelay,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.values.isEmpty) return const SizedBox.shrink();

    final longest = widget.values.reduce(
      (left, right) => left.length >= right.length ? left : right,
    );
    final visible = _currentValue.substring(0, _characterIndex);

    return Semantics(
      label: _currentValue,
      liveRegion: true,
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          Opacity(
            opacity: 0,
            child: Text(
              '$longest|',
              style: widget.style,
              maxLines: 2,
              overflow: TextOverflow.visible,
            ),
          ),
          Text(
            '$visible|',
            style: widget.style,
            maxLines: 2,
            overflow: TextOverflow.visible,
          ),
        ],
      ),
    );
  }
}
