import 'package:intl/intl.dart';
import 'package:rewild/core/utils/resource.dart';

import 'package:rewild/domain/services/update_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

class LastUpdateDayDataProvider
    implements UpdateServiceLastUpdateDayDataProvider {
  const LastUpdateDayDataProvider();
  static const updatedAtKey = 'updatedAt';
  @override
  Future<Resource<void>> update() async {
    var now = DateTime.now();
    var formatter = DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      final ok = await prefs.setString(updatedAtKey, formattedDate);
      if (!ok) {
        return Resource.error(
            'Не удалось сохранить дату последнего обновления');
      }
      return Resource.empty();
    } catch (e) {
      return Resource.error(
          'Не удалось сохранить дату последнего обновления: $e');
    }
  }

  @override
  Future<Resource<bool>> updated() async {
    var now = DateTime.now();
    var formatter = DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    try {
      final prefs = await SharedPreferences.getInstance();
      final updatedAt = prefs.getString(updatedAtKey);
      if (updatedAt != null) {
        return Resource.success(formattedDate == updatedAt);
      }
      return Resource.success(false);
    } on Exception catch (e) {
      return Resource.error(
          'Не удалось получить дату последнего обновления:  $e');
    }
  }
}
