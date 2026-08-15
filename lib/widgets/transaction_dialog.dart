import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/category.dart';

class TransactionDialog extends StatefulWidget {
  final TransactionModel? transaction; // If null, we are in "Create" mode
  final String defaultCurrency;
  final VoidCallback? onDelete;

  const TransactionDialog({
    super.key,
    this.transaction,
    required this.defaultCurrency,
    this.onDelete,
  });

  @override
  State<TransactionDialog> createState() => _TransactionDialogState();
}

class _TransactionDialogState extends State<TransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late bool _isIncome;
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  late DateTime _selectedDate;
  late String _categoryId;
  late PaymentMethod _paymentMethod;

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    
    _isIncome = tx?.isIncome ?? false;
    _titleController = TextEditingController(text: tx?.title ?? '');
    _amountController = TextEditingController(
      text: tx != null ? tx.amount.toStringAsFixed(2) : '',
    );
    _notesController = TextEditingController(text: tx?.notes ?? '');
    _selectedDate = tx?.date ?? DateTime.now();
    
    // Set default category
    if (tx != null) {
      _categoryId = tx.categoryId;
    } else {
      _categoryId = _isIncome 
          ? CategoryModel.incomeCategories.first.id 
          : CategoryModel.expenseCategories.first.id;
    }
    
    _paymentMethod = tx?.paymentMethod ?? PaymentMethod.cash;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime(DateTime.now().year + 1),
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
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _onTypeChanged(bool isIncome) {
    setState(() {
      _isIncome = isIncome;
      // Reset category to first matching category
      _categoryId = isIncome 
          ? CategoryModel.incomeCategories.first.id 
          : CategoryModel.expenseCategories.first.id;
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      final tx = TransactionModel(
        id: widget.transaction?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        amount: amount,
        date: _selectedDate,
        categoryId: _categoryId,
        paymentMethod: _isIncome ? PaymentMethod.transfer : _paymentMethod,
        notes: _notesController.text.trim(),
        isIncome: _isIncome,
        currency: widget.transaction?.currency ?? widget.defaultCurrency,
      );
      Navigator.of(context).pop(tx);
    }
  }

  void _confirmDelete(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (innerContext) => AlertDialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.dividerColor, width: 0.5),
        ),
        title: const Text(
          '¿Eliminar transacción?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este registro? Esta acción no se puede deshacer.',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(innerContext),
            child: Text('Cancelar', style: TextStyle(color: theme.hintColor)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(innerContext); // Pop confirm dialog
              Navigator.pop(context); // Pop edit dialog
              if (widget.onDelete != null) {
                widget.onDelete!();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB07D7D),
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = _isIncome 
        ? CategoryModel.incomeCategories 
        : CategoryModel.expenseCategories;

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
        constraints: const BoxConstraints(maxWidth: 420),
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
                      widget.transaction == null ? 'Nuevo Registro' : 'Editar Registro',
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
                const SizedBox(height: 16),
                
                // Toggle Type (Gasto / Ingreso)
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.dividerColor, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _onTypeChanged(false),
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: !_isIncome ? theme.scaffoldBackgroundColor : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Gasto',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: !_isIncome ? FontWeight.w600 : FontWeight.w400,
                                color: !_isIncome ? theme.primaryColor : theme.hintColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _onTypeChanged(true),
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _isIncome ? theme.scaffoldBackgroundColor : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Ingreso',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: _isIncome ? FontWeight.w600 : FontWeight.w400,
                                color: _isIncome ? theme.primaryColor : theme.hintColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Title Input
                TextFormField(
                  controller: _titleController,
                  autofocus: widget.transaction == null,
                  decoration: const InputDecoration(
                    labelText: 'Concepto',
                    hintText: 'Ej. Almuerzo, Gasolina, Sueldo',
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Por favor escribe un concepto';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Amount Input
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Monto',
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

                // Date Picker Button
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
                            Icon(Icons.calendar_month_rounded, size: 18, color: theme.primaryColor),
                            const SizedBox(width: 10),
                            Text(
                              DateFormat('EEEE, d MMMM y', 'es').format(_selectedDate),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                        const Icon(Icons.chevron_right_rounded, size: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Category Selection Grid
                const Text(
                  'Categoría',
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

                // Payment Method (Only for expenses)
                if (!_isIncome) ...[
                  const Text(
                    'Método de Pago',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: PaymentMethod.values.map((method) {
                      final isSelected = _paymentMethod == method;
                      return ChoiceChip(
                        label: Text(
                          method.displayName,
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
                              _paymentMethod = method;
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
                ],

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
                  children: [
                    if (widget.transaction != null && widget.onDelete != null) ...[
                      TextButton.icon(
                        onPressed: () => _confirmDelete(context),
                        icon: const Icon(Icons.delete_outline_rounded, size: 16),
                        label: const Text('Eliminar', style: TextStyle(fontSize: 13)),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFB07D7D), // soft red
                        ),
                      ),
                      const Spacer(),
                    ] else ...[
                      const Spacer(),
                    ],
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.hintColor,
                      ),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: theme.scaffoldBackgroundColor,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(widget.transaction == null ? 'Guardar' : 'Actualizar'),
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
