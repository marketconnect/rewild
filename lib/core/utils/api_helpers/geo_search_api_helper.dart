import 'package:rewild/core/utils/api_helpers/api_helper.dart';

class GeoSearchApiHelper {
  static const String _host = 'search.wb.ru';
  static const String _path = '/exactmatch/ru/male/v4/search';

  static ApiHelper search = ApiHelper(
    host: _host,
    url: _path,
    requestLimitPerMinute: 60, // Example limit
    statusCodeDescriptions: {
      400: 'Некорректный запрос',
      401: 'Пустой авторизационный заголовок',
    },
  );
}
