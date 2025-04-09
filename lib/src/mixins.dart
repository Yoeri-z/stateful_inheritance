part of 'stateful_inheritance.dart';

mixin Async<T extends StatefulInheritedWidget> on InheritedState<T> {
  @override
  void initState() {
    super.initState();
    _loadingBox = LoadingBox();
    _errorBox = ErrorBox();
  }

  bool get isLoading => _loadingBox!.isLoading;
  bool get hasError => _errorBox!.hasError;

  Object? get error => _errorBox!.error;

  @protected
  void setStateLoading({List<String>? affects, List<String>? excludes}) {
    _loadingBox!.isLoading = true;
    setState(affects: affects, excludes: excludes);
  }

  @protected
  void setStateDone({List<String>? affects, List<String>? excludes}) {
    _loadingBox!.isLoading = false;
    setState(affects: affects, excludes: excludes);
  }

  @protected
  void setStateError(
    Object error, {
    List<String>? affects,
    List<String>? excludes,
  }) {
    _loadingBox!.isLoading = false;
    _errorBox!.error = error;
    setState(affects: affects, excludes: excludes);
  }
}
