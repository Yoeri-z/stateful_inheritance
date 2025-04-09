import 'package:flutter/material.dart';
import 'package:inherited_state/inherited_state.dart';

class CounterProvider extends StatefulInheritedWidget {
  const CounterProvider({super.key, required super.child});

  @override
  CounterState createState() => CounterState();

  static CounterState observeState(BuildContext context, String key) {
    return context.observeInheritedStateOf<CounterProvider>(key: key)!
        as CounterState;
  }
}

class CounterState extends InheritedState<CounterProvider> {
  static const firstCounterKey = 'counter1';
  static const secondCounterKey = 'counter2';

  int firstCount = 0;
  int secondCount = 0;

  void incrementFirst() {
    firstCount++;
    setState(affects: [firstCounterKey]);
  }

  void incrementSecond() {
    secondCount++;
    setState(affects: [secondCounterKey]);
  }
}

class Counter1 extends StatelessWidget {
  const Counter1({super.key});

  @override
  Widget build(BuildContext context) {
    final state = CounterProvider.observeState(
      context,
      CounterState.firstCounterKey,
    );
    return Text('Value of counter 1 is: ${state.firstCount}');
  }
}

class Counter2 extends StatelessWidget {
  const Counter2({super.key});

  @override
  Widget build(BuildContext context) {
    final state = CounterProvider.observeState(
      context,
      CounterState.secondCounterKey,
    );
    return Text('Value of counter 2 is: ${state.secondCount}');
  }
}
