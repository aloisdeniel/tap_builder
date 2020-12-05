# tap_builder

<p>
  <a href="https://pub.dartlang.org/packages/tap_builder"><img src="https://img.shields.io/pub/v/tap_builder.svg"></a>
  <a href="https://www.buymeacoffee.com/aloisdeniel">
    <img src="https://img.shields.io/badge/$-donate-ff69b4.svg?maxAge=2592000&amp;style=flat">
  </a>
</p>

![screenshot](https://github.com/aloisdeniel/tap_builder/raw/main/doc/tap_builder.gif)

A simple widget for building interactive areas. It is an alternative to the material's `Inkwell` that allow to customize the visual effects.

## Quickstart

```dart
 @override
Widget build(BuildContext context) {
    return TapBuilder(
        onTap: () {},
        builder: (context, state) => AnimatedContainer(
            padding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 20,
            ),
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
                color: () {
                    switch (state) {
                        case TapState.disabled:
                            return Colors.grey;
                        case TapState.focused:
                            return Colors.lightBlue;
                        case TapState.hover:
                            return Colors.blue;
                        case TapState.inactive:
                            return Colors.amberAccent;
                        case TapState.pressed:
                            return Colors.red;
                    }
                }(),
            ),
            child: Text('Button'),
        ),
    );
}
```

## Example

[See the full example](https://github.com/aloisdeniel/tap_builder/blob/main/example/lib/main.dart)