import 'package:flutter/widgets.dart';

import 'tap_state.dart';

MouseCursor defaultMouseCursorBuilder(
  BuildContext context,
  TapState state,
  bool isFocused,
) {
  switch (state) {
    case TapState.disabled:
      return SystemMouseCursors.forbidden;
    case TapState.pressed:
    case TapState.hover:
      return SystemMouseCursors.click;
    default:
      return SystemMouseCursors.basic;
  }
}
