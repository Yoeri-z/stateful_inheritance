import 'package:flutter/material.dart';
import 'package:inherited_state/inherited_state.dart';

class Counter extends StatefulInheritedWidget {
  const Counter({super.key, required super.child});

  @override
  createState() => CounterState();

  //Still behaves like a regular inherited widget
  static Counter of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Counter>()!;
  }

  static CounterState state(BuildContext context) {
    return context.getInheritedStateOf<Counter>()! as CounterState;
  }

  static CounterState observeState(BuildContext context) {
    return context.observeInheritedStateOf<Counter>()! as CounterState;
  }
}

class CounterState extends InheritedState<Counter> {
  int count = 0;

  void increment() {
    count++;
    setState();
  }

  void reset() {
    count = 0;
    setState();
  }

  //called when the state is attached to the widget tree
  @override
  void initState() {
    super.initState();
  }

  //called when the state [widget] is updated
  @override
  void didUpdateWidget() {}

  @override
  //called when the state is being disposed of.
  void dispose() {
    super.dispose();
  }
}

void main(List<String> args) {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Counter(child: CounterPage()));
  }
}

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Counter.observeState(context);

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
