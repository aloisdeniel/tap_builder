part of 'tap_builder.dart';

typedef TapMouseCursorBuilder = MouseCursor Function(
  BuildContext context,
  TapState state,
  bool isFocused,
);

abstract class _TapBuilderWidget extends StatefulWidget {
  const _TapBuilderWidget({
    Key? key,
    required this.onTap,
    required this.onLongPress,
    required this.mouseCursorBuilder,
    required this.enableFeedback,
    required this.excludeFromSemantics,
    required this.focusNode,
    required this.canRequestFocus,
    required this.onFocusChange,
    required this.autofocus,
    required this.onKey,
    required this.onKeyEvent,
    this.hitTestBehavior = HitTestBehavior.opaque,
    this.minPressedDuration,
  }) : super(key: key);

  final VoidCallback? onTap;

  final VoidCallback? onLongPress;

  /// The cursor for a mouse pointer when it enters or is hovering over the
  /// widget.
  final TapMouseCursorBuilder mouseCursorBuilder;

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
  final ValueChanged<bool>? onFocusChange;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.canRequestFocus}
  final bool canRequestFocus;

  /// {@macro flutter.widgets.Focus.onKey}
  final FocusOnKeyCallback? onKey;

  /// {@macro flutter.widgets.Focus.onKeyEvent}
  final FocusOnKeyEventCallback? onKeyEvent;

  /// {@macro flutter.widgets.GestureDetector.hitTestBehavior}
  final HitTestBehavior hitTestBehavior;

  /// The minimal duration during which the builder will remain in the
  /// [TapState.pressed].
  ///
  /// This can be useful to make sure an animation is fully played before
  /// coming back to its inactive state.
  ///
  /// If `null`, then the button comes back to the inactive state right after
  /// the builder is released.
  final Duration? minPressedDuration;
}

abstract class _TapBuilderBaseState<T extends _TapBuilderWidget>
    extends State<T> {
  bool _isFocused = false;
  bool _isHovered = false;
  bool _isPressed = false;
  bool _showFocus = true;
  int _pressCount = 0;

  @override
  void initState() {
    super.initState();
    FocusManager.instance
        .addHighlightModeListener(handleFocusHighlightModeChange);
  }

  @override
  void dispose() {
    FocusManager.instance
        .removeHighlightModeListener(handleFocusHighlightModeChange);
    super.dispose();
  }

  bool get isFocused => _showFocus && _isFocused;

  TapState get state {
    if (widget.onTap == null) {
      return TapState.disabled;
    }
    if (_isPressed) {
      return TapState.pressed;
    }
    if (_isHovered) {
      return TapState.hover;
    }
    return TapState.inactive;
  }

  late final Map<Type, Action<Intent>> _actionMap = <Type, Action<Intent>>{
    ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: simulateTap),
    ButtonActivateIntent:
        CallbackAction<ButtonActivateIntent>(onInvoke: simulateTap),
  };

  void simulateTap([Intent? intent]) {
    widget.onTap?.call();
    if (widget.enableFeedback) Feedback.forTap(context);
  }

  void handleFocusHighlightModeChange(FocusHighlightMode mode) {
    if (!mounted) {
      return;
    }
    setState(() {
      switch (FocusManager.instance.highlightMode) {
        case FocusHighlightMode.touch:
          _showFocus = false;
          break;
        case FocusHighlightMode.traditional:
          _showFocus = _shouldShowFocus;
          break;
      }
    });
  }

  bool get _shouldShowFocus {
    final mode = MediaQuery.maybeOf(context)?.navigationMode ??
        NavigationMode.traditional;
    switch (mode) {
      case NavigationMode.traditional:
        return enabled && _isFocused;
      case NavigationMode.directional:
        return _isFocused;
    }
  }

  void handleFocusUpdate(bool hasFocus) {
    setState(() {
      _isFocused = hasFocus;
    });
  }

  void handleTapDown(TapDownDetails details) {
    press();
  }

  void handleTapCancel() {
    unpress();
  }

  void handleTap() {
    simulateTap();
    unpress();
  }

  void handleLongpress() {
    final onLongPress = widget.onLongPress;
    if (onLongPress != null) {
      onLongPress();
      if (widget.enableFeedback) Feedback.forLongPress(context);
    }
    unpress();
  }

  /// Set [_isPressed] to `true`.
  void press() {
    if (!_isPressed) {
      _pressCount++;
      setState(() {
        _isPressed = true;
      });
    }
  }

  /// Set [_isPressed] to `false`.
  void unpress() {
    if (_isPressed) {
      final duration = widget.minPressedDuration;
      if (duration != null) {
        unpressAfterDelay(_pressCount, duration);
      } else {
        setState(() {
          _isPressed = false;
        });
      }
    }
  }

  Future<void> unpressAfterDelay(
    int initialPressCount,
    Duration duration,
  ) async {
    await Future.delayed(duration);
    // If press count is different from the initial one, then the button has
    // been pressed again in between and we shouldn't unpress it.
    if (_isPressed && _pressCount == initialPressCount) {
      setState(() {
        _isPressed = false;
      });
    }
  }

  bool isWidgetEnabled(_TapBuilderWidget widget) {
    return widget.onTap != null || widget.onLongPress != null;
  }

  bool get enabled => isWidgetEnabled(widget);

  void handleMouseEnter(PointerEnterEvent event) {
    if (!_isHovered) {
      setState(() {
        _isHovered = true;
      });
    }
  }

  void handleMouseExit(PointerExitEvent event) {
    if (_isHovered) {
      setState(() {
        _isHovered = false;
      });
    }
  }

  bool get canRequestFocus {
    final NavigationMode mode = MediaQuery.maybeOf(context)?.navigationMode ??
        NavigationMode.traditional;
    switch (mode) {
      case NavigationMode.traditional:
        return enabled && widget.canRequestFocus;
      case NavigationMode.directional:
        return true;
    }
  }

  Widget buildChild(BuildContext context);

  Widget buildGestureManager(
      BuildContext context, Widget child, MouseCursor cursor) {
    return MouseRegion(
      cursor: cursor,
      onEnter: handleMouseEnter,
      onExit: handleMouseExit,
      child: GestureDetector(
        onTapDown: enabled ? handleTapDown : null,
        onTap: widget.onTap != null ? handleTap : null,
        onLongPress: widget.onLongPress != null ? handleLongpress : null,
        onTapCancel: enabled ? handleTapCancel : null,
        behavior: widget.hitTestBehavior,
        excludeFromSemantics: true,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = this.state;
    final effectiveMouseCursor = widget.mouseCursorBuilder.call(
      context,
      state,
      isFocused,
    );
    return Actions(
      actions: _actionMap,
      child: Focus(
        focusNode: widget.focusNode,
        canRequestFocus: canRequestFocus,
        onFocusChange: handleFocusUpdate,
        autofocus: widget.autofocus,
        onKey: widget.onKey,
        onKeyEvent: widget.onKeyEvent,
        child: Semantics(
          onTap: widget.excludeFromSemantics || widget.onTap == null
              ? null
              : simulateTap,
          child: buildGestureManager(
            context,
            buildChild(context),
            effectiveMouseCursor,
          ),
        ),
      ),
    );
  }
}
