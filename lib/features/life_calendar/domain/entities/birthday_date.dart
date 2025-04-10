import 'package:life_weeks/core/error/error_helper.dart';

class BirthDayDate {
  final DateTime value;
  BirthDayDate({required this.value}) {
    if (value.isAfter(DateTime.now())) {
      throw ErrorHelper(errorMessage: 'BirthDayDate cannot be the future');
    }
  }
}
