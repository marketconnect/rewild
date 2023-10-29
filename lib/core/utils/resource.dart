sealed class Resource<T> {
  final T? data;
  final String? message;
  Resource({required this.data, required this.message});

  factory Resource.success(T data) {
    return Success<T>(data: data);
  }

  factory Resource.empty() {
    return Empty<T>();
  }

  factory Resource.error(String message, [T? data]) {
    return Error<T>(message: message, data: data);
  }
}

class Success<T> extends Resource<T> {
  Success({required T data}) : super(data: data, message: null);
}

class Empty<T> extends Resource<T> {
  Empty() : super(data: null, message: null);
}

class Error<T> extends Resource<T> {
  Error({required String super.message, super.data});
}
