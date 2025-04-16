import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({
    super.key,
    required this.birthDate,
    required this.onChangeDate,
  });

  final DateTime? birthDate;
  final VoidCallback onChangeDate;
  static const String routeName = '/calendar';
  static const int totalWeeks = 100 * 52; // 100 лет * 52 недели

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime? _selectedBirthDate;

  @override
  void initState() {
    super.initState();
    _selectedBirthDate = widget.birthDate;
    if (_selectedBirthDate == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showBirthDateDialog();
      });
    }
  }

  Future<void> _showBirthDateDialog() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6E56CF),
              onPrimary: Colors.white,
              surface: Color(0xFF2D2D44),
            ),
            dialogBackgroundColor: const Color(0xFF2D2D44),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
            ),
            inputDecorationTheme: const InputDecorationTheme(
              labelStyle: TextStyle(color: Colors.white),
              hintStyle: TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white54),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF6E56CF)),
              ),
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedBirthDate = picked;
      });
      widget.onChangeDate();
    }
  }

  int _calculateLivedWeeks(DateTime birthDate) {
    final now = DateTime.now();
    final difference = now.difference(birthDate);
    final weeksLived = (difference.inDays / 7).floor();
    return weeksLived.clamp(0, CalendarScreen.totalWeeks);
  }

  double _calculateAgeAtWeek(DateTime birthDate, int weekIndex) {
    // Дата, соответствующая данной неделе
    final weekDate = birthDate.add(Duration(days: weekIndex * 7));

    // Расчет разницы в годах
    final years = weekDate.year - birthDate.year;
    final months = weekDate.month - birthDate.month;
    final days = weekDate.day - birthDate.day;

    // Корректировка, если день рождения еще не наступил в этом году
    final adjustedYears =
        years + (months < 0 || (months == 0 && days < 0) ? -1 : 0);

    // Добавляем дробную часть года
    final monthFraction = (((weekDate.month + (weekDate.day / 30.44)) -
                (birthDate.month + (birthDate.day / 30.44))) %
            12) /
        12;

    return adjustedYears +
        (monthFraction < 0 ? 1 + monthFraction : monthFraction);
  }

  String _getLifeStage(double age) {
    if (age < 2) return 'Малыш';
    if (age < 7) return 'Дошкольник';
    if (age < 13) return 'Школьник';
    if (age < 18) return 'Подросток';
    if (age < 25) return 'Молодой взрослый';
    if (age < 40) return 'Взрослый';
    if (age < 60) return 'Зрелый возраст';
    return 'Пожилой возраст';
  }

  String _getTooltipMessage(int weekIndex, DateTime birthDate, bool isLived) {
    final age = _calculateAgeAtWeek(birthDate, weekIndex);
    final lifeStage = _getLifeStage(age);
    final ageText = isLived
        ? 'Возраст: ${age.toStringAsFixed(1)} лет'
        : 'Будет примерно ${age.toStringAsFixed(1)} лет';
    return 'Неделя: ${weekIndex + 1}\n$ageText\nЭтап: $lifeStage';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2F),
      appBar: AppBar(
        title: Text(
          'Life Calendar',
          style: TextStyle(
            fontFamily: GoogleFonts.montserrat().fontFamily,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        backgroundColor: const Color(0xFF2D2D44),
        elevation: 0,
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: TextButton.icon(
              onPressed: _showBirthDateDialog,
              icon: const Icon(Icons.date_range, color: Colors.white),
              label: Text(
                'Изменить дату',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _selectedBirthDate == null
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6E56CF),
              ),
            )
          : Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount =
                            (constraints.maxWidth / 20).floor();
                        return SingleChildScrollView(
                          child: SizedBox(
                            height: (CalendarScreen.totalWeeks /
                                    crossAxisCount *
                                    24)
                                .h,
                            child: GridView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                mainAxisSpacing: 4.w,
                                crossAxisSpacing: 4.w,
                              ),
                              itemCount: CalendarScreen.totalWeeks,
                              itemBuilder: (context, index) {
                                final weeksLived =
                                    _calculateLivedWeeks(_selectedBirthDate!);
                                final isLived = index < weeksLived;
                                return MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Tooltip(
                                    message: _getTooltipMessage(
                                        index, _selectedBirthDate!, isLived),
                                    preferBelow: true,
                                    textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                      fontFamily:
                                          GoogleFonts.montserrat().fontFamily,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2D2D44),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isLived
                                            ? const Color(0xFF6E56CF)
                                            : Colors.grey[700],
                                        borderRadius:
                                            BorderRadius.circular(4.r),
                                        boxShadow: [
                                          if (isLived)
                                            BoxShadow(
                                              color: const Color(0xFF6E56CF)
                                                  .withOpacity(0.3),
                                              blurRadius: 4.r,
                                              spreadRadius: 1.r,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 16.h),
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D2D44),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.r),
                        bottomLeft: Radius.circular(16.r),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 12.r,
                          offset: Offset(-4.w, 0),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Дата рождения',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: GoogleFonts.montserrat().fontFamily,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          _selectedBirthDate!.toString().split(' ')[0],
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14.sp,
                            fontFamily: GoogleFonts.montserrat().fontFamily,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: _showBirthDateDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6E56CF),
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 12.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Text(
                            'Изменить',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: GoogleFonts.montserrat().fontFamily,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
