import 'package:flutter/foundation.dart';
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
  static const int totalWeeks = 100 * 52;
  static const int weeksPerDecade = 10 * 52;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime? _selectedBirthDate;
  int? _weeksLived;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedBirthDate = widget.birthDate;
    if (_selectedBirthDate == null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _showBirthDateDialog());
    } else {
      _calculateWeeksLived();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _showBirthDateDialog() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
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

    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
        _weeksLived = null;
      });
      await _calculateWeeksLived();
      widget.onChangeDate();
    }
  }

  Future<void> _calculateWeeksLived() async {
    final date = _selectedBirthDate!;
    final duration = DateTime.now().difference(date);
    if (duration.inDays > 5000) {
      // > ~13 лет — вычисления в изоляте
      _weeksLived = await compute((d) {
        return (DateTime.now().difference(d).inDays / 7)
            .floor()
            .clamp(0, CalendarScreen.totalWeeks);
      }, date);
    } else {
      _weeksLived =
          (duration.inDays / 7).floor().clamp(0, CalendarScreen.totalWeeks);
    }
    if (mounted) setState(() {});
  }

  double _calculateAgeAtWeek(DateTime birthDate, int weekIndex) {
    final weekDate = birthDate.add(Duration(days: weekIndex * 7));
    return weekDate.difference(birthDate).inDays / 365.25;
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
    return 'Неделя: ${weekIndex + 1}\nВозраст: ${age.toStringAsFixed(1)} лет\nЭтап: $lifeStage';
  }

  void _scrollToDecade(int decade) {
    final weekIndex = decade * CalendarScreen.weeksPerDecade;
    final crossAxisCount = (MediaQuery.of(context).size.width / 20).floor();
    final rowIndex = (weekIndex / crossAxisCount).floor();
    final offset = rowIndex * 24.h;
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildGrid() {
    final birthDate = _selectedBirthDate!;
    final lived = _weeksLived!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = (constraints.maxWidth / 20).floor();
        final decadeSeparators =
            (CalendarScreen.totalWeeks / CalendarScreen.weeksPerDecade).floor();
        final totalItems = CalendarScreen.totalWeeks + decadeSeparators;

        return GridView.builder(
          controller: _scrollController,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: totalItems,
          itemBuilder: (context, index) {
            final isSeparator =
                index % (CalendarScreen.weeksPerDecade + 1) == 0;
            if (isSeparator) {
              final decade = index ~/ (CalendarScreen.weeksPerDecade + 1);
              final age = _calculateAgeAtWeek(
                  birthDate, decade * CalendarScreen.weeksPerDecade);
              return GestureDetector(
                onTap: () {
                  _scrollToDecade(decade);
                  showDialog<void>(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: const Color(0xFF2D2D44),
                      title: Text('$decade-е десятилетие',
                          style: const TextStyle(color: Colors.white)),
                      content: Text(
                          'Возраст: ${age.toStringAsFixed(1)} лет\nЭтап: ${_getLifeStage(age)}',
                          style: const TextStyle(color: Colors.white70)),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Закрыть'))
                      ],
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF6E56CF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: Text('${decade * 10} лет',
                      style: const TextStyle(color: Colors.white)),
                ),
              );
            }
            final weekIndex =
                index - (index ~/ (CalendarScreen.weeksPerDecade + 1));
            final isLived = weekIndex < lived;
            return Tooltip(
              message: _getTooltipMessage(weekIndex, birthDate, isLived),
              child: Container(
                decoration: BoxDecoration(
                  color: isLived ? const Color(0xFF6E56CF) : Colors.grey[700],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final font = GoogleFonts.montserrat().fontFamily;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D2D44),
        title: Text('Life Calendar',
            style: TextStyle(fontFamily: font, fontWeight: FontWeight.bold)),
        actions: [
          TextButton.icon(
            onPressed: _showBirthDateDialog,
            icon: const Icon(Icons.date_range, color: Colors.white),
            label: Text('Изменить дату',
                style: TextStyle(color: Colors.white, fontFamily: font)),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: (_selectedBirthDate == null || _weeksLived == null)
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF6E56CF)))
            : Row(
                children: [
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: _buildGrid())),
                  Container(
                    width: 200,
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2D2D44),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Дата рождения',
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: font,
                                fontSize: 16)),
                        const SizedBox(height: 8),
                        Text(
                            _selectedBirthDate!
                                .toLocal()
                                .toString()
                                .split(' ')[0],
                            style: TextStyle(
                                color: Colors.white70, fontFamily: font)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _showBirthDateDialog,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6E56CF)),
                          child: Text('Изменить',
                              style: TextStyle(
                                  color: Colors.white, fontFamily: font)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
