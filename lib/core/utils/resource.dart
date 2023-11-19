import 'package:flutter/material.dart';

sealed class Resource<T> {
  final T? data;
  final String? message;
  final String? info;
  final String? error;
  final String? stackTrace;
  Resource(
      {required this.data,
      required this.message,
      this.info,
      this.error,
      this.stackTrace});

  factory Resource.success(T data) {
    return Success<T>(data: data);
  }

  factory Resource.empty() {
    return Empty<T>();
  }

  factory Resource.error(String message,
      [T? data, String? info, String? error, String? stackTrace]) {
    debugPrint("Error from rewsource: $message");
    return Error<T>(
        message: message,
        data: data,
        info: info,
        error: error,
        stackTrace: stackTrace);
  }
}

class Success<T> extends Resource<T> {
  Success({required T data})
      : super(
            data: data,
            message: null,
            info: null,
            error: null,
            stackTrace: null);
}

class Empty<T> extends Resource<T> {
  Empty()
      : super(
            data: null,
            message: null,
            info: null,
            error: null,
            stackTrace: null);
}

class Error<T> extends Resource<T> {
  Error(
      {required String super.message,
      super.data,
      required super.info,
      required super.error,
      required super.stackTrace});
}
