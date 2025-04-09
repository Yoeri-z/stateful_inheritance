import 'package:flutter/material.dart';
import 'package:stateful_inheritance/inherited_state.dart';

void main(List<String> args) {
  runApp(CounterApp());
}

class CounterApp extends StatelessWidget {
  const CounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: CounterProvider(child: CounterPage()));
  }
}

class CounterProvider extends StatefulInheritedWidget {
  const CounterProvider({super.key, required super.child});

  @override
  createState() => CounterState();

  //Still behaves like a regular inherited widget
  static CounterProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CounterProvider>()!;
  }

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

  void reset() {
    count = 0;
    setState();
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
