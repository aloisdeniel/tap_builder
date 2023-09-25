// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:tap_builder/tap_builder.dart';

/// Associate data to [TapState]s.
///
/// The only required builder is [inactive].
///
/// If the other builders are not provided, they will fallback to the most
/// common use case :
/// * [pressed] will try to fallback to [hover], else to [inactive].
/// * [disabled] will fallback to [inactive].
/// * [hover] will fallback to [pressed], else to [inactive].
class TapResolver<T> {
  const TapResolver({
    required this.inactive,
    this.key,
    this.pressed,
    this.disabled,
    this.hover,
  });

  /// The key will serve as the identifier of the equality.
  ///
  /// If not provided it fallbacks to the default instance behaviour.
  final Object? key;
  final T Function() inactive;
  final T Function()? pressed;
  final T Function()? disabled;
  final T Function()? hover;

  /// Resolve the value associated to the given [state].
  T resolve(TapState state) {
    final inactive = this.inactive;
    final pressed = this.pressed ?? this.hover ?? inactive;
    final disabled = this.disabled ?? inactive;
    final hover = this.hover ?? pressed;
    return switch (state) {
      TapState.inactive => inactive(),
      TapState.pressed => pressed(),
      TapState.hover => hover(),
      TapState.disabled => disabled(),
    };
  }

  @override
  bool operator ==(covariant TapResolver<T> other) {
    if (other.key == null) return identical(this, other);
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    if (key == null) return super.hashCode;
    return key.hashCode;
  }
}
