<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

Stateful inheritance is a state management solution that attempts to stay inline with the 'flutter' way of doing things (whatever that means).
Note: This package is more of an experiment than something that should be actually used in an application, it is probably wise to choose a more popular
solution for your projects.

## Features

 - :racing_car: Fast
 - :bulb: familiar if you are used to flutters `InheritedWidget`
 - :fire: Hot reload compatible
 - :hammer_and_wrench: Dev tool compatible
 - :control_knobs: Extreme finegrained control over rebuilds if wanted

## Getting started

Run 

`flutter pub add statefull_inheritance` 

to install the package.

This package is not intended to be used by beginners as it relies heavily on some core flutter concepts,
so I created a list of prerequisisites:

 - [State and statefulwidget](https://api.flutter.dev/flutter/widgets/StatefulWidget-class.html)
 - [Inherited widget](https://api.flutter.dev/flutter/widgets/InheritedWidget-class.html)
 - [Build context](https://api.flutter.dev/flutter/widgets/BuildContext-class.html)
 - [State management](https://docs.flutter.dev/get-started/fundamentals/state-management)

Make sure you are comfortable with, and understand these topics.

## Core concepts
This package attempts to extend on flutters principle of inheritence by adding a new widget called `StatefulInheritedWidget`. Which in essence an `InheritedWidget` with a piece of state attached to it. Kind of like what `StatefulWidget` is to `StatelessWidget`.

Lets create a `StatefulInheritedWidget` for keeping track of the count of a simple integer.
```dart
class CounterProvider extends StatefulInheritedWidget {
  const CounterProvider({super.key, required super.child});

  @override
  createState() => CounterState();
}

class CounterState extends InheritedState<CounterProvider> {
  int count = 0;

  void increment() {
    count++;
    setState();
  }
}
```
In theory this is all we would need, but if you are familiar with InheritedWidget you'll know that it is common to write a static `.of(context)` method. The same principle should be followed with our new `StatefulInheritedWidget`.

```dart
class CounterProvider extends StatefulInheritedWidget {
  const CounterProvider({super.key, required super.child});

  @override
  createState() => CounterState();

  //The StatefulInheritedWidget still has the same functionality
  //as a regular inherited widget
  static CounterProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CounterProvider>()!;
  }
  //The state of a StatefulInheritedWidget can also be retrieved,
  //behaves similarly to [context.getInheritedWidgetOfExactType]
  static CounterState state(BuildContext context) {
    return context.getInheritedStateOf<CounterProvider>()! as CounterState;
  }
  //The state of a StatefulInheritedWidget can also be observed.
  //This will make the widget the context was from rebuild whenever
  //the state changes
  static CounterState observeState(BuildContext context) {
    return context.observeInheritedStateOf<CounterProvider>()! as CounterState;
  }

}

class CounterState extends InheritedState<CounterProvider> {
  int count = 0;

  void increment() {
    count++;
    setState();
  }
}
```

This is all we need to create our counter app.
💡Tip: you can create a VScode snippet for the widget, like the snippet for the stateful widget.

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: CounterProvider(child: CounterPage()));
  }
}

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = CounterProvider.observeState(context);

    return Scaffold(
      appBar: AppBar(title: Text('A counter app')),
      body: Center(child: Text(state.count.toString())),
      floatingActionButton: IconButton(
        onPressed: () => state.increment(),
        onLongPress: () => state.reset(),
        icon: Icon(Icons.add),
      ),
    );
  }
}
```
As you can see the Widget tree is very concise because the `StatefulInheritedWidget` does the heavy lifting. Usually it is good practice to put your StatefulInheritedWidget in a seperate file next to the other widgets like is done in the [flutter compass app example](https://github.com/flutter/samples/tree/main/compass_app)

### properties of InheritedState
Just like a `State`, the `InheritedState` has a few overridable methods to manage its contents over its lifecycle.
```dart
class CounterState extends InheritedState<CounterProvider> {
  //called when the state is attached to the widget tree
  @override
  void initState() {
    super.initState();
  }

  //called when the states [widget] is updated
  @override
  void didUpdateWidget() {}

  //called when the state is being disposed of.
  @override
  void dispose() {
    super.dispose();
  }
}
```
These methods do look like they are inviting mutable objects into the state, but this should be avoided. There are very few cases where having mutable state is more convenient but for the few cases that it is, this package makes handling them easy.

### keys
Keys come in handy when you want to optimize your app. They are a way to control exactly what widget rebuilds with which state change.

It is probably easier to understand if you just see it in action.

```dart
class CounterProvider extends StatefulInheritedWidget {
  const CounterProvider({super.key, required super.child});

  @override
  CounterState createState() => CounterState();

  //pass the key with the observe function
  static CounterState observeState(BuildContext context, String key) {
    return context.observeInheritedStateOf<CounterProvider>(key: key)!
        as CounterState;
  }
}

class CounterState extends InheritedState<CounterProvider> {
  //create your keys, for now keys are string values
  static const firstKey = '1';
  static const secondKey = '2';

  int firstCount = 0;
  int secondCount = 0;

  void incrementFirst() {
    firstCount++;
    //the affects field contains all the keys that this state change
    //should affect
    setState(affects: [firstKey]);
  }

  void incrementSecond() {
    secondCount++;
    //same thing
    setState(affects: [secondKey]);
  }
}

class Counter1 extends StatelessWidget {
  const Counter1({super.key});

  @override
  Widget build(BuildContext context) {
    //This widget will now only rebuild when the first counter changes
    final state = CounterProvider.observeState(
      context,
      CounterState.firstKey,
    );
    return Text('Value of counter 1 is: ${state.firstCount}');
  }
}

class Counter2 extends StatelessWidget {
  const Counter2({super.key});

  @override
  Widget build(BuildContext context) {
    //This widget will now only rebuild when the second counter changes
    final state = CounterProvider.observeState(
      context,
      CounterState.secondKey,
    );
    return Text('Value of counter 2 is: ${state.secondCount}');
  }
}

```

## Mixins(To be implemented)
`InheritedState` can be given a lot of default utility with a couple of utility mixins this package provides for it:
 - AsyncMixin, a mixin for handling async operations. With default operations for loading and error handling.
   Comes with the AsyncConsumer widget to implement it in the ui
 - PersistenceMixin, persist an InheritedStates data (or part of it) over multiple sessions
 - SideEffectMixin, a mixin for creating ui side effect at the level of the StatefulInheritedWidget. Usefull for things like pop-up dialogs and snackbars
 - MultiErrorProducerMixin, a mixin for states that are error prone and can function eventhough errors occur. This mixin provides functionality to store all the errors that occured in the states lifetime


## Style Guide
Here are a few principles that are good to follow when using InheritedState:
- Eventhough InheritedState does have all the functionality needed to allow managing mutable objects,
it is recommended to have all the fields in your state be immutable objects. (Just google 'State immutability flutter' to see many reasons why)
- Dont observe from context directly in the widget, write static methods on your `StatefulInheritedWidget` instead. (As seen in [The core concepts](#core-concepts))
- Usually it is good practice to put your StatefulInheritedWidget in a seperate file next to the other widgets like is done in the [flutter compass app example](https://github.com/flutter/samples/tree/main/compass_app)

