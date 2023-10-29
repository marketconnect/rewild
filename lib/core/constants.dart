class APIConstants {
  static const int apiPort = 25891;
  // static const int apiPort = 20000;
  // static const String apiHost = "192.168.43.109";
  // static const String apiHost = "192.168.31.203";
  static const String apiHost = "89.108.70.221";
}

class TextConstants {
  static const List<String> months = [
    'Январь',
    'Февраль',
    'Март',
    'Апрель',
    'Май',
    'Июнь',
    'Июль',
    'Август',
    'Сентябрь',
    'Октябрь',
    'Ноябрь',
    'Декабрь'
  ];
}

class ErrorsConstants {
  static const String unavailable =
      "Сервер временно недоступен, попробуйте позже.";
}

class TimeConstants {
  static const Duration updatePeriod = Duration(minutes: 1);
}

class NumericConstants {
  static const int supplyThreshold = 10;
}
