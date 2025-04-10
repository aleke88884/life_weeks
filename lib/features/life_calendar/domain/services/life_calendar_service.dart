import 'package:life_weeks/features/life_calendar/domain/entities/week.dart';

abstract class LifeCalendarService {
  List<Week> generateListWeeks({required DateTime birthDate});
  int getPassedWeeks({required DateTime birthDate});
  int getRemainingWeeks({required DateTime birthDate});
}
