import 'package:rewild/core/utils/api/api_constants.dart';

class WbAdvertApiHelper {
  static const String host = 'advert-api.wb.ru';
  // General =========================================================== General
  // Изменение ставки у кампании
  static ApiConstants setCpm = ApiConstants(
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
  static ApiConstants pauseCampaign = ApiConstants(
    host: host,
    url: '/adv/v0/pause',
    requestLimitPerMinute: 300, // 300 per minute
    statusCodeDescriptions: {
      400: 'Некорректный идентификатор РК',
      401: 'Пустой авторизационный заголовок',
    },
  );

  // Запуск кампании
  static ApiConstants startCampaign = ApiConstants(
    host: host,
    url: '/adv/v0/start',
    requestLimitPerMinute: 300, // 300 per minute
    statusCodeDescriptions: {
      400: 'Некорректный идентификатор РК',
      401: 'Пустой авторизационный заголовок',
    },
  );

  // Бюджет кампании
  static ApiConstants getCompanyBudget = ApiConstants(
    host: host,
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
    host: host,
    url: '/adv/v1/promotion/count',
    requestLimitPerMinute: 300, // 300 per minute
    statusCodeDescriptions: {
      401: 'Пустой авторизационный заголовок',
    },
  );

  // Информация о кампаниях
  static ApiConstants getCampaignsInfo = ApiConstants(
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
  static ApiConstants getCampaignInfo = ApiConstants(
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
  static ApiConstants getBalance = ApiConstants(
    host: host,
    url: '/adv/v1/balance',
    requestLimitPerMinute: 60, // 60 per minute
    statusCodeDescriptions: {
      400: 'Некорректный идентификатор продавца',
      401: 'Пустой авторизационный заголовок',
    },
  );

  // Полная статистика кампании
  static ApiConstants getFullStat = ApiConstants(
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
  static ApiConstants autoGetStat = ApiConstants(
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
  static ApiConstants autoGetStatsWords = ApiConstants(
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
  static ApiConstants searchGetStatsWords = ApiConstants(
    host: host,
    url: '/adv/v1/stat/words',
    requestLimitPerMinute: 240, // 240 per minute
    statusCodeDescriptions: {
      401: 'Пустой авторизационный заголовок',
      429: 'Превышен лимит запросов в минуту',
    },
  );

  // Установка/удаление минус-фраз из поиска для кампании в поиске
  static ApiConstants searchSetExcludedKeywords = ApiConstants(
    host: host,
    url: '/adv/v1/search/set-excluded',
    requestLimitPerMinute: 60, // unknown TODO
    statusCodeDescriptions: {
      400: 'Некорректный запрос',
      401: 'Пустой авторизационный заголовок'
    },
  );

  // Установка/удаление минус-фраз фразового соответствия для кампании в поиске
  static ApiConstants searchSetPhraseKeywords = ApiConstants(
    host: host,
    url: '/adv/v1/search/set-phrase',
    requestLimitPerMinute: 60, // unknown TODO
    statusCodeDescriptions: {
      400: 'Некорректный запрос',
      401: 'Пустой авторизационный заголовок'
    },
  );

  // Установка/удаление минус-фраз точного соответствия для кампании в поиске
  static ApiConstants searchSetStrongKeywords = ApiConstants(
    host: host,
    url: '/adv/v1/search/set-strong',
    requestLimitPerMinute: 60, // unknown TODO
    statusCodeDescriptions: {
      400: 'Некорректный запрос',
      401: 'Пустой авторизационный заголовок'
    },
  );

  // Установка/удаление фиксированных фраз у кампании в поиске
  static ApiConstants searchSetPlusKeywords = ApiConstants(
    host: host,
    url: '/adv/v1/search/set-plus',
    requestLimitPerMinute: 120, // 2 per second
    statusCodeDescriptions: {
      400: 'Некорректный запрос',
    },
  );

  // Установка/удаление минус-фраз для автоматической кампаний
  static ApiConstants autoSetExcludedKeywords = ApiConstants(
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
