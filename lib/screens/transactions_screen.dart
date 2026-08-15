import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../providers/app_state_provider.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../widgets/transaction_dialog.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _searchQuery = '';
  String _selectedCategoryId = 'all';
  String _selectedType = 'all'; // 'all', 'income', 'expense'
  DateTime _filterMonth = DateTime.now(); // default to current month

  void _showEditTransaction(BuildContext context, AppState state, TransactionModel tx) async {
    final result = await showDialog<TransactionModel>(
      context: context,
      builder: (context) => TransactionDialog(
        transaction: tx,
        defaultCurrency: state.currency,
        onDelete: () {
          state.deleteTransaction(tx.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transacción eliminada'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    );

    if (result != null) {
      state.editTransaction(result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transacción actualizada'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // Group transactions by date
  Map<DateTime, List<TransactionModel>> _groupTransactionsByDate(List<TransactionModel> txs) {
    final Map<DateTime, List<TransactionModel>> grouped = {};
    for (var tx in txs) {
      final dateOnly = DateTime(tx.date.year, tx.date.month, tx.date.day);
      if (!grouped.containsKey(dateOnly)) {
        grouped[dateOnly] = [];
      }
      grouped[dateOnly]!.add(tx);
    }
    return grouped;
  }

  String _getDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) {
      return 'Hoy';
    } else if (date == yesterday) {
      return 'Ayer';
    } else {
      return DateFormat('EEEE, d \'de\' MMMM', 'es').format(date);
    }
  }

  void _selectMonth(BuildContext context) async {
    final theme = Theme.of(context);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _filterMonth,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 1),
      initialDatePickerMode: DatePickerMode.year,
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _filterMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: state,
      builder: (context, child) {
        // Apply filters
        final filteredList = state.transactions.where((tx) {
          // 1. Search Query
          final matchesSearch = tx.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              tx.notes.toLowerCase().contains(_searchQuery.toLowerCase());
          
          // 2. Category Filter
          final matchesCategory = _selectedCategoryId == 'all' || tx.categoryId == _selectedCategoryId;

          // 3. Type Filter
          final matchesType = _selectedType == 'all' ||
              (_selectedType == 'income' && tx.isIncome) ||
              (_selectedType == 'expense' && !tx.isIncome);

          // 4. Month Filter
          final matchesMonth = tx.date.year == _filterMonth.year && tx.date.month == _filterMonth.month;

          return matchesSearch && matchesCategory && matchesType && matchesMonth;
        }).toList();

        // Sort: newest first
        filteredList.sort((a, b) => b.date.compareTo(a.date));

        final groupedTxs = _groupTransactionsByDate(filteredList);
        final dateKeys = groupedTxs.keys.toList();

        return Scaffold(
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Filters Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Historial',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.6,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      // Month selector button
                      TextButton.icon(
                        onPressed: () => _selectMonth(context),
                        icon: Icon(Icons.calendar_today_rounded, size: 14, color: theme.primaryColor),
                        label: Text(
                          DateFormat('MMM y', 'es').format(_filterMonth),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: theme.cardColor,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: theme.dividerColor, width: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextField(
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Buscar concepto o nota...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 16),
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Horizontal Category filter list
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    itemCount: CategoryModel.all.length + 1,
                    itemBuilder: (context, idx) {
                      final isAll = idx == 0;
                      final cat = isAll ? null : CategoryModel.all[idx - 1];
                      final isSelected = isAll 
                          ? _selectedCategoryId == 'all' 
                          : _selectedCategoryId == cat!.id;
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(isAll ? 'Todas' : cat!.name),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategoryId = isAll ? 'all' : cat!.id;
                            });
                          },
                          showCheckmark: false,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected 
                                ? theme.scaffoldBackgroundColor 
                                : theme.textTheme.bodyLarge?.color,
                          ),
                          selectedColor: theme.primaryColor,
                          backgroundColor: theme.cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(
                            color: isSelected ? theme.primaryColor : theme.dividerColor,
                            width: 0.5,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),

                // Type Filter Switcher (Todos, Gastos, Ingresos)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      _buildTypeFilterChip('all', 'Todos'),
                      const SizedBox(width: 8),
                      _buildTypeFilterChip('expense', 'Gastos'),
                      const SizedBox(width: 8),
                      _buildTypeFilterChip('income', 'Ingresos'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Transaction list grouped by date
                Expanded(
                  child: filteredList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.hourglass_empty_rounded,
                                size: 48,
                                color: theme.disabledColor.withOpacity(0.3),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No se encontraron registros.',
                                style: TextStyle(color: theme.hintColor, fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: dateKeys.length,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          itemBuilder: (context, idx) {
                            final date = dateKeys[idx];
                            final dayTransactions = groupedTxs[date]!;
                            
                            // Calculate daily total
                            final dayExpenses = dayTransactions
                                .where((t) => !t.isIncome)
                                .fold(0.0, (sum, t) => sum + t.amount);
                            final dayIncomes = dayTransactions
                                .where((t) => t.isIncome)
                                .fold(0.0, (sum, t) => sum + t.amount);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Date Header Row
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _getDateHeader(date),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: theme.hintColor,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      // Daily summary metrics
                                      Row(
                                        children: [
                                          if (dayIncomes > 0)
                                            Text(
                                              '+${dayIncomes.toStringAsFixed(0)}',
                                              style: const TextStyle(fontSize: 11, color: Color(0xFF6F8F72), fontWeight: FontWeight.w600),
                                            ),
                                          if (dayIncomes > 0 && dayExpenses > 0)
                                            const SizedBox(width: 8),
                                          if (dayExpenses > 0)
                                            Text(
                                              '-${dayExpenses.toStringAsFixed(0)}',
                                              style: TextStyle(fontSize: 11, color: theme.textTheme.bodyLarge?.color?.withOpacity(0.8), fontWeight: FontWeight.w600),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Group List Items
                                Container(
                                  decoration: BoxDecoration(
                                    color: theme.cardColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: theme.dividerColor, width: 0.5),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: ListView.separated(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: dayTransactions.length,
                                      separatorBuilder: (_, __) => Divider(height: 1, thickness: 0.5, color: theme.dividerColor),
                                      itemBuilder: (context, dayIdx) {
                                        final tx = dayTransactions[dayIdx];
                                        final cat = CategoryModel.getById(tx.categoryId);
                                        
                                        return Dismissible(
                                          key: Key(tx.id),
                                          direction: DismissDirection.endToStart,
                                          onDismissed: (direction) {
                                            state.deleteTransaction(tx.id);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('"${tx.title}" eliminado'),
                                                action: SnackBarAction(
                                                  label: 'Deshacer',
                                                  onPressed: () {
                                                    state.addTransaction(tx);
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                          background: Container(
                                            alignment: Alignment.centerRight,
                                            padding: const EdgeInsets.only(right: 20.0),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFB07D7D).withOpacity(0.9),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.delete_sweep_rounded,
                                              color: Colors.white,
                                              size: 22,
                                            ),
                                          ),
                                          child: ListTile(
                                            leading: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: cat.color.withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(cat.icon, size: 16, color: cat.color),
                                            ),
                                            title: Text(
                                              tx.title,
                                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                            ),
                                            subtitle: tx.notes.isNotEmpty 
                                                ? Text(
                                                    tx.notes,
                                                    style: TextStyle(fontSize: 11, color: theme.hintColor),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  )
                                                : null,
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      '${tx.isIncome ? '+' : '-'}${tx.amount.toStringAsFixed(2)} ${tx.currency}',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.bold,
                                                        color: tx.isIncome 
                                                            ? const Color(0xFF6F8F72) 
                                                            : theme.textTheme.bodyLarge?.color,
                                                      ),
                                                    ),
                                                    if (!tx.isIncome) ...[
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        tx.paymentMethod.displayName,
                                                        style: TextStyle(fontSize: 9, color: theme.hintColor),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                                const SizedBox(width: 8),
                                                Icon(Icons.chevron_right_rounded, size: 16, color: theme.hintColor.withOpacity(0.5)),
                                              ],
                                            ),
                                            onTap: () => _showEditTransaction(context, state, tx),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypeFilterChip(String type, String label) {
    final isSelected = _selectedType == type;
    final theme = Theme.of(context);
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedType = type;
          });
        }
      },
      showCheckmark: false,
      labelStyle: TextStyle(
        fontSize: 11,
        color: isSelected ? theme.primaryColor : theme.hintColor,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.transparent,
      selectedColor: theme.primaryColor.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(
          color: isSelected ? theme.primaryColor.withOpacity(0.3) : theme.dividerColor,
          width: 0.5,
        ),
      ),
    );
  }
}
