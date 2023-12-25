import 'package:flutter/material.dart';

class RewildError {
  final List<dynamic>? args;
  final String? message;
  final String? source;
  final String? error;
  final String name;
  final String? stackTrace;

  RewildError(this.message,
      {required this.name,
      this.args,
      this.source,
      this.error,
      this.stackTrace}) {
    debugPrint(toString());
  }
  @override
  String toString() {
    return 'RewildError: $message\nSource: $source\nName: $name\nError: $error\nStackTrace: $stackTrace';
  }
}
