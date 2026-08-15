import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../providers/app_state_provider.dart';
import '../widgets/custom_pie_chart.dart';
import '../widgets/custom_bar_chart.dart';
import '../widgets/transaction_dialog.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../widgets/app_logo.dart';


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _showAddTransaction(BuildContext context, AppState state) async {
    final result = await showDialog<TransactionModel>(
      context: context,
      builder: (context) => TransactionDialog(
        defaultCurrency: state.currency,
      ),
    );

    if (result != null) {
      state.addTransaction(result);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transacción guardada con éxito'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transacción actualizada'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showBudgetDialog(BuildContext context, AppState state) {
    final controller = TextEditingController(text: state.budget.toStringAsFixed(2));
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.dividerColor, width: 0.5),
        ),
        title: const Text(
          'Ajustar Presupuesto Quincenal',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Presupuesto mensual',
            prefixText: '${state.currency} ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: theme.hintColor)),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null && val >= 0) {
                state.setBudget(val);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: theme.scaffoldBackgroundColor,
            ),
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: state,
      builder: (context, child) {
        final totalExpense = state.currentQuincenaExpensesTotal;
        final totalIncome = state.currentQuincenaIncomeTotal;
        final balance = totalIncome - totalExpense;
        final remaining = state.remainingQuincenaBudget;
        final budgetProgress = state.quincenaBudgetProgressPercentage;
        final breakdown = state.categoryExpensesBreakdownQuincena;
        final insights = state.financialInsights;
        final recentTransactions = state.transactions.take(5).toList();

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Greet
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const AppLogo(size: 38),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bienvenida, Luci',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.6,
                                  color: theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                state.quincenaName.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                  color: theme.hintColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Quick actions
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add_rounded, size: 22),
                            onPressed: () => _showAddTransaction(context, state),
                            style: IconButton.styleFrom(
                              backgroundColor: theme.primaryColor,
                              foregroundColor: theme.scaffoldBackgroundColor,
                              padding: const EdgeInsets.all(10),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Financial Card (Balance & Budget)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.dividerColor, width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SUELDO / INGRESOS QUINCENALES',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                            color: theme.hintColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${totalIncome.toStringAsFixed(2)} ${state.currency}',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Mini row of totals (Expense & Net Balance)
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.arrow_upward_rounded, size: 12, color: Color(0xFFB07D7D)),
                                      const SizedBox(width: 4),
                                      Text('Gastos Quincena', style: TextStyle(fontSize: 11, color: theme.hintColor)),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${totalExpense.toStringAsFixed(2)} ${state.currency}',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            Container(width: 0.5, height: 28, color: theme.dividerColor),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        balance >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                                        size: 12,
                                        color: balance >= 0 ? const Color(0xFF6F8F72) : const Color(0xFFB07D7D),
                                      ),
                                      const SizedBox(width: 4),
                                      Text('Balance Quincena', style: TextStyle(fontSize: 11, color: theme.hintColor)),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${balance.toStringAsFixed(2)} ${state.currency}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: balance >= 0 
                                          ? const Color(0xFF6F8F72) 
                                          : const Color(0xFFB07D7D),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Divider(height: 1, thickness: 0.5),
                        ),

                        // Monthly Budget progress bar
                        GestureDetector(
                          onTap: () => _showBudgetDialog(context, state),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Presupuesto quincenal',
                                    style: TextStyle(fontSize: 12, color: theme.hintColor),
                                  ),
                                  Text(
                                    '${totalExpense.toStringAsFixed(0)} / ${state.budget.toStringAsFixed(0)} ${state.currency}',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Progress bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: budgetProgress,
                                  minHeight: 6,
                                  backgroundColor: theme.scaffoldBackgroundColor,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    budgetProgress >= 1.0
                                        ? const Color(0xFFB07D7D) // Exceeded
                                        : (budgetProgress >= 0.8
                                            ? const Color(0xFFBCA374) // Warning
                                            : theme.primaryColor),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                remaining >= 0
                                    ? 'Saldo quincenal restante: ${remaining.toStringAsFixed(2)} ${state.currency}'
                                    : 'Excedido por ${(-remaining).toStringAsFixed(2)} ${state.currency}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: remaining >= 0 ? theme.hintColor : const Color(0xFFB07D7D),
                                  fontWeight: remaining >= 0 ? FontWeight.normal : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Financial Health Insights Carousel
                  if (insights.isNotEmpty) ...[
                    Text(
                      'Análisis Financiero',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 80,
                      child: PageView.builder(
                        itemCount: insights.length,
                        controller: PageController(viewportFraction: 0.96),
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(right: 8.0),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: theme.cardColor.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: theme.dividerColor, width: 0.5),
                            ),
                            child: Center(
                              child: Text(
                                insights[index],
                                style: const TextStyle(
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Expenses Pie Chart Breakdown
                  if (breakdown.isNotEmpty) ...[
                    Text(
                      'Distribución de Gastos',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.dividerColor, width: 0.5),
                      ),
                      child: CustomPieChart(
                        data: breakdown,
                        currency: state.currency,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Weekly Bar Chart
                  if (state.transactions.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.dividerColor, width: 0.5),
                      ),
                      child: CustomBarChart(
                        transactions: state.transactions,
                        currency: state.currency,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Recent Transactions Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Actividad Reciente',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Recent Transactions List
                  if (recentTransactions.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      alignment: Alignment.center,
                      child: Text(
                        'No hay transacciones guardadas.',
                        style: TextStyle(color: theme.hintColor, fontSize: 13),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recentTransactions.length,
                      separatorBuilder: (_, __) => Divider(height: 1, thickness: 0.5, color: theme.dividerColor),
                      itemBuilder: (context, idx) {
                        final tx = recentTransactions[idx];
                        final cat = CategoryModel.getById(tx.categoryId);
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: cat.color.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(cat.icon, size: 18, color: cat.color),
                          ),
                          title: Text(
                            tx.title,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            DateFormat('d MMM y', 'es').format(tx.date),
                            style: TextStyle(fontSize: 11, color: theme.hintColor),
                          ),
                          trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${tx.isIncome ? '+' : '-'}${tx.amount.toStringAsFixed(2)} ${tx.currency}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: tx.isIncome 
                                      ? const Color(0xFF6F8F72) 
                                      : theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                              if (tx.notes.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  tx.notes,
                                  style: TextStyle(fontSize: 9, color: theme.hintColor),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ],
                          ),
                          onTap: () => _showEditTransaction(context, state, tx),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
