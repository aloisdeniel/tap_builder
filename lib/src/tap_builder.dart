import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'tap_state.dart';

typedef TapWidgetBuilder = Widget Function(
  BuildContext context,
  TapState state,
);

class TapBuilder extends StatefulWidget {
  const TapBuilder({
    Key key,
    @required this.builder,
    this.onTap,
    this.mouseCursor,
    this.enableFeedback = true,
    this.excludeFromSemantics = false,
    this.focusNode,
    this.canRequestFocus = true,
    this.onFocusChange,
    this.autofocus = false,
  })  : assert(builder != null),
        assert(enableFeedback != null),
        assert(excludeFromSemantics != null),
        assert(autofocus != null),
        assert(canRequestFocus != null),
        super(key: key);

  final TapWidgetBuilder builder;
  final VoidCallback onTap;

  /// The cursor for a mouse pointer when it enters or is hovering over the
  /// widget.
  ///
  /// If [mouseCursor] is a [MaterialStateProperty<MouseCursor>],
  /// [MaterialStateProperty.resolve] is used for the following [MaterialState]s:
  ///
  ///  * [MaterialState.hovered].
  ///  * [MaterialState.focused].
  ///  * [MaterialState.disabled].
  ///
  /// If this property is null, [MaterialStateMouseCursor.clickable] will be used.
  final MouseCursor mouseCursor;

  /// Whether detected gestures should provide acoustic and/or haptic feedback.
  ///
  /// For example, on Android a tap will produce a clicking sound and a
  /// long-press will produce a short vibration, when feedback is enabled.
  ///
  /// See also:
  ///
  ///  * [Feedback] for providing platform-specific feedback to certain actions.
  final bool enableFeedback;

  /// Whether to exclude the gestures introduced by this widget from the
  /// semantics tree.
  ///
  /// For example, a long-press gesture for showing a tooltip is usually
  /// excluded because the tooltip itself is included in the semantics
  /// tree directly and so having a gesture to show it would result in
  /// duplication of information.
  final bool excludeFromSemantics;

  /// Handler called when the focus changes.
  ///
  /// Called with true if this widget's node gains focus, and false if it loses
  /// focus.
  final ValueChanged<bool> onFocusChange;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode focusNode;

  /// {@macro flutter.widgets.Focus.canRequestFocus}
  final bool canRequestFocus;

  @override
  _TapBuilderState createState() => _TapBuilderState();
}

class _TapBuilderState extends State<TapBuilder> {
  TapState _tapState = TapState.inactive;
  bool _hovering = false;
  bool _hasFocus = false;
  bool _isPressed = false;

  bool get enabled => widget.onTap != null;

  void _updateTapState() {
    final newState = TapStates.fromBooleans(
      isEnabled: enabled,
      isPressed: _isPressed,
      isFocused: _hasFocus,
      isHovered: _hovering,
    );

    if (newState != _tapState) {
      setState(() {
        _tapState = newState;
      });
    }
  }

  void _handleMouseEnter(PointerEnterEvent event) {
    _hovering = true;
    _updateTapState();
  }

  void _handleMouseExit(PointerExitEvent event) {
    _hovering = false;
    _updateTapState();
  }

  void _handleFocusUpdate(bool hasFocus) {
    _hasFocus = hasFocus;
    _updateTapState();
  }

  void _handleTapDown(TapDownDetails details) {
    _isPressed = true;
    _updateTapState();
  }

  void _handleTapCancel() {
    _isPressed = false;
    _updateTapState();
  }

  void _handleTap() {
    _isPressed = false;
    _updateTapState();
    if (widget.onTap != null) {
      if (widget.enableFeedback) Feedback.forTap(context);
      widget.onTap.call();
    }
  }

  bool get _canRequestFocus {
    final mode = MediaQuery.of(context, nullOk: true)?.navigationMode ??
        NavigationMode.traditional;
    switch (mode) {
      case NavigationMode.traditional:
        return enabled && widget.canRequestFocus;
      case NavigationMode.directional:
        return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveMouseCursor = MaterialStateProperty.resolveAs<MouseCursor>(
      widget.mouseCursor ?? MaterialStateMouseCursor.clickable,
      <MaterialState>{
        if (!enabled) MaterialState.disabled,
        if (_hovering && enabled) MaterialState.hovered,
        if (_hasFocus) MaterialState.focused,
      },
    );

    return Focus(
      focusNode: widget.focusNode,
      canRequestFocus: _canRequestFocus,
      onFocusChange: _handleFocusUpdate,
      autofocus: widget.autofocus,
      child: MouseRegion(
        cursor: effectiveMouseCursor,
        onEnter: _handleMouseEnter,
        onExit: _handleMouseExit,
        child: Semantics(
          onTap: widget.excludeFromSemantics || widget.onTap == null
              ? null
              : _handleTap,
          child: GestureDetector(
            onTapDown: enabled ? _handleTapDown : null,
            onTap: enabled ? _handleTap : null,
            onTapCancel: enabled ? _handleTapCancel : null,
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            child: widget.builder(context, _tapState),
          ),
        ),
      ),
    );
  }
}
