import 'dart:async';
import 'package:flutter/material.dart';

Widget _snackBuilder(BuildContext context) =>
    const SnackBar(content: Text("Timeout replace."));

class TimerReplace extends StatefulWidget {
  final Duration duration;
  final Widget Function(BuildContext context) builder;
  final Widget Function(BuildContext context) replaceBuilder;
  final Function()? onTimeout;

  const TimerReplace({
    super.key,
    required this.duration,
    required this.builder,
    this.replaceBuilder = _snackBuilder,
    this.onTimeout,
  });

  @override
  State<TimerReplace> createState() => _TimerReplaceState();
}

class _TimerReplaceState extends State<TimerReplace> {
  bool _timeoutReached = false;

  @override
  void initState() {
    super.initState();

    Timer(widget.duration, _onTimeout);
  }

  void _onTimeout() {
    if (widget.onTimeout != null) {
      widget.onTimeout!();
    }

    setState(() {
      _timeoutReached = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return (_timeoutReached ? widget.replaceBuilder : widget.builder)(context);
  }
}
