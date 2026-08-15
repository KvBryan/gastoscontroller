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
  late List<int> _selectedWeekdays;
  late bool _allWeekdays;
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
    _selectedWeekdays = sub != null ? List<int>.from(sub.weekdays) : [];
    _allWeekdays = _selectedWeekdays.length == 7;
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
        weekdays: _frequency == SubscriptionFrequency.weekly ? _selectedWeekdays : [],
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
                            if (freq == SubscriptionFrequency.weekly) {
                              if (_selectedWeekdays.isEmpty) {
                                _selectedWeekdays = [DateTime.now().weekday];
                              }
                              _allWeekdays = _selectedWeekdays.length == 7;
                            } else if (freq == SubscriptionFrequency.fortnightly) {
                              if (_dueDate < 1 || _dueDate > 15) _dueDate = 1;
                            } else if (freq == SubscriptionFrequency.monthly) {
                              if (_dueDate < 1 || _dueDate > 32) _dueDate = 1;
                            }
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
                    labelText: () {
                      if (_frequency == SubscriptionFrequency.daily) return 'Monto Diario';
                      if (_frequency == SubscriptionFrequency.weekly) return 'Monto Semanal';
                      if (_frequency == SubscriptionFrequency.fortnightly) return 'Monto Quincenal';
                      return 'Monto Mensual';
                    }(),
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

                // Due Day/Weekdays selector
                if (_frequency != SubscriptionFrequency.daily) ...[
                  if (_frequency == SubscriptionFrequency.weekly) ...[
                    const Text(
                      'Días de cobro semanal:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    StatefulBuilder(
                      builder: (context, setDialogState) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _allWeekdays = !_allWeekdays;
                                  if (_allWeekdays) {
                                    _selectedWeekdays = [1, 2, 3, 4, 5, 6, 7];
                                  } else {
                                    _selectedWeekdays = [DateTime.now().weekday];
                                  }
                                });
                                setDialogState(() {});
                              },
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Checkbox(
                                        value: _allWeekdays,
                                        activeColor: theme.primaryColor,
                                        onChanged: (val) {
                                          setState(() {
                                            _allWeekdays = val ?? false;
                                            if (_allWeekdays) {
                                              _selectedWeekdays = [1, 2, 3, 4, 5, 6, 7];
                                            } else {
                                              _selectedWeekdays = [DateTime.now().weekday];
                                            }
                                          });
                                          setDialogState(() {});
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Todos los días de la semana',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (!_allWeekdays) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6.0,
                                runSpacing: 6.0,
                                children: List.generate(7, (index) {
                                  final dayNum = index + 1;
                                  final isSelected = _selectedWeekdays.contains(dayNum);
                                  return FilterChip(
                                    label: Text(
                                      ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'][index],
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
                                      setState(() {
                                        if (selected) {
                                          _selectedWeekdays.add(dayNum);
                                        } else {
                                          if (_selectedWeekdays.length > 1) {
                                            _selectedWeekdays.remove(dayNum);
                                          }
                                        }
                                        _allWeekdays = _selectedWeekdays.length == 7;
                                      });
                                      setDialogState(() {});
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
                                }),
                              ),
                            ],
                          ],
                        );
                      }
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
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
                          value: () {
                            if (_frequency == SubscriptionFrequency.fortnightly) {
                              return (_dueDate >= 1 && _dueDate <= 15) ? _dueDate : 1;
                            } else {
                              return (_dueDate >= 1 && _dueDate <= 32) ? _dueDate : 1;
                            }
                          }(),
                          dropdownColor: theme.cardColor,
                          underline: const SizedBox(),
                          borderRadius: BorderRadius.circular(8),
                          alignment: Alignment.centerRight,
                          items: () {
                            if (_frequency == SubscriptionFrequency.fortnightly) {
                              return List.generate(15, (index) {
                                final dayNum = index + 1;
                                return DropdownMenuItem<int>(
                                  value: dayNum,
                                  child: Text(
                                    'Día $dayNum',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                );
                              });
                            } else {
                              final list = List.generate(31, (index) {
                                final dayNum = index + 1;
                                return DropdownMenuItem<int>(
                                  value: dayNum,
                                  child: Text(
                                    'Día $dayNum',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                );
                              });
                              list.add(
                                const DropdownMenuItem<int>(
                                  value: 32,
                                  child: Text(
                                    'Fin de mes',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              );
                              return list;
                            }
                          }(),
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
