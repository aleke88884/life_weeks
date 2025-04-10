import 'package:get_it/get_it.dart';
import 'package:life_weeks/features/life_calendar/domain/repositories/life_calendar_repository.dart';
import 'package:life_weeks/features/life_calendar/domain/repositories/life_calendar_repository_impl.dart';
import 'package:life_weeks/features/life_calendar/domain/services/life_calendar_service.dart';
import 'package:life_weeks/features/life_calendar/domain/services/life_calendar_service_impl.dart';

class DiResolver {
  static final GetIt _di = GetIt.instance;
  static Future<void> register() async {
    _registerServices();
    _registerRepositories();
    _registerStorage();
  }

  static Future<void> _registerRepositories() async {
    _di.registerLazySingleton<LifeCalendarRepository>(
      () => LifeCalendarRepositoryImpl(),
    );
  }

  static Future<void> _registerServices() async {
    _di.registerLazySingleton<LifeCalendarService>(
        () => LifeCalendarServiceImpl());
  }

  static Future<void> _registerStorage() async {}
}
