import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../providers/app_state_provider.dart';
import '../models/goal.dart';
import '../models/subscription.dart';
import '../widgets/goal_dialog.dart';
import '../widgets/subscription_dialog.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

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
            labelText: 'Presupuesto quincenal',
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

  // Goals
  void _showAddGoal(BuildContext context, AppState state) async {
    final result = await showDialog<GoalModel>(
      context: context,
      builder: (context) => GoalDialog(
        defaultCurrency: state.currency,
      ),
    );
    if (result != null) {
      state.addGoal(result);
    }
  }

  void _showEditGoal(BuildContext context, AppState state, GoalModel goal) async {
    final result = await showDialog<GoalModel>(
      context: context,
      builder: (context) => GoalDialog(
        goal: goal,
        defaultCurrency: state.currency,
      ),
    );
    if (result != null) {
      state.editGoal(result);
    }
  }

  void _showAddFundsDialog(BuildContext context, AppState state, GoalModel goal) {
    final controller = TextEditingController();
    final theme = Theme.of(context);
    final availableSavings = state.currentQuincenaAvailableSavings;
    final hasDeficit = state.remainingQuincenaBudget < 0;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.dividerColor, width: 0.5),
        ),
        title: Text(
          'Aportar a: ${goal.title}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Esta aportación se registrará como un egreso automático en tu historial.',
                  style: TextStyle(fontSize: 11, color: theme.hintColor),
                ),
                const SizedBox(height: 12),
                
                // Available balance indicator / Deficit warning
                if (hasDeficit) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB07D7D).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFB07D7D)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Alerta: Tu presupuesto está en déficit de ${(-state.remainingQuincenaBudget).toStringAsFixed(2)} ${state.currency}.',
                            style: const TextStyle(fontSize: 10, color: Color(0xFFB07D7D), fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ] else if (availableSavings > 0) ...[
                  InkWell(
                    onTap: () {
                      controller.text = availableSavings.toStringAsFixed(2);
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6F8F72).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF6F8F72).withOpacity(0.2), width: 0.5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.savings_rounded, size: 14, color: Color(0xFF6F8F72)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Saldo libre quincenal disponible: ${availableSavings.toStringAsFixed(2)} ${state.currency} (Toca para usar)',
                              style: const TextStyle(fontSize: 10, color: Color(0xFF6F8F72), fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.dividerColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded, size: 14, color: theme.hintColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'No tienes saldo libre disponible en esta quincena.',
                            style: TextStyle(fontSize: 10, color: theme.hintColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                
                TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Monto a ahorrar',
                    prefixText: '${goal.currency} ',
                  ),
                ),
              ],
            );
          }
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: theme.hintColor)),
          ),
          ElevatedButton(
            onPressed: () {
              final amt = double.tryParse(controller.text);
              if (amt != null && amt > 0) {
                state.addSavingsToGoal(goal.id, amt);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ahorraste ${amt.toStringAsFixed(2)} ${goal.currency} para ${goal.title}')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: theme.scaffoldBackgroundColor,
            ),
            child: const Text('Ahorrar'),
          ),
        ],
      ),
    );
  }

  // Subscriptions
  void _showAddSubscription(BuildContext context, AppState state) async {
    final result = await showDialog<SubscriptionModel>(
      context: context,
      builder: (context) => SubscriptionDialog(
        defaultCurrency: state.currency,
      ),
    );
    if (result != null) {
      state.addSubscription(result);
    }
  }

  void _showEditSubscription(BuildContext context, AppState state, SubscriptionModel sub) async {
    final result = await showDialog<SubscriptionModel>(
      context: context,
      builder: (context) => SubscriptionDialog(
        subscription: sub,
        defaultCurrency: state.currency,
      ),
    );
    if (result != null) {
      state.editSubscription(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: state,
      builder: (context, child) {
        final totalExpense = state.currentQuincenaExpensesTotal;
        final budgetProgress = state.quincenaBudgetProgressPercentage;
        final remaining = state.remainingQuincenaBudget;

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Screen Title
                  Text(
                    'Presupuesto y Metas',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.6,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Monthly Budget section
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.dividerColor, width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                             Text(
                              'Presupuesto de la Quincena',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.primaryColor),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.edit_rounded, 
                                size: 16,
                                color: state.useIncomeAsBudget ? theme.hintColor.withOpacity(0.5) : theme.textTheme.bodyLarge?.color,
                              ),
                              onPressed: state.useIncomeAsBudget 
                                  ? () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('El presupuesto está vinculado a tus ingresos quincenales. Desactiva la vinculación abajo para editarlo manualmente.'),
                                        ),
                                      );
                                    }
                                  : () => _showBudgetDialog(context, state),
                              style: IconButton.styleFrom(
                                backgroundColor: theme.scaffoldBackgroundColor,
                                padding: const EdgeInsets.all(8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Límite Establecido:',
                              style: TextStyle(fontSize: 13, color: theme.hintColor),
                            ),
                            Text(
                              '${state.budget.toStringAsFixed(2)} ${state.currency}',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Consumido:',
                              style: TextStyle(fontSize: 13, color: theme.hintColor),
                            ),
                            Text(
                              '${totalExpense.toStringAsFixed(2)} ${state.currency} (${(budgetProgress * 100).toStringAsFixed(0)}%)',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: budgetProgress,
                            minHeight: 8,
                            backgroundColor: theme.scaffoldBackgroundColor,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              budgetProgress >= 1.0
                                  ? const Color(0xFFB07D7D)
                                  : theme.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          remaining >= 0
                              ? 'Saldo quincenal disponible: ${remaining.toStringAsFixed(2)} ${state.currency}'
                              : 'Excedido por ${(-remaining).toStringAsFixed(2)} ${state.currency}',
                          style: TextStyle(
                            fontSize: 12,
                            color: remaining >= 0 ? const Color(0xFF6F8F72) : const Color(0xFFB07D7D),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 24, thickness: 0.5),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Vincular con mis ingresos',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Usa el sueldo quincenal como límite de presupuesto.',
                                    style: TextStyle(fontSize: 10, color: theme.hintColor),
                                  ),
                                ],
                              ),
                            ),
                            Switch.adaptive(
                              value: state.useIncomeAsBudget,
                              activeColor: theme.primaryColor,
                              onChanged: (val) {
                                state.setUseIncomeAsBudget(val);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Savings Goals section header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Metas de Ahorro',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          Text(
                            'Ahorra de forma automatizada',
                            style: TextStyle(fontSize: 11, color: theme.hintColor),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () => _showAddGoal(context, state),
                        icon: const Icon(Icons.add_rounded, size: 14),
                        label: const Text('Crear Meta', style: TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.primaryColor,
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
                  const SizedBox(height: 12),

                  // Balance connection banner for Goals
                  () {
                    final availableSavings = state.currentQuincenaAvailableSavings;
                    final hasDeficit = state.remainingQuincenaBudget < 0;
                    
                    if (availableSavings > 0 && !hasDeficit) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6F8F72).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF6F8F72).withOpacity(0.3), width: 0.5),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF6F8F72), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '¡Excelente! Tienes ${availableSavings.toStringAsFixed(2)} ${state.currency} de saldo libre esta quincena para aportar a tus metas.',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB07D7D).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFB07D7D).withOpacity(0.3), width: 0.5),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Color(0xFFB07D7D), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                hasDeficit 
                                    ? '⚠️ Presupuesto quincenal excedido en ${(-state.remainingQuincenaBudget).toStringAsFixed(2)} ${state.currency}. Se recomienda no aportar a metas hasta equilibrar tu saldo.'
                                    : '⚠️ No tienes saldo libre disponible en esta quincena. Registra ingresos o reduce gastos antes de aportar a tus metas.',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFFB07D7D)),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  }(),

                  // Savings Goals List
                  if (state.goals.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: theme.cardColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.dividerColor, width: 0.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'No has creado metas de ahorro todavía.',
                        style: TextStyle(color: theme.hintColor, fontSize: 13),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.goals.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, idx) {
                        final goal = state.goals[idx];
                        final pct = goal.progressPercentage;

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: theme.dividerColor, width: 0.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          goal.title,
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (goal.deadline != null) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            'Meta: ${DateFormat('d MMM y', 'es').format(goal.deadline!)}',
                                            style: TextStyle(fontSize: 10, color: theme.hintColor),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  // Edit & delete popup menu
                                  PopupMenuButton<String>(
                                    icon: Icon(Icons.more_vert_rounded, size: 18, color: theme.hintColor),
                                    padding: EdgeInsets.zero,
                                    color: theme.cardColor,
                                    borderRadius: BorderRadius.circular(8),
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit_rounded, size: 16),
                                            SizedBox(width: 8),
                                            Text('Editar', style: TextStyle(fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete_rounded, size: 16, color: Color(0xFFB07D7D)),
                                            SizedBox(width: 8),
                                            Text('Eliminar', style: TextStyle(fontSize: 12, color: Color(0xFFB07D7D))),
                                          ],
                                        ),
                                      ),
                                    ],
                                    onSelected: (val) {
                                      if (val == 'edit') {
                                        _showEditGoal(context, state, goal);
                                      } else if (val == 'delete') {
                                        state.deleteGoal(goal.id);
                                      }
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              
                              // Target vs saved
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Ahorrado: ${goal.currentAmount.toStringAsFixed(2)} / ${goal.targetAmount.toStringAsFixed(2)} ${goal.currency}',
                                    style: TextStyle(fontSize: 12, color: theme.hintColor, fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    '${(pct * 100).toStringAsFixed(0)}%',
                                    style: TextStyle(fontSize: 12, color: theme.primaryColor, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              
                              // Progress bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: pct,
                                  minHeight: 6,
                                  backgroundColor: theme.scaffoldBackgroundColor,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    goal.isAchieved ? const Color(0xFF6F8F72) : theme.primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Goal notes / Aportar button row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      goal.notes.isNotEmpty ? goal.notes : 'Sin observaciones',
                                      style: TextStyle(fontSize: 11, color: theme.hintColor, fontStyle: FontStyle.italic),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: () => _showAddFundsDialog(context, state, goal),
                                    icon: const Icon(Icons.savings_rounded, size: 12),
                                    label: const Text('Aportar', style: TextStyle(fontSize: 11)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.primaryColor,
                                      foregroundColor: theme.scaffoldBackgroundColor,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 28),

                  // Subscriptions tracker section header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Suscripciones / Gastos Fijos',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          Text(
                            'Total quincenal estimado: ${state.activeSubscriptionsTotalQuincenal.toStringAsFixed(2)} ${state.currency}',
                            style: TextStyle(fontSize: 11, color: theme.hintColor, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () => _showAddSubscription(context, state),
                        icon: const Icon(Icons.add_rounded, size: 14),
                        label: const Text('Agregar', style: TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.primaryColor,
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
                  const SizedBox(height: 12),

                  // Subscriptions list
                  if (state.subscriptions.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: theme.cardColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.dividerColor, width: 0.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'No tienes suscripciones registradas.',
                        style: TextStyle(color: theme.hintColor, fontSize: 13),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.dividerColor, width: 0.5),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.subscriptions.length,
                          separatorBuilder: (_, __) => Divider(height: 1, thickness: 0.5, color: theme.dividerColor),
                          itemBuilder: (context, idx) {
                            final sub = state.subscriptions[idx];

                            return ListTile(
                              leading: Switch.adaptive(
                                value: sub.isActive,
                                activeColor: theme.primaryColor,
                                onChanged: (_) {
                                  state.toggleSubscriptionActive(sub.id);
                                },
                              ),
                              title: Text(
                                sub.title,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  decoration: sub.isActive ? TextDecoration.none : TextDecoration.lineThrough,
                                  color: sub.isActive ? theme.textTheme.bodyLarge?.color : theme.hintColor,
                                ),
                              ),
                              subtitle: Text(
                                () {
                                  if (sub.frequency == SubscriptionFrequency.daily) {
                                    return 'Cobro: Todos los días';
                                  } else if (sub.frequency == SubscriptionFrequency.weekly) {
                                    if (sub.weekdays.isNotEmpty) {
                                      const weekdaysNames = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
                                      final daysStr = sub.weekdays.map((d) => weekdaysNames[d - 1]).join(', ');
                                      return 'Cobro: Cada $daysStr';
                                    } else {
                                      const weekdays = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
                                      final weekdayName = (sub.dueDate >= 1 && sub.dueDate <= 7) ? weekdays[sub.dueDate - 1] : 'Lunes';
                                      return 'Cobro: Cada $weekdayName';
                                    }
                                  } else if (sub.frequency == SubscriptionFrequency.fortnightly) {
                                    return 'Cobro: Día ${sub.dueDate} de cada quincena';
                                  } else {
                                    return sub.dueDate == 32 
                                        ? 'Cobro: Fin de mes' 
                                        : 'Cobro: Día ${sub.dueDate} de cada mes';
                                  }
                                }(),
                                style: TextStyle(fontSize: 10, color: theme.hintColor),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    () {
                                      final String freqLabel;
                                      if (sub.frequency == SubscriptionFrequency.daily) {
                                        freqLabel = 'd';
                                      } else if (sub.frequency == SubscriptionFrequency.weekly) {
                                        freqLabel = 'sem';
                                      } else if (sub.frequency == SubscriptionFrequency.fortnightly) {
                                        freqLabel = 'q';
                                      } else {
                                        freqLabel = 'm';
                                      }
                                      return '${sub.amount.toStringAsFixed(2)} ${sub.currency} / $freqLabel';
                                    }(),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: sub.isActive ? theme.primaryColor : theme.hintColor,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  PopupMenuButton<String>(
                                    icon: Icon(Icons.more_vert_rounded, size: 18, color: theme.hintColor),
                                    padding: EdgeInsets.zero,
                                    color: theme.cardColor,
                                    borderRadius: BorderRadius.circular(8),
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Editar', style: TextStyle(fontSize: 12)),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Eliminar', style: TextStyle(fontSize: 12, color: Color(0xFFB07D7D))),
                                      ),
                                    ],
                                    onSelected: (val) {
                                      if (val == 'edit') {
                                        _showEditSubscription(context, state, sub);
                                      } else if (val == 'delete') {
                                        state.deleteSubscription(sub.id);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
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
