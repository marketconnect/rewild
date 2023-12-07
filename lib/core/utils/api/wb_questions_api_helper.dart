import 'package:rewild/core/utils/api/api_constants.dart';

class WbQuestionsApiHelper {
  static const String host = 'feedbacks-api.wildberries.ru';

  // Получение количества неотвеченных вопросов за сегодня и всё время
  static ApiConstants getUnansweredQuestionsCount = ApiConstants(
    host: host,
    url: '/api/v1/questions/count-unanswered',
    requestLimitPerMinute: 300, // 300 per minute
    statusCodeDescriptions: {
      400: 'Ошибка переданных параметров',
      401: 'Не авторизован',
    },
  );

  // Информация о наличии непросмотренных отзывов и вопросов
  static ApiConstants getNewFeedbacksQuestions = ApiConstants(
    host: host,
    url: '/api/v1/new-feedbacks-questions',
    requestLimitPerMinute: 300, // 300 per minute
    statusCodeDescriptions: {
      401: 'Не авторизован',
      403: 'Ошибка авторизации',
    },
  );

  // Получение товаров, про которые чаще всего спрашивают
  static ApiConstants getFrequentlyAskedProducts = ApiConstants(
    host: host,
    url: '/api/v1/questions/products/rating',
    requestLimitPerMinute: 240, // 240 per minute
    statusCodeDescriptions: {
      400: 'Ошибка переданных параметров',
      401: 'Не авторизован',
      403: 'Ошибка авторизации',
    },
  );

  // Получение списка вопросов
  static ApiConstants getQuestionsList = ApiConstants(
    host: host,
    url: '/api/v1/questions',
    requestLimitPerMinute: 300, // 300 per minute
    statusCodeDescriptions: {
      400: 'Ошибка переданных параметров',
      401: 'Не авторизован',
      403: 'Ошибка авторизации',
    },
  );

  // Работа с вопросами
  static ApiConstants patchQuestions = ApiConstants(
    host: host,
    url: '/api/v1/questions',
    requestLimitPerMinute: 300, // 300 per minute
    statusCodeDescriptions: {
      400: 'Ошибка переданных параметров',
      401: 'Не авторизован',
      403: 'Ошибка авторизации',
      404: 'Ошибка - не найдено',
    },
  );
  // Метод позволяет получить вопрос по его Id.
  static ApiConstants getQuestionById = ApiConstants(
    host: host,
    url: '/api/v1/question',
    requestLimitPerMinute: 60, // unknown
    statusCodeDescriptions: {
      401: 'Не авторизован',
    },
  );
}
