import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class CustomBarChart extends StatefulWidget {
  final List<TransactionModel> transactions;
  final String currency;

  const CustomBarChart({
    super.key,
    required this.transactions,
    required this.currency,
  });

  @override
  State<CustomBarChart> createState() => _CustomBarChartState();
}

class _CustomBarChartState extends State<CustomBarChart> {
  int _selectedIdx = -1;

  // Generate the last 7 days list
  List<Map<String, dynamic>> get _last7DaysData {
    final List<Map<String, dynamic>> data = [];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final targetDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      
      // Calculate expenses for this day
      final double daySpend = widget.transactions
          .where((tx) =>
              !tx.isIncome &&
              tx.date.year == targetDate.year &&
              tx.date.month == targetDate.month &&
              tx.date.day == targetDate.day)
          .fold(0.0, (sum, tx) => sum + tx.amount);

      final weekdayName = DateFormat('E', 'es').format(targetDate); // e.g. "lun.", "mar."
      final formattedDay = weekdayName.replaceAll('.', '').toUpperCase();

      data.add({
        'date': targetDate,
        'label': formattedDay,
        'amount': daySpend,
      });
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    final data = _last7DaysData;
    final maxAmount = data.fold<double>(
      0.0,
      (max, item) => (item['amount'] as double) > max ? (item['amount'] as double) : max,
    );

    final double totalWeek = data.fold(0.0, (sum, item) => sum + (item['amount'] as double));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      key: const ValueKey('custom_bar_chart'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Últimos 7 días',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              Text(
                'Total: ${totalWeek.toStringAsFixed(2)} ${widget.currency}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(data.length, (idx) {
                final item = data[idx];
                final double amount = item['amount'];
                final String label = item['label'];
                final DateTime date = item['date'];

                final isToday = date.day == DateTime.now().day &&
                    date.month == DateTime.now().month &&
                    date.year == DateTime.now().year;

                // Height ratio
                final double ratio = maxAmount > 0 ? amount / maxAmount : 0.0;
                final double height = (ratio * 90).clamp(4.0, 90.0);

                final isSelected = _selectedIdx == idx;

                return Expanded(
                  child: GestureDetector(
                    onTapDown: (_) {
                      setState(() {
                        _selectedIdx = isSelected ? -1 : idx;
                      });
                    },
                    child: MouseRegion(
                      onEnter: (_) {
                        setState(() {
                          _selectedIdx = idx;
                        });
                      },
                      onExit: (_) {
                        setState(() {
                          _selectedIdx = -1;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Floating amount indicator
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 150),
                            opacity: isSelected && amount > 0 ? 1.0 : 0.0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${amount.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Bar
                          Container(
                            height: 90,
                            alignment: Alignment.bottomCenter,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeOutCubic,
                              width: 14,
                              height: height,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : (isToday
                                        ? Theme.of(context).primaryColor.withOpacity(0.8)
                                        : Theme.of(context).primaryColor.withOpacity(0.3)),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Label
                          Text(
                            label.substring(0, 1), // Just first letter (L, M, M, J, V, S, D)
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isToday ? FontWeight.bold : FontWeight.w400,
                              color: isToday
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).hintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
