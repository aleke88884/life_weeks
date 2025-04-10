import 'package:life_weeks/features/life_calendar/domain/entities/birthday_date.dart';
import 'package:life_weeks/features/life_calendar/domain/entities/week.dart';
import 'package:life_weeks/features/life_calendar/domain/repositories/life_calendar_repository.dart';

class LifeCalendarRepositoryImpl implements LifeCalendarRepository {
  @override
  List<Week> generateWeeks(BirthDayDate birthDayDate) {
    // TODO: implement generateWeeks
    throw UnimplementedError();
  }

  @override
  Future<BirthDayDate?> getSavedBirthDay() {
    // TODO: implement getSavedBirthDay
    throw UnimplementedError();
  }

  @override
  Future<void> saveBirthDay(BirthDayDate birthDayDate) {
    // TODO: implement saveBirthDay
    throw UnimplementedError();
  }
}