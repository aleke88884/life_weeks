import 'package:life_weeks/features/life_calendar/domain/entities/birthday_date.dart';
import 'package:life_weeks/features/life_calendar/domain/entities/week.dart';

abstract class LifeCalendarRepository {
  Future<BirthDayDate?> getSavedBirthDay();
  Future<void> saveBirthDay(BirthDayDate birthDayDate);
  List<Week> generateWeeks(BirthDayDate birthDayDate);
}
