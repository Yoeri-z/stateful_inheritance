part of 'stateful_inheritance.dart';

//this can be done better
class AsyncConsumer<State extends InheritedState> extends StatelessWidget {
  const AsyncConsumer({
    super.key,
    required this.onLoading,
    required this.onResult,
    required this.onError,
    required this.observe,
  });

  final State Function(BuildContext context) observe;
  final Widget Function(BuildContext context) onLoading;
  final Widget Function(BuildContext context, State state) onResult;
  final Widget Function(BuildContext context, Object error) onError;

  @override
  Widget build(BuildContext context) {
    final state = observe(context);

    assert(
      state._loadingBox != null && state._errorBox != null,
      'Your state must have the Async mixin for this widget to be used'
      'did you perhaps forget to add it?',
    );

    if (state._loadingBox!.isLoading) {
      return onLoading(context);
    }

    if (state._errorBox!.hasError) {
      return onError(context, state._errorBox!.error!);
    }

    return onResult(context, state);
  }
}
