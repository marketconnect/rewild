import 'package:rewild/core/utils/api/api_constants.dart';

class WbReviewApiHelper {
  static const String host =
      'feedbacks-api.wildberries.ru'; // Replace with your actual host
  // Add other constants as needed

  // Метод позволяет получить список отзывов по заданным параметрам с пагинацией и сортировкой.
  static ApiConstants getFeedbacks = ApiConstants(
    host: host,
    url: '/api/v1/feedbacks',
    requestLimitPerMinute: 60, // Set the appropriate limit
    statusCodeDescriptions: {
      200: 'Успешно',
      400: 'Ошибка переданных параметров',
      401: 'Не авторизован',
      403: 'Ошибка авторизации',
    },
  );

  // В зависимости от тела запроса можно просмотреть отзыв, ответить на отзыв или отредактировать ответ.
  // Отредактировать ответ на отзыв можно в течение 2 месяцев (60 дней) после предоставления ответа и только 1 раз.
  static ApiConstants patchFeedbacks = ApiConstants(
    host: host,
    url: '/api/v1/feedbacks',
    requestLimitPerMinute: 60, // Set the appropriate limit
    statusCodeDescriptions: {
      200: 'Успешно',
      400: 'Ошибка переданных параметров',
      401: 'Не авторизован',
      403: 'Ошибка авторизации',
      404: 'Ошибка - не найдено',
      422: 'Ошибка - не удалось исправить отзыв',
    },
  );

  // Add other ApiConstants as needed
}
