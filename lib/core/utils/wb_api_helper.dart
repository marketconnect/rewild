class WbApiHelper {
  static DateTime? getCampaignsLastReq;
  static DateTime? setCpmLastReq;
  static DateTime? getCampaignInfoLastReq;
  static DateTime? getCompanyBudgetLastReq;
  static DateTime? pauseCampaignLastReq;
  static DateTime? startCampaignLastReq;
  static DateTime? getBalanceLastReq;
  // General =========================================================== General
  // Изменение ставки у кампании
  static ApiConstants setCpm = ApiConstants(
    url: '/adv/v0/cpm',
    requestLimitPerMinute: 300, // 300 per minute
    statusCodeDescriptions: {
      400: 'Некорректное значение параметра param',
      401: 'Пустой авторизационный заголовок',
      422: 'Ошибка обработки тела запроса'
    },
  );

  // Пауза кампании
  static ApiConstants pauseCampaign = ApiConstants(
    url: '/adv/v0/pause',
    requestLimitPerMinute: 300, // 300 per minute
    statusCodeDescriptions: {
      400: 'Некорректный идентификатор РК',
      401: 'Пустой авторизационный заголовок',
    },
  );

  // Запуск кампании
  static ApiConstants startCampaign = ApiConstants(
    url: '/adv/v0/start',
    requestLimitPerMinute: 300, // 300 per minute
    statusCodeDescriptions: {
      400: 'Некорректный идентификатор РК',
      401: 'Пустой авторизационный заголовок',
    },
  );

  // Бюджет кампании
  static ApiConstants getCompanyBudget = ApiConstants(
    url: '/adv/v1/budget',
    requestLimitPerMinute: 240, // 240 per minute
    statusCodeDescriptions: {
      400: 'кампания не принадлежит продавцу',
      401: 'Пустой авторизационный заголовок',
      429: 'Превышен лимит запросов в минуту',
    },
  );

  // Списки кампаний
  static ApiConstants getCampaigns = ApiConstants(
    url: '/adv/v1/promotion/count',
    requestLimitPerMinute: 300, // 300 per minute
    statusCodeDescriptions: {
      401: 'Пустой авторизационный заголовок',
    },
  );

  // Информация о кампаниях
  static ApiConstants getCampaignsInfo = ApiConstants(
    url: '/adv/v1/promotion/adverts',
    requestLimitPerMinute: 300, // 300 per minute
    statusCodeDescriptions: {
      400: 'Некорректное значение параметра type',
      401: 'Пустой авторизационный заголовок',
      422: 'Ошибка обработки параметров запроса',
    },
  );

  // Информация о кампании
  static ApiConstants getCampaignInfo = ApiConstants(
    url: '/adv/v0/advert',
    requestLimitPerMinute: 300, // 300 per minute
    statusCodeDescriptions: {
      204: 'Кампания не найдена',
      400: 'Некорректный идентификатор РК',
      401: 'Пустой авторизационный заголовок',
      429: 'Превышен лимит запросов в минуту',
    },
  );

  // Баланс
  static ApiConstants getBalance = ApiConstants(
    url: '/adv/v1/balance',
    requestLimitPerMinute: 60, // 60 per minute
    statusCodeDescriptions: {
      400: 'Некорректный идентификатор продавца',
      401: 'Пустой авторизационный заголовок',
    },
  );

  // Полная статистика кампании
  static ApiConstants getFullStat = ApiConstants(
    url: '/adv/v1/fullstat',
    requestLimitPerMinute: 10, // 10 per minute
    statusCodeDescriptions: {
      400: 'Кампания не найдена',
      401: 'Пустой авторизационный заголовок',
      429: 'Превышен лимит запросов в минуту',
    },
  );

  // Auto ================================================================= Auto
  // Статистика автоматической кампании
  static ApiConstants autoGetStat = ApiConstants(
    url: '/adv/v1/auto/stat',
    requestLimitPerMinute: 10, // 10 per minute
    statusCodeDescriptions: {
      400: 'Кампания не найдена',
      401: 'Пустой авторизационный заголовок',
      429: 'Превышен лимит запросов в минуту',
    },
  );

  // Статистика автоматической кампании по ключевым фразам
  static ApiConstants autoGetStatsWords = ApiConstants(
    url: '/adv/v1/auto/stat-words',
    requestLimitPerMinute: 10, // 10 per minute
    statusCodeDescriptions: {
      401: 'Пустой авторизационный заголовок',
      429: 'Превышен лимит запросов в минуту',
    },
  );

  // Search ============================================================= Search
  // Статистика поисковой кампании по ключевым фразам
  static ApiConstants searchGetStatsWords = ApiConstants(
    url: '/adv/v1/stat/words',
    requestLimitPerMinute: 240, // 240 per minute
    statusCodeDescriptions: {
      401: 'Пустой авторизационный заголовок',
      429: 'Превышен лимит запросов в минуту',
    },
  );

  // Установка/удаление минус-фраз из поиска для кампании в поиске
  static ApiConstants searchSetExcludedKeywords = ApiConstants(
    url: '/adv/v1/search/set-excluded',
    requestLimitPerMinute: 60, // unknown TODO
    statusCodeDescriptions: {
      400: 'Некорректный запрос',
      401: 'Пустой авторизационный заголовок'
    },
  );

  // Установка/удаление минус-фраз фразового соответствия для кампании в поиске
  static ApiConstants searchSetPhraseKeywords = ApiConstants(
    url: '/adv/v1/search/set-phrase',
    requestLimitPerMinute: 60, // unknown TODO
    statusCodeDescriptions: {
      400: 'Некорректный запрос',
      401: 'Пустой авторизационный заголовок'
    },
  );

  // Установка/удаление минус-фраз точного соответствия для кампании в поиске
  static ApiConstants searchSetStrongKeywords = ApiConstants(
    url: '/adv/v1/search/set-strong',
    requestLimitPerMinute: 60, // unknown TODO
    statusCodeDescriptions: {
      400: 'Некорректный запрос',
      401: 'Пустой авторизационный заголовок'
    },
  );

  // Установка/удаление фиксированных фраз у кампании в поиске
  static ApiConstants searchSetPlusKeywords = ApiConstants(
    url: '/adv/v1/search/set-plus',
    requestLimitPerMinute: 120, // 2 per second
    statusCodeDescriptions: {
      400: 'Некорректный запрос',
    },
  );

  // Установка/удаление минус-фраз для автоматической кампаний
  static ApiConstants autoSetExcludedKeywords = ApiConstants(
    url: '/adv/v1/auto/set-excluded',
    requestLimitPerMinute: 10, // 10 per min
    statusCodeDescriptions: {
      400: 'Некорректный запрос',
      401: 'Пустой авторизационный заголовок',
      429: 'Превышен лимит запросов в минуту',
    },
  );
}

class ApiConstants {
  final String _url;
  DateTime? lastReq;

  Map<String, String> headers(String token) => {
        'Authorization': token,
        'Content-Type': 'application/json',
      };

  final int requestLimitPerMinute;

  final Map<int, String> statusCodeDescriptions;

  ApiConstants(
      {required String url,
      required this.requestLimitPerMinute,
      required this.statusCodeDescriptions})
      : _url = url;

  Uri buildUri(Map<String, String> params) {
    return Uri.https('advert-api.wb.ru', _url, params);
  }

  String errResponse({
    required int statusCode,
  }) {
    return statusCodeDescriptions[statusCode] ??
        "Unknown error. Status code: $statusCode";
  }

  Future<void> waitForNextRequest() async {
    final now = DateTime.now();
    if (lastReq != null) {
      final elapsedMilliseconds = now.difference(lastReq!).inMilliseconds;
      final timeToWait =
          (60 * 1000 / requestLimitPerMinute).round() - elapsedMilliseconds;

      if (timeToWait > 0) {
        await Future.delayed(Duration(milliseconds: timeToWait));
      }
    }

    lastReq = DateTime.now();
  }
}
