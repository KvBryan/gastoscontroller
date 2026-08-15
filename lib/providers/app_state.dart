import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/goal.dart';
import '../models/subscription.dart';
import '../models/category.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';

class AppState extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  double _budget = 1000.0;
  String _currency = '\$';
  List<GoalModel> _goals = [];
  List<SubscriptionModel> _subscriptions = [];
  bool _isDarkMode = true;
  bool _useIncomeAsBudget = true;

  // Getters
  List<TransactionModel> get transactions => _transactions;
  double get budget => _useIncomeAsBudget ? (currentQuincenaIncomeTotal > 0 ? currentQuincenaIncomeTotal : _budget) : _budget;
  String get currency => _currency;
  List<GoalModel> get goals => _goals;
  List<SubscriptionModel> get subscriptions => _subscriptions;
  bool get isDarkMode => _isDarkMode;
  bool get useIncomeAsBudget => _useIncomeAsBudget;

  AppState() {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    _transactions = StorageService.getTransactions();
    _budget = StorageService.getBudget();
    _currency = StorageService.getCurrency();
    _goals = StorageService.getGoals();
    _subscriptions = StorageService.getSubscriptions();
    _isDarkMode = StorageService.isDarkMode();
    _useIncomeAsBudget = StorageService.getUseIncomeAsBudget();
    notifyListeners();
  }

  // Setters & Actions

  // Theme
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    StorageService.saveThemeMode(_isDarkMode);
    notifyListeners();
  }

  // Currency
  void setCurrency(String newCurrency) {
    _currency = newCurrency;
    StorageService.saveCurrency(newCurrency);
    // Update currency in goals and subscriptions
    _goals = _goals.map((g) => GoalModel(
      id: g.id,
      title: g.title,
      targetAmount: g.targetAmount,
      currentAmount: g.currentAmount,
      deadline: g.deadline,
      notes: g.notes,
      currency: newCurrency,
    )).toList();
    StorageService.saveGoals(_goals);

    _subscriptions = _subscriptions.map((s) => SubscriptionModel(
      id: s.id,
      title: s.title,
      amount: s.amount,
      categoryId: s.categoryId,
      dueDate: s.dueDate,
      notes: s.notes,
      isActive: s.isActive,
      currency: newCurrency,
      frequency: s.frequency,
    )).toList();
    StorageService.saveSubscriptions(_subscriptions);

    notifyListeners();
  }

  // Budget
  void setBudget(double amount) {
    _budget = amount;
    StorageService.saveBudget(amount);
    notifyListeners();
  }

  void setUseIncomeAsBudget(bool value) {
    _useIncomeAsBudget = value;
    StorageService.saveUseIncomeAsBudget(value);
    notifyListeners();
  }

  // Transactions
  void addTransaction(TransactionModel tx) {
    _transactions.insert(0, tx);
    StorageService.saveTransactions(_transactions);
    notifyListeners();
  }

  void editTransaction(TransactionModel updatedTx) {
    final index = _transactions.indexWhere((tx) => tx.id == updatedTx.id);
    if (index != -1) {
      _transactions[index] = updatedTx;
      StorageService.saveTransactions(_transactions);
      notifyListeners();
    }
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((tx) => tx.id == id);
    StorageService.saveTransactions(_transactions);
    notifyListeners();
  }

  // Goals
  void addGoal(GoalModel goal) {
    _goals.add(goal);
    StorageService.saveGoals(_goals);
    notifyListeners();
  }

  void editGoal(GoalModel updatedGoal) {
    final index = _goals.indexWhere((g) => g.id == updatedGoal.id);
    if (index != -1) {
      _goals[index] = updatedGoal;
      StorageService.saveGoals(_goals);
      notifyListeners();
    }
  }

  void deleteGoal(String id) {
    _goals.removeWhere((g) => g.id == id);
    StorageService.saveGoals(_goals);
    notifyListeners();
  }

  void addSavingsToGoal(String id, double amount) {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index != -1) {
      final goal = _goals[index];
      // We limit to targetAmount or just allow exceeding
      final newAmount = goal.currentAmount + amount;
      _goals[index] = GoalModel(
        id: goal.id,
        title: goal.title,
        targetAmount: goal.targetAmount,
        currentAmount: newAmount,
        deadline: goal.deadline,
        notes: goal.notes,
        currency: goal.currency,
      );

      // Create a transaction automatically as an expense categorized under "Otros" / "Ahorro" 
      // with a note referring to the goal
      addTransaction(TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Ahorro: ${goal.title}',
        amount: amount,
        date: DateTime.now(),
        categoryId: 'other',
        paymentMethod: PaymentMethod.transfer,
        notes: 'Aportación a la meta de ahorro: "${goal.title}"',
        isIncome: false,
        currency: _currency,
      ));

      StorageService.saveGoals(_goals);
      notifyListeners();
    }
  }

  // Subscriptions
  void addSubscription(SubscriptionModel sub) {
    _subscriptions.add(sub);
    StorageService.saveSubscriptions(_subscriptions);
    notifyListeners();
  }

  void editSubscription(SubscriptionModel updatedSub) {
    final index = _subscriptions.indexWhere((s) => s.id == updatedSub.id);
    if (index != -1) {
      _subscriptions[index] = updatedSub;
      StorageService.saveSubscriptions(_subscriptions);
      notifyListeners();
    }
  }

  void deleteSubscription(String id) {
    _subscriptions.removeWhere((s) => s.id == id);
    StorageService.saveSubscriptions(_subscriptions);
    notifyListeners();
  }

  void toggleSubscriptionActive(String id) {
    final index = _subscriptions.indexWhere((s) => s.id == id);
    if (index != -1) {
      final sub = _subscriptions[index];
      _subscriptions[index] = SubscriptionModel(
        id: sub.id,
        title: sub.title,
        amount: sub.amount,
        categoryId: sub.categoryId,
        dueDate: sub.dueDate,
        notes: sub.notes,
        isActive: !sub.isActive,
        currency: sub.currency,
        frequency: sub.frequency,
      );
      StorageService.saveSubscriptions(_subscriptions);
      notifyListeners();
    }
  }

  // Helper Calculations (Current Quincena)
  
  DateTime get quincenaStartDate {
    final now = DateTime.now();
    if (now.day <= 15) {
      return DateTime(now.year, now.month, 1);
    } else {
      return DateTime(now.year, now.month, 16);
    }
  }

  DateTime get quincenaEndDate {
    final now = DateTime.now();
    if (now.day <= 15) {
      return DateTime(now.year, now.month, 15);
    } else {
      return DateTime(now.year, now.month + 1, 0); // Last day of month
    }
  }

  String get quincenaName {
    final now = DateTime.now();
    final monthName = DateFormat('MMMM', 'es').format(now);
    final capitalizedMonth = monthName[0].toUpperCase() + monthName.substring(1);
    if (now.day <= 15) {
      return '1ª Quincena de $capitalizedMonth';
    } else {
      return '2ª Quincena de $capitalizedMonth';
    }
  }

  List<TransactionModel> get currentQuincenaTransactions {
    final start = quincenaStartDate;
    final end = quincenaEndDate;
    return _transactions.where((tx) {
      final txDateOnly = DateTime(tx.date.year, tx.date.month, tx.date.day);
      return (txDateOnly.isAtSameMomentAs(start) || txDateOnly.isAfter(start)) &&
             (txDateOnly.isAtSameMomentAs(end) || txDateOnly.isBefore(end));
    }).toList();
  }

  double get currentQuincenaExpensesTotal {
    return currentQuincenaTransactions
        .where((tx) => !tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get currentQuincenaIncomeTotal {
    return currentQuincenaTransactions
        .where((tx) => tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get currentQuincenaAvailableSavings {
    final net = currentQuincenaIncomeTotal - currentQuincenaExpensesTotal;
    return net > 0 ? net : 0.0;
  }

  double get remainingQuincenaBudget {
    return _budget - currentQuincenaExpensesTotal;
  }

  double get quincenaBudgetProgressPercentage {
    if (_budget <= 0) return 0.0;
    return (currentQuincenaExpensesTotal / _budget).clamp(0.0, 1.0);
  }

  Map<CategoryModel, double> get categoryExpensesBreakdownQuincena {
    final Map<CategoryModel, double> breakdown = {};
    final quincenaExpenses = currentQuincenaTransactions.where((tx) => !tx.isIncome);

    for (var tx in quincenaExpenses) {
      final category = CategoryModel.getById(tx.categoryId);
      breakdown[category] = (breakdown[category] ?? 0.0) + tx.amount;
    }

    return breakdown;
  }

  double get activeSubscriptionsTotalQuincenal {
    double total = 0.0;
    final start = quincenaStartDate;
    final end = quincenaEndDate;
    final int daysInQuincena = end.difference(start).inDays + 1;
    
    for (var s in _subscriptions) {
      if (!s.isActive) continue;
      
      if (s.frequency == SubscriptionFrequency.daily) {
        total += s.amount * daysInQuincena;
      } else if (s.frequency == SubscriptionFrequency.weekly) {
        int occurrences = 0;
        DateTime temp = start;
        while (temp.isBefore(end) || temp.isAtSameMomentAs(end)) {
          if (temp.weekday == s.dueDate) {
            occurrences++;
          }
          temp = temp.add(const Duration(days: 1));
        }
        total += s.amount * occurrences;
      } else if (s.frequency == SubscriptionFrequency.fortnightly) {
        total += s.amount;
      } else if (s.frequency == SubscriptionFrequency.monthly) {
        if (s.dueDate == 32) {
          // "Fin de mes" is always in the second quincena of the month (starts day 16)
          if (start.day >= 16) {
            total += s.amount;
          }
        } else {
          // Handle cases where the month has fewer days than the s.dueDate (e.g. Feb 28, but dueDate is 30)
          int effectiveDueDate = s.dueDate;
          final lastDayOfMonth = DateTime(start.year, start.month + 1, 0).day;
          if (effectiveDueDate > lastDayOfMonth) {
            effectiveDueDate = lastDayOfMonth;
          }
          
          if (effectiveDueDate >= start.day && effectiveDueDate <= end.day) {
            total += s.amount;
          }
        }
      }
    }
    return total;
  }

  // CSV Exporter
  String exportToCSV() {
    final buffer = StringBuffer();
    // Headers
    buffer.writeln('ID,Concepto,Monto,Fecha,Categoria,MetodoPago,Tipo,Notas,Moneda');
    
    for (var tx in _transactions) {
      final category = CategoryModel.getById(tx.categoryId).name;
      final type = tx.isIncome ? 'Ingreso' : 'Gasto';
      final formattedDate = '${tx.date.year}-${tx.date.month.toString().padLeft(2, '0')}-${tx.date.day.toString().padLeft(2, '0')}';
      final notesCleaned = tx.notes.replaceAll('"', '""');
      
      buffer.writeln(
        '"${tx.id}","${tx.title}",${tx.amount},"$formattedDate","$category","${tx.paymentMethod.displayName}","$type","${notesCleaned}","${tx.currency}"'
      );
    }
    return buffer.toString();
  }

  // Import from CSV
  bool importFromCSV(String csvContent) {
    try {
      final lines = csvContent.split('\n');
      if (lines.isEmpty || lines.length < 2) return false;

      final List<TransactionModel> importedTxs = [];
      
      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        final parts = _parseCSVLine(line);
        if (parts.length < 8) continue;

        final id = parts[0].isNotEmpty ? parts[0] : DateTime.now().millisecondsSinceEpoch.toString() + i.toString();
        final title = parts[1];
        final amount = double.tryParse(parts[2]) ?? 0.0;
        final date = DateTime.tryParse(parts[3]) ?? DateTime.now();
        
        final catName = parts[4].toLowerCase();
        String catId = 'other';
        for (var cat in CategoryModel.all) {
          if (cat.name.toLowerCase() == catName) {
            catId = cat.id;
            break;
          }
        }

        PaymentMethod pm = PaymentMethod.cash;
        final pmName = parts[5].toLowerCase();
        if (pmName.contains('tarjeta')) pm = PaymentMethod.card;
        if (pmName.contains('transferencia')) pm = PaymentMethod.transfer;

        final isIncome = parts[6].toLowerCase() == 'ingreso';
        final notes = parts[7];
        final currency = parts.length > 8 ? parts[8] : _currency;

        importedTxs.add(TransactionModel(
          id: id,
          title: title,
          amount: amount,
          date: date,
          categoryId: catId,
          paymentMethod: pm,
          notes: notes,
          isIncome: isIncome,
          currency: currency,
        ));
      }

      if (importedTxs.isNotEmpty) {
        final existingIds = _transactions.map((tx) => tx.id).toSet();
        final List<TransactionModel> newTxs = [];
        
        for (var tx in importedTxs) {
          if (!existingIds.contains(tx.id)) {
            newTxs.add(tx);
          }
        }
        
        _transactions.insertAll(0, newTxs);
        StorageService.saveTransactions(_transactions);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error importing CSV: $e');
      return false;
    }
  }

  List<String> _parseCSVLine(String line) {
    List<String> result = [];
    bool inQuotes = false;
    StringBuffer currentField = StringBuffer();

    for (int i = 0; i < line.length; i++) {
      String char = line[i];
      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          currentField.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        result.add(currentField.toString());
        currentField.clear();
      } else {
        currentField.write(char);
      }
    }
    result.add(currentField.toString());
    return result;
  }

  // Financial Health Insights Engine
  List<String> get financialInsights {
    final List<String> insights = [];
    final expenses = currentQuincenaExpensesTotal;
    final income = currentQuincenaIncomeTotal;
    
    // Budget limit insight
    if (_budget > 0) {
      final percentage = (expenses / _budget) * 100;
      if (percentage >= 100) {
        insights.add('⚠️ Has excedido tu presupuesto quincenal por ${(expenses - _budget).toStringAsFixed(2)} $_currency.');
      } else if (percentage >= 85) {
        insights.add('⚠️ Estás a punto de alcanzar tu límite quincenal (consumido ${percentage.toStringAsFixed(0)}%).');
      } else if (percentage > 50) {
        insights.add('ℹ️ Has consumido el ${percentage.toStringAsFixed(0)}% de tu presupuesto quincenal. Aún te quedan ${(remainingQuincenaBudget).toStringAsFixed(2)} $_currency.');
      } else if (expenses > 0) {
        insights.add('👍 Excelente control. Has gastado un moderado ${percentage.toStringAsFixed(0)}% de tu presupuesto quincenal.');
      }
    }

    // Top Category insight
    final breakdown = categoryExpensesBreakdownQuincena;
    if (breakdown.isNotEmpty) {
      CategoryModel? topCat;
      double topAmount = -1;
      breakdown.forEach((cat, amt) {
        if (amt > topAmount) {
          topAmount = amt;
          topCat = cat;
        }
      });
      if (topCat != null && topAmount > 0) {
        final share = (topAmount / expenses) * 100;
        insights.add('📊 Tu mayor gasto esta quincena es en la categoría *${topCat!.name}* (${topAmount.toStringAsFixed(2)} $_currency), representando el ${share.toStringAsFixed(0)}% de tus salidas.');
      }
    }

    // Balance insight
    if (income > 0) {
      final savingsRate = ((income - expenses) / income) * 100;
      if (savingsRate > 20) {
        insights.add('💰 Tu tasa de ahorro en esta quincena es de ${savingsRate.toStringAsFixed(0)}%. ¡Un excelente número!');
      } else if (savingsRate < 0) {
        insights.add('🚨 Atención: Estás gastando más de tu sueldo quincenal (${(expenses - income).toStringAsFixed(2)} $_currency de déficit).');
      }
    }

    // Subscriptions insight
    final activeSubsCount = _subscriptions.where((s) => s.isActive).length;
    if (activeSubsCount > 0) {
      final subCost = activeSubscriptionsTotalQuincenal;
      insights.add('🔄 Tienes $activeSubsCount suscripciones activas, con un gasto fijo estimado esta quincena de ${subCost.toStringAsFixed(2)} $_currency.');
    }

    if (insights.isEmpty) {
      insights.add('✨ Empieza a registrar tus gastos e ingresos diarios para recibir análisis de salud financiera.');
    }

    return insights;
  }
}
