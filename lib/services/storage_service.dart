import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import '../models/goal.dart';
import '../models/subscription.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static const String _keyTransactions = 'transactions';
  static const String _keyBudget = 'monthly_budget';
  static const String _keyCurrency = 'local_currency';
  static const String _keyGoals = 'savings_goals';
  static const String _keySubscriptions = 'subscriptions';
  static const String _keyDarkMode = 'is_dark_mode';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Transactions
  static List<TransactionModel> getTransactions() {
    if (_prefs == null) return [];
    final List<String>? jsonList = _prefs!.getStringList(_keyTransactions);
    if (jsonList == null) return [];
    return jsonList.map((item) => TransactionModel.fromJson(item)).toList();
  }

  static Future<void> saveTransactions(List<TransactionModel> transactions) async {
    if (_prefs == null) return;
    final List<String> jsonList = transactions.map((tx) => tx.toJson()).toList();
    await _prefs!.setStringList(_keyTransactions, jsonList);
  }

  // Budget
  static double getBudget() {
    if (_prefs == null) return 1000.0; // Default budget if not set
    return _prefs!.getDouble(_keyBudget) ?? 1000.0;
  }

  static Future<void> saveBudget(double budget) async {
    if (_prefs == null) return;
    await _prefs!.setDouble(_keyBudget, budget);
  }

  // Currency
  static String getCurrency() {
    if (_prefs == null) return '\$';
    return _prefs!.getString(_keyCurrency) ?? '\$';
  }

  static Future<void> saveCurrency(String currency) async {
    if (_prefs == null) return;
    await _prefs!.setString(_keyCurrency, currency);
  }

  // Savings Goals
  static List<GoalModel> getGoals() {
    if (_prefs == null) return [];
    final List<String>? jsonList = _prefs!.getStringList(_keyGoals);
    if (jsonList == null) return [];
    return jsonList.map((item) => GoalModel.fromJson(item)).toList();
  }

  static Future<void> saveGoals(List<GoalModel> goals) async {
    if (_prefs == null) return;
    final List<String> jsonList = goals.map((g) => g.toJson()).toList();
    await _prefs!.setStringList(_keyGoals, jsonList);
  }

  // Subscriptions
  static List<SubscriptionModel> getSubscriptions() {
    if (_prefs == null) return [];
    final List<String>? jsonList = _prefs!.getStringList(_keySubscriptions);
    if (jsonList == null) return [];
    return jsonList.map((item) => SubscriptionModel.fromJson(item)).toList();
  }

  static Future<void> saveSubscriptions(List<SubscriptionModel> subscriptions) async {
    if (_prefs == null) return;
    final List<String> jsonList = subscriptions.map((s) => s.toJson()).toList();
    await _prefs!.setStringList(_keySubscriptions, jsonList);
  }

  // Dark Mode Setting
  static bool isDarkMode() {
    if (_prefs == null) return true; // Default to dark mode as requested
    return _prefs!.getBool(_keyDarkMode) ?? true;
  }

  static Future<void> saveThemeMode(bool isDark) async {
    if (_prefs == null) return;
    await _prefs!.setBool(_keyDarkMode, isDark);
  }
}
