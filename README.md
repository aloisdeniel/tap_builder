# tap_builder

<p>
  <a href="https://pub.dartlang.org/packages/tap_builder"><img src="https://img.shields.io/pub/v/tap_builder.svg"></a>
  <a href="https://www.buymeacoffee.com/aloisdeniel">
    <img src="https://img.shields.io/badge/$-donate-ff69b4.svg?maxAge=2592000&amp;style=flat">
  </a>
</p>

A simple widget for building interactive areas.

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
    
