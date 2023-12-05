class APIConstants {
  static const int apiPort = 25891;
  static const String apiHost = "89.108.70.221";
}

enum ApiKeyType {
  stat,
  promo,
  question,
}

class RegionsNumsConstants {
  static const Map<String, String> regions = {
    "01": "Республика Адыгея",
    "04": "Республика Алтай",
    "02": "Республика Башкортостан",
    "03": "Республика Бурятия",
    "05": "Республика Дагестан",
    "06": "Республика Ингушетия",
    "07": "Кабардино-Балкарская республика",
    "08": "Республика Калмыкия",
    "09": "Карачаево-Черкесская республика",
    "10": "Республика Карелия",
    "11": "Республика Коми",
    "91": "Республика Крым",
    "12": "Республика Марий Эл",
    "13": "Республика Мордовия",
    "14": "Республика Саха (Якутия)",
    "15": "Республика Северная Осетия — Алания",
    "16": "Республика Татарстан",
    "17": "Республика Тыва",
    "18": "Удмуртская республика",
    "19": "Республика Хакасия",
    "20": "Чеченская республика",
    "21": "Чувашская республика",
    "22": "Алтайский край",
    "75": "Забайкальский край",
    "41": "Камчатский край",
    "23": "Краснодарский край",
    "24": "Красноярский край",
    "59": "Пермский край",
    "25": "Приморский край",
    "26": "Ставропольский край",
    "27": "Хабаровский край",
    "28": "Амурская область",
    "29": "Архангельская область",
    "30": "Астраханская область",
    "31": "Белгородская область",
    "32": "Брянская область",
    "33": "Владимирская область",
    "34": "Волгоградская область",
    "35": "Вологодская область",
    "36": "Воронежская область",
    "37": "Ивановская область",
    "38": "Иркутская область",
    "39": "Калининградская область",
    "40": "Калужская область",
    "42": "Кемеровская область",
    "43": "Кировская область",
    "44": "Костромская область",
    "45": "Курганская область",
    "46": "Курская область",
    "47": "Ленинградская область",
    "48": "Липецкая область",
    "49": "Магаданская область",
    "50": "Московская область",
    "51": "Мурманская область",
    "52": "Нижегородская область",
    "53": "Новгородская область",
    "54": "Новосибирская область",
    "55": "Омская область",
    "56": "Оренбургская область",
    "57": "Орловская область",
    "58": "Пензенская область",
    "60": "Псковская область",
    "61": "Ростовская область",
    "62": "Рязанская область",
    "63": "Самарская область",
    "64": "Саратовская область",
    "65": "Сахалинская область",
    "66": "Свердловская область",
    "67": "Смоленская область",
    "68": "Тамбовская область",
    "69": "Тверская область",
    "70": "Томская область",
    "71": "Тульская область",
    "72": "Тюменская область",
    "73": "Ульяновская область",
    "74": "Челябинская область",
    "76": "Ярославская область",
    "77": "Москва",
    "78": "Санкт-Петербург",
    "92": "Севастополь",
    "79": "Еврейская автономная область",
    "83": "Ненецкий автономный округ",
    "86": "Ханты-Мансийский автономный округ - Югра",
    "87": "Чукотский автономный округ",
    "89": "Ямало-Ненецкий автономный округ",
  };
}

class StringConstants {
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

  static const Map<ApiKeyType, String> apiKeyTypes = {
    ApiKeyType.stat: "Статистика",
    ApiKeyType.promo: "Продвижение",
    ApiKeyType.question: "Вопросы/Отз."
  };
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
  static const Map<int, String> advTypes = {
    4: "в каталоге",
    5: "в карточке",
    6: "в поиске",
    7: "на главной странице",
    8: "автокампания",
    9: "поиск + каталог",
  };
  static const Map<int, String> advStatus = {
    -1: "удаление",
    4: "готова к запуску",
    7: "завершена",
    8: "отказался",
    9: "идут показы",
    11: "приостановленно",
  };
}

class NotificationConditionConstants {
  static const int budgetLessThan = 1;
  static const int priceChanged = 2;
  static const int promoChanged = 3;
  static const int nameChanged = 4;
  static const int picsChanged = 5;
  static const int reviewRatingChanged = 6;
  static const int stocksLessThan = 7;
  static const int stocksInWhLessThan = 8;
  static const int sizeStocksLessThan = 9;
  static const int sizeStocksInWhLessThan = 10;
  static const int stocksMoreThan = 11;
}

// WB constants
class AdvertStatusConstants {
  static const int deleted = -1;
  static const int readyToStart = 4;
  static const int finished = 7;
  static const int refused = 8;
  static const int active = 9;
  static const int paused = 11;
}

class AdvertTypeConstants {
  static const int inCatalog = 4;
  static const int inCard = 5;
  static const int inSearch = 6;
  static const int inRecomendation = 7;
  static const int auto = 8;
  static const int searchPlusCatalog = 9;
}

class AdvertTypeNameConstants {
  static const Map<String, int> names = {
    "Автокампания": AdvertTypeConstants.auto,
    "Карточка": AdvertTypeConstants.inCard,
    "Поиск": AdvertTypeConstants.inSearch,
    "Каталог": AdvertTypeConstants.inCatalog,
    "Поиск + каталог": AdvertTypeConstants.searchPlusCatalog,
    "Рекомендации": AdvertTypeConstants.inRecomendation
  };
}
