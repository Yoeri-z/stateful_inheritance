import 'package:examples/counter.dart';
import 'package:flutter/material.dart';
import 'package:stateful_inheritance/inherited_state.dart';

void main(List<String> args) {
  runApp(DoubleCounterApp());
}

class DoubleCounterApp extends StatelessWidget {
  const DoubleCounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: CounterProvider(child: CounterPage()));
  }
}

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
    final state = CounterProvider.observeState(context, CounterState.firstKey);
    return Text('Value of counter 1 is: ${state.firstCount}');
  }
}

class Counter2 extends StatelessWidget {
  const Counter2({super.key});

  @override
  Widget build(BuildContext context) {
    //This widget will now only rebuild when the second counter changes
    final state = CounterProvider.observeState(context, CounterState.secondKey);
    return Text('Value of counter 2 is: ${state.secondCount}');
  }
}
