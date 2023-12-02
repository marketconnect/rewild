import 'package:flutter/material.dart';

sealed class Resource<T> {
  final T? data;
  final List<dynamic>? args;
  final String? message;
  final String? source;
  final String? error;
  final String? stackTrace;
  Resource(
      {required this.data,
      required this.message,
      this.args,
      this.source,
      this.error,
      this.stackTrace});

  factory Resource.success(T data) {
    return Success<T>(data: data);
  }

  factory Resource.empty() {
    return Empty<T>();
  }

  factory Resource.error(String message,
      {T? data,
      List<dynamic>? args,
      required String? name,
      required String? source,
      String? error,
      String? stackTrace}) {
    final fullName = '$source - $name';
    final prefix = '[$fullName - ERROR]:';

    final text = "$prefix${error ?? message}";
    String argsStr = "";
    if (args != null) {
      for (var arg in args) {
        argsStr = '$argsStr $arg';
      }
    }

    debugPrint(
        '\x1B[31m$text\x1B[0m\x1B[33m$argsStr\x1B[0m stackTrace: \x1B[31m$stackTrace\x1B[0m\x1B[33m');

    return Error<T>(
        message: message,
        data: data,
        args: args,
        error: error,
        stackTrace: stackTrace);
  }
}

class Success<T> extends Resource<T> {
  Success({required T data})
      : super(
            data: data,
            message: null,
            source: null,
            error: null,
            stackTrace: null);
}

class Empty<T> extends Resource<T> {
  Empty()
      : super(
            data: null,
            message: null,
            source: null,
            error: null,
            stackTrace: null);
}

class Error<T> extends Resource<T> {
  Error(
      {required String super.message,
      super.data,
      super.args,
      super.error,
      super.stackTrace});
}
