import 'package:flutter/material.dart';
import '../models/subscription.dart';
import '../models/category.dart';

class SubscriptionDialog extends StatefulWidget {
  final SubscriptionModel? subscription; // If null, we are in "Create" mode
  final String defaultCurrency;

  const SubscriptionDialog({
    super.key,
    this.subscription,
    required this.defaultCurrency,
  });

  @override
  State<SubscriptionDialog> createState() => _SubscriptionDialogState();
}

class _SubscriptionDialogState extends State<SubscriptionDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  late int _dueDate;
  late String _categoryId;
  late SubscriptionFrequency _frequency;

  @override
  void initState() {
    super.initState();
    final sub = widget.subscription;
    
    _titleController = TextEditingController(text: sub?.title ?? '');
    _amountController = TextEditingController(
      text: sub != null ? sub.amount.toStringAsFixed(2) : '',
    );
    _notesController = TextEditingController(text: sub?.notes ?? '');
    _dueDate = sub?.dueDate ?? 1;
    _categoryId = sub?.categoryId ?? CategoryModel.expenseCategories.first.id;
    _frequency = sub?.frequency ?? SubscriptionFrequency.monthly;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      
      final sub = SubscriptionModel(
        id: widget.subscription?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        amount: amount,
        categoryId: _categoryId,
        dueDate: _frequency == SubscriptionFrequency.daily ? 1 : _dueDate,
        notes: _notesController.text.trim(),
        isActive: widget.subscription?.isActive ?? true,
        currency: widget.subscription?.currency ?? widget.defaultCurrency,
        frequency: _frequency,
      );
      Navigator.of(context).pop(sub);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = CategoryModel.expenseCategories;

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
                      widget.subscription == null ? 'Nueva Suscripción' : 'Editar Suscripción',
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
                  autofocus: widget.subscription == null,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Servicio / Gasto Fijo',
                    hintText: 'Ej. Netflix, Gimnasio, Alquiler',
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Por favor escribe un nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Frequency Selection
                const Text(
                  'Frecuencia de Pago',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: SubscriptionFrequency.values.map((freq) {
                    final isSelected = _frequency == freq;
                    return ChoiceChip(
                      label: Text(
                        freq.displayName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected 
                              ? theme.scaffoldBackgroundColor 
                              : theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _frequency = freq;
                          });
                        }
                      },
                      showCheckmark: false,
                      selectedColor: theme.primaryColor,
                      backgroundColor: theme.cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      side: BorderSide(
                        color: isSelected ? theme.primaryColor : theme.dividerColor,
                        width: 0.5,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Amount Input
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: _frequency == SubscriptionFrequency.daily 
                        ? 'Monto Diario'
                        : (_frequency == SubscriptionFrequency.fortnightly ? 'Monto Quincenal' : 'Monto Mensual'),
                    prefixText: '${widget.defaultCurrency} ',
                    hintText: '0.00',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Por favor escribe un monto';
                    }
                    final amt = double.tryParse(val);
                    if (amt == null || amt <= 0) {
                      return 'Por favor escribe un monto válido mayor a 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Due Day selector (Only show for non-daily)
                if (_frequency != SubscriptionFrequency.daily) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _frequency == SubscriptionFrequency.fortnightly
                              ? 'Día de cobro quincenal:'
                              : 'Día de cobro mensual:',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.textTheme.bodyLarge?.color?.withOpacity(0.8),
                          ),
                        ),
                      ),
                      DropdownButton<int>(
                        value: _frequency == SubscriptionFrequency.fortnightly && _dueDate > 15 ? 1 : _dueDate,
                        dropdownColor: theme.cardColor,
                        underline: const SizedBox(),
                        borderRadius: BorderRadius.circular(8),
                        alignment: Alignment.centerRight,
                        items: List.generate(
                          _frequency == SubscriptionFrequency.fortnightly ? 15 : 31,
                          (index) => index + 1
                        ).map((day) {
                          return DropdownMenuItem<int>(
                            value: day,
                            child: Text(
                              'Día $day',
                              style: const TextStyle(fontSize: 13),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _dueDate = val;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Category Selection
                const Text(
                  'Categoría de Gasto',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 64,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isSelected = _categoryId == cat.id;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _categoryId = cat.id;
                          });
                        },
                        child: Container(
                          width: 80,
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? cat.color.withOpacity(0.15) 
                                : theme.cardColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? cat.color : theme.dividerColor,
                              width: isSelected ? 1.5 : 0.5,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                cat.icon,
                                size: 18,
                                color: isSelected ? cat.color : theme.hintColor,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                cat.name,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  color: isSelected ? theme.textTheme.bodyLarge?.color : theme.hintColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

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
                      child: Text(widget.subscription == null ? 'Agregar' : 'Actualizar'),
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
