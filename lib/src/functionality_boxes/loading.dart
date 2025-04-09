class LoadingBox {
  LoadingBox();

  bool isLoading = false;
}

class ErrorBox {
  ErrorBox();

  Object? error;

  bool get hasError => error != null;
}
