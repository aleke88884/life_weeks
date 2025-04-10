import 'package:life_weeks/core/constants/app_contstants.dart';
import 'package:life_weeks/features/life_calendar/domain/entities/week.dart';
import 'package:life_weeks/features/life_calendar/domain/services/life_calendar_service.dart';

class LifeCalendarServiceImpl implements LifeCalendarService {
  @override
  List<Week> generateListWeeks({required DateTime birthDate}) {
    try {
      final now = DateTime.now();
      final List<Week> weeks = [];
      for (int i = 0; i < AppContstants.totalWeeks; i++) {
        final weekStartDate = birthDate.add(Duration(days: i * 7));
        final isPast = now.isAfter(weekStartDate);
        weeks.add(
          Week(
            number: i,
            startDate: weekStartDate,
            isLived: isPast,
          ),
        );
      }
      return weeks;
    } catch (_) {
      rethrow;
    }
  }

  @override
  int getPassedWeeks({required DateTime birthDate}) {
    try {
      final now = DateTime.now();
      final difference = now.difference(birthDate);
      return (difference.inDays / 7 ).floor().clamp(0, AppContstants.totalWeeks);
    } catch (_) {
      rethrow;
    }
  }
  
  @override
  int getRemainingWeeks({required DateTime birthDate}) {
    try{
      return AppContstants.totalWeeks - getPassedWeeks(birthDate:birthDate );
    }catch(_){
      rethrow;
    }
  }
}
