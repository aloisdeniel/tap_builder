part of 'tap_builder.dart';

typedef AnimatedTapWidgetBuilder = Widget Function(
  BuildContext context,
  TapState state,
  bool isFocused,
  Offset localCursorPosition,
  Alignment cursorAlignment,
);

class AnimatedTapBuilder extends _TapBuilderWidget {
  const AnimatedTapBuilder({
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
        );

  final AnimatedTapWidgetBuilder builder;

  @override
  _AnimatedTapBuilderState createState() => _AnimatedTapBuilderState();
}

class _AnimatedTapBuilderState
    extends _TapBuilderBaseState<AnimatedTapBuilder> {
  Offset _localCursorPosition = Offset.zero;
  Alignment _cursorAlignment = Alignment.center;

  void _updateCursorPosition(Offset newLocalCursorPosition) {
    if (newLocalCursorPosition != _localCursorPosition) {
      setState(() {
        _localCursorPosition = newLocalCursorPosition;
        _updateCursorAlignment();
      });
    }
  }

  void _updateCursorAlignment() {
    final size = context.size;
    if (size != null) {
      final ax = _localCursorPosition.dx / size.width;
      final ay = _localCursorPosition.dy / size.height;
      _cursorAlignment = Alignment(
        ((ax - 0.5) * 2).clamp(-1.0, 1.0),
        ((ay - 0.5) * 2).clamp(-1.0, 1.0),
      );
    }
  }

  void _handlePanUpdate(DragUpdateDetails event) {
    _updateCursorPosition(event.localPosition);
  }

  void _handlePanDown(DragDownDetails details) {
    super.handleTapDown(TapDownDetails());
    _localCursorPosition = details.localPosition;
    _updateCursorAlignment();
  }

  void _handlePanUp(DragEndDetails details) {
    setState(() {
      super._isPressed = false;
    });
  }

  @override
  void handleMouseEnter(PointerEnterEvent event) {
    super.handleMouseEnter(event);
    _localCursorPosition = event.localPosition;
    _updateCursorAlignment();
  }

  void _handleMouseHover(PointerHoverEvent event) {
    _updateCursorPosition(event.localPosition);
  }

  @override
  Widget buildGestureManager(
      BuildContext context, Widget child, MouseCursor cursor) {
    return MouseRegion(
      cursor: cursor,
      onEnter: handleMouseEnter,
      onHover: _handleMouseHover,
      onExit: handleMouseExit,
      child: GestureDetector(
        onPanEnd: enabled ? _handlePanUp : null,
        onPanDown: enabled ? _handlePanDown : null,
        onPanUpdate: enabled ? _handlePanUpdate : null,
        onTap: widget.onTap != null ? handleTap : null,
        onPanCancel: enabled ? handleTapCancel : null,
        onLongPress: widget.onLongPress != null ? handleLongpress : null,
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        child: child,
      ),
    );
  }

  @override
  Widget buildChild(BuildContext context) {
    return widget.builder(
      context,
      state,
      isFocused,
      _localCursorPosition,
      _cursorAlignment,
    );
  }
}
