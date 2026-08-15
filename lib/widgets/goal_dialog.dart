import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/goal.dart';

class GoalDialog extends StatefulWidget {
  final GoalModel? goal; // If null, we are in "Create" mode
  final String defaultCurrency;

  const GoalDialog({
    super.key,
    this.goal,
    required this.defaultCurrency,
  });

  @override
  State<GoalDialog> createState() => _GoalDialogState();
}

class _GoalDialogState extends State<GoalDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _targetAmountController;
  late TextEditingController _currentAmountController;
  late TextEditingController _notesController;
  DateTime? _deadline;

  @override
  void initState() {
    super.initState();
    final goal = widget.goal;
    
    _titleController = TextEditingController(text: goal?.title ?? '');
    _targetAmountController = TextEditingController(
      text: goal != null ? goal.targetAmount.toStringAsFixed(2) : '',
    );
    _currentAmountController = TextEditingController(
      text: goal != null ? goal.currentAmount.toStringAsFixed(2) : '0.00',
    );
    _notesController = TextEditingController(text: goal?.notes ?? '');
    _deadline = goal?.deadline;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 10),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _deadline = picked;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final target = double.tryParse(_targetAmountController.text) ?? 0.0;
      final current = double.tryParse(_currentAmountController.text) ?? 0.0;
      
      final goal = GoalModel(
        id: widget.goal?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        targetAmount: target,
        currentAmount: current,
        deadline: _deadline,
        notes: _notesController.text.trim(),
        currency: widget.goal?.currency ?? widget.defaultCurrency,
      );
      Navigator.of(context).pop(goal);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor, width: 0.5),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.goal == null ? 'Nueva Meta de Ahorro' : 'Editar Meta de Ahorro',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                      style: IconButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(32, 32),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Title Input
                TextFormField(
                  controller: _titleController,
                  autofocus: widget.goal == null,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la Meta',
                    hintText: 'Ej. Viaje de vacaciones, Fondo de emergencia',
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Por favor escribe un nombre para la meta';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Target Amount Input
                TextFormField(
                  controller: _targetAmountController,
                  decoration: InputDecoration(
                    labelText: 'Monto Objetivo',
                    prefixText: '${widget.defaultCurrency} ',
                    hintText: '0.00',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Por favor escribe un monto objetivo';
                    }
                    final amt = double.tryParse(val);
                    if (amt == null || amt <= 0) {
                      return 'Por favor escribe un monto válido mayor a 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Current Amount Input
                TextFormField(
                  controller: _currentAmountController,
                  decoration: InputDecoration(
                    labelText: 'Monto Inicial Ahorrado (Opcional)',
                    prefixText: '${widget.defaultCurrency} ',
                    hintText: '0.00',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (val) {
                    if (val == null || val.isEmpty) return null;
                    final amt = double.tryParse(val);
                    if (amt == null || amt < 0) {
                      return 'Por favor escribe un monto válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Deadline Picker Button
                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.dividerColor, width: 0.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, size: 18, color: theme.primaryColor),
                            const SizedBox(width: 10),
                            Text(
                              _deadline == null
                                  ? 'Fecha límite (Sin fecha)'
                                  : DateFormat('d MMMM y', 'es').format(_deadline!),
                              style: TextStyle(
                                fontSize: 13,
                                color: _deadline == null ? theme.hintColor : theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                        if (_deadline != null)
                          IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 16),
                            onPressed: () {
                              setState(() {
                                _deadline = null;
                              });
                            },
                            style: IconButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(24, 24),
                            ),
                          )
                        else
                          const Icon(Icons.chevron_right_rounded, size: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Notes input
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notas u observaciones (Opcional)',
                    hintText: 'Detalles adicionales...',
                  ),
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.hintColor,
                      ),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: theme.scaffoldBackgroundColor,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(widget.goal == null ? 'Crear' : 'Actualizar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
