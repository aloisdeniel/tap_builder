import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'mouse_cursor_builder.dart';
import 'tap_state.dart';

part 'animated_tap_builder.dart';
part 'tap_builder_base.dart';

typedef TapWidgetBuilder = Widget Function(
  BuildContext context,
  TapState state,
  bool isFocused,
);

class TapBuilder extends _TapBuilderWidget {
  const TapBuilder({
    Key? key,
    required this.builder,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    TapMouseCursorBuilder mouseCursorBuilder = defaultMouseCursorBuilder,
    bool enableFeedback = true,
    bool excludeFromSemantics = false,
    FocusNode? focusNode,
    bool canRequestFocus = true,
    ValueChanged<bool>? onFocusChange,
    bool autofocus = false,
    FocusOnKeyCallback? onKey,
    FocusOnKeyEventCallback? onKeyEvent,
    HitTestBehavior hitTestBehavior = HitTestBehavior.opaque,
    Duration? minPressedDuration,
  }) : super(
          key: key,
          onTap: onTap,
          onLongPress: onLongPress,
          mouseCursorBuilder: mouseCursorBuilder,
          enableFeedback: enableFeedback,
          excludeFromSemantics: excludeFromSemantics,
          focusNode: focusNode,
          canRequestFocus: canRequestFocus,
          onFocusChange: onFocusChange,
          autofocus: autofocus,
          onKey: onKey,
          onKeyEvent: onKeyEvent,
          hitTestBehavior: hitTestBehavior,
          minPressedDuration: minPressedDuration,
        );

  final TapWidgetBuilder builder;

  @override
  _TapBuilderState createState() => _TapBuilderState();
}

class _TapBuilderState extends _TapBuilderBaseState<TapBuilder> {
  @override
  Widget buildChild(BuildContext context) {
    return widget.builder(context, state, isFocused);
  }
}
