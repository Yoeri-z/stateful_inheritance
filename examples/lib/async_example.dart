import 'package:flutter/material.dart';
import 'package:stateful_inheritance/inherited_state.dart';

void main(List<String> args) {
  runApp(AsyncExampleApp());
}

class AsyncExampleApp extends StatelessWidget {
  const AsyncExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: AsyncProvider(child: AsyncPage()));
  }
}

class AsyncProvider extends StatefulInheritedWidget {
  const AsyncProvider({super.key, required super.child});

  @override
  AsyncState createState() => AsyncState();

  static AsyncState readState(BuildContext context) {
    return context.getInheritedStateOf<AsyncProvider>() as AsyncState;
  }

  static AsyncState observeState(BuildContext context) {
    return context.observeInheritedStateOf<AsyncProvider>() as AsyncState;
  }
}

class AsyncState extends InheritedState<AsyncProvider> with Async {
  int attempt = 0;

  Future<void> doAttempt() async {
    setStateLoading();
    await Future.delayed(Duration(seconds: 2));
    if (attempt < 4) {
      attempt++;
      setStateDone();
      return;
    }
    setStateError(Exception('Error occured after $attempt attempts'));
  }
}

class AsyncPage extends StatelessWidget {
  const AsyncPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Async example')),
      body: Center(
        child: AsyncConsumer(
          observe: AsyncProvider.observeState,
          onLoading: (_) => CircularProgressIndicator(),
          onResult: (_, state) => Text(state.attempt.toString()),
          onError: (_, error) => Text(error.toString()),
        ),
      ),

      floatingActionButton: IconButton(
        onPressed: () => AsyncProvider.readState(context).doAttempt(),
        icon: Icon(Icons.add),
      ),
    );
  }
}
