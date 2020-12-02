import 'package:flutter/widgets.dart';

enum TapState {
  disabled,
  inactive,
  focused,
  hover,
  pressed,
}

abstract class TapStates {
  static TapState fromBooleans({
    @required bool isEnabled,
    @required bool isPressed,
    @required bool isHovered,
    @required bool isFocused,
  }) {
    if (!isEnabled) return TapState.disabled;
    if (isPressed) return TapState.pressed;
    if (isHovered) return TapState.hover;
    if (isFocused) return TapState.focused;
    return TapState.inactive;
  }
}
