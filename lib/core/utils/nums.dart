import 'package:fixnum/fixnum.dart';

Int64 stringToInt64(String stringValue) {
  try {
    if (stringValue.isEmpty) {
      return Int64(0);
    }
    final intValue = int.tryParse(stringValue);
    final int64Value = Int64(intValue!);
    return int64Value;
  } catch (e) {
    return Int64(0);
  }
}
