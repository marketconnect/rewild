class APIConstants {
  static const int apiPort = 25891;
  static const String apiHost = "89.108.70.221";
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
