import 'package:rewild/core/utils/api_helpers/api_helper.dart';

class WbAdvertApiHelper {
  static const String host = 'advert-api.wb.ru';
  // General =========================================================== General
  // Изменение ставки у кампании
  static ApiHelper setCpm = ApiHelper(
    host: host,
    url: '/adv/v0/cpm',
    requestLimitPerMinute: 300, // 300 per minute
    statusCodeDescriptions: {
      400: 'Некорректное значение параметра param',
      401: 'Пустой авторизационный заголовок',
      422: 'Ошибка обработки тела запроса'
    },
  );

  // Пауза кампании
  static ApiHelper pauseCampaign = ApiHelper(
    host: host,
    url: '/adv/v0/pause',
    requestLimitPerMinute: 300, // 300 per minute
    statusCodeDescriptions: {
      400: 'Некорректный идентификатор РК',
      401: 'Пустой авторизационный заголовок',
    },
  );

  // Запуск кампании
  static ApiHelper startCampaign = ApiHelper(
    host: host,
    url: '/adv/v0/start',
    requestLimitPerMinute: 300, // 300 per minute
    statusCodeDescriptions: {
      400: 'Некорректный идентификатор РК',
      401: 'Пустой авторизационный заголовок',
    },
  );

  // Бюджет кампании
  static ApiHelper getCompanyBudget = ApiHelper(
    host: host,
    url: '/adv/v1/budget',
    requestLimitPerMinute:
        200, // 240 per minute, but it's not enough in practice
    statusCodeDescriptions: {
      400: 'кампания не принадлежит продавцу',
      401: 'Пустой авторизационный заголовок',
      429: 'Превышен лимит запросов в минуту',
    },
  );

  // Списки кампаний
  static ApiHelper getCampaigns = ApiHelper(
    host: host,
    url: '/adv/v1/promotion/count',
    requestLimitPerMinute: 300, // 300 per minute
    statusCodeDescriptions: {
      401: 'Пустой авторизационный заголовок',
    },
  );

  // Информация о кампаниях
  static ApiHelper getCampaignsInfo = ApiHelper(
    host: host,
    url: '/adv/v1/promotion/adverts',
    requestLimitPerMinute: 300, // 300 per minute
    statusCodeDescriptions: {
      400: 'Некорректное значение параметра type',
      401: 'Пустой авторизационный заголовок',
      422: 'Ошибка обработки параметров запроса',
    },
  );

  // Информация о кампании
  static ApiHelper getCampaignInfo = ApiHelper(
    host: host,
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
  static ApiHelper getBalance = ApiHelper(
    host: host,
    url: '/adv/v1/balance',
    requestLimitPerMinute: 60, // 60 per minute
    statusCodeDescriptions: {
      400: 'Некорректный идентификатор продавца',
      401: 'Пустой авторизационный заголовок',
    },
  );

  // Полная статистика кампании
  static ApiHelper getFullStat = ApiHelper(
    host: host,
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
  static ApiHelper autoGetStat = ApiHelper(
    host: host,
    url: '/adv/v1/auto/stat',
    requestLimitPerMinute: 10, // 10 per minute
    statusCodeDescriptions: {
      400: 'Кампания не найдена',
      401: 'Пустой авторизационный заголовок',
      429: 'Превышен лимит запросов в минуту',
    },
  );

  // Статистика автоматической кампании по ключевым фразам
  static ApiHelper autoGetStatsWords = ApiHelper(
    host: host,
    url: '/adv/v1/auto/stat-words',
    requestLimitPerMinute: 10, // 10 per minute
    statusCodeDescriptions: {
      401: 'Пустой авторизационный заголовок',
      429: 'Превышен лимит запросов в минуту',
    },
  );

  // Search ============================================================= Search
  // Статистика поисковой кампании по ключевым фразам
  static ApiHelper searchGetStatsWords = ApiHelper(
    host: host,
    url: '/adv/v1/stat/words',
    requestLimitPerMinute: 240, // 240 per minute
    statusCodeDescriptions: {
      401: 'Пустой авторизационный заголовок',
      429: 'Превышен лимит запросов в минуту',
    },
  );

  // Установка/удаление минус-фраз из поиска для кампании в поиске
  static ApiHelper searchSetExcludedKeywords = ApiHelper(
    host: host,
    url: '/adv/v1/search/set-excluded',
    requestLimitPerMinute: 60, // unknown TODO
    statusCodeDescriptions: {
      400: 'Некорректный запрос',
      401: 'Пустой авторизационный заголовок'
    },
  );

  // Установка/удаление минус-фраз фразового соответствия для кампании в поиске
  static ApiHelper searchSetPhraseKeywords = ApiHelper(
    host: host,
    url: '/adv/v1/search/set-phrase',
    requestLimitPerMinute: 60, // unknown TODO
    statusCodeDescriptions: {
      400: 'Некорректный запрос',
      401: 'Пустой авторизационный заголовок'
    },
  );

  // Установка/удаление минус-фраз точного соответствия для кампании в поиске
  static ApiHelper searchSetStrongKeywords = ApiHelper(
    host: host,
    url: '/adv/v1/search/set-strong',
    requestLimitPerMinute: 60, // unknown TODO
    statusCodeDescriptions: {
      400: 'Некорректный запрос',
      401: 'Пустой авторизационный заголовок'
    },
  );

  // Установка/удаление фиксированных фраз у кампании в поиске
  static ApiHelper searchSetPlusKeywords = ApiHelper(
    host: host,
    url: '/adv/v1/search/set-plus',
    requestLimitPerMinute: 120, // 2 per second
    statusCodeDescriptions: {
      400: 'Некорректный запрос',
    },
  );

  // Установка/удаление минус-фраз для автоматической кампаний
  static ApiHelper autoSetExcludedKeywords = ApiHelper(
    host: host,
    url: '/adv/v1/auto/set-excluded',
    requestLimitPerMinute: 10, // 10 per min
    statusCodeDescriptions: {
      400: 'Некорректный запрос',
      401: 'Пустой авторизационный заголовок',
      429: 'Превышен лимит запросов в минуту',
    },
  );
}
