import 'package:flutter/material.dart';
import 'package:tap_builder/tap_builder.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TapBuilder'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: StateButton(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: AnimatedStateButton(),
          ),
        ],
      ),
    );
  }
}

class StateButton extends StatelessWidget {
  const StateButton({
    Key key,
  }) : super(key: key);

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
          borderRadius: BorderRadius.circular(5),
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
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.button.copyWith(
                fontWeight: state == TapState.pressed
                    ? FontWeight.bold
                    : FontWeight.w400,
              ),
          child: Text(
            'TapBuilder',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class AnimatedStateButton extends StatelessWidget {
  const AnimatedStateButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedTapBuilder(
      onTap: () {},
      builder: (context, state, cursorLocation, cursorAlignment) =>
          AnimatedContainer(
        height: 200,
        transformAlignment: Alignment.center,
        transform: Matrix4.rotationX(-cursorAlignment.y * 0.2)
          ..rotateY(cursorAlignment.x * 0.2),
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
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
        child: ClipRect(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 20,
            ),
            child: Stack(
              children: [
                DefaultTextStyle(
                  style: Theme.of(context).textTheme.button.copyWith(
                        fontWeight: state == TapState.pressed
                            ? FontWeight.bold
                            : FontWeight.w400,
                      ),
                  child: Text(
                    'TapBuilder',
                    textAlign: TextAlign.center,
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment:
                        Alignment(-cursorAlignment.x, -cursorAlignment.y),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.01),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(
                                state == TapState.pressed ? 0.5 : 0.0),
                            blurRadius: 200,
                            spreadRadius: 130,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
