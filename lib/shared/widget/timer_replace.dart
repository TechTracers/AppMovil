import 'dart:async';
import 'package:flutter/material.dart';

// Default SnackBar for timeout replacement
Widget _snackBuilder(BuildContext context) =>
    const SnackBar(content: Text("Timeout replace."));

// Controller class for manual timeout
class TimerReplaceController {
  void Function()? _forceTimeoutCallback;

  // This sets the callback that triggers timeout
  void _setForceTimeoutCallback(void Function() callback) {
    _forceTimeoutCallback = callback;
  }

  // Method to manually trigger the timeout
  void forceTimeout() {
    _forceTimeoutCallback?.call();
  }
}

class TimerReplace extends StatefulWidget {
  final Duration duration;
  final Widget Function(BuildContext context) builder;
  final Widget Function(BuildContext context) replaceBuilder;
  final Function()? onTimeout;
  final TimerReplaceController? controller;

  const TimerReplace({
    super.key,
    required this.duration,
    required this.builder,
    this.replaceBuilder = _snackBuilder,
    this.onTimeout,
    this.controller, // Added controller as argument
  });

  @override
  State<TimerReplace> createState() => _TimerReplaceState();
}

class _TimerReplaceState extends State<TimerReplace> {
  bool _timeoutReached = false;

  @override
  void initState() {
    super.initState();
    widget.controller?._setForceTimeoutCallback(_onTimeout);
    Timer(widget.duration, _onTimeout);
  }

  void _onTimeout() {
    if (_timeoutReached) return;
    if (widget.onTimeout != null) widget.onTimeout!();

    setState(() {
      _timeoutReached = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Return the replaceBuilder widget if timeout has been reached, otherwise return the builder
    return (_timeoutReached ? widget.replaceBuilder : widget.builder)(context);
  }
}
