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
    print('$source $name $message');
  }
}
