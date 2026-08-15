import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final bool isIncome;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.isIncome,
  });

  // Predefined lists
  static const List<CategoryModel> expenseCategories = [
    CategoryModel(
      id: 'food',
      name: 'Comida',
      icon: Icons.restaurant_rounded,
      color: Color(0xFFC7A287), // Terracotta/Warm Clay
      isIncome: false,
    ),
    CategoryModel(
      id: 'transport',
      name: 'Transporte',
      icon: Icons.directions_transit_rounded,
      color: Color(0xFF8A9A86), // Sage green
      isIncome: false,
    ),
    CategoryModel(
      id: 'services',
      name: 'Servicios',
      icon: Icons.home_work_rounded,
      color: Color(0xFF7A8C99), // Slate blue
      isIncome: false,
    ),
    CategoryModel(
      id: 'entertainment',
      name: 'Entretenimiento',
      icon: Icons.local_play_rounded,
      color: Color(0xFF9E8FA9), // Muted lavender
      isIncome: false,
    ),
    CategoryModel(
      id: 'health',
      name: 'Salud',
      icon: Icons.favorite_rounded,
      color: Color(0xFFB07D7D), // Muted red/coral
      isIncome: false,
    ),
    CategoryModel(
      id: 'shopping',
      name: 'Compras',
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFFBCA374), // Muted gold/bronze
      isIncome: false,
    ),
    CategoryModel(
      id: 'education',
      name: 'Educación',
      icon: Icons.school_rounded,
      color: Color(0xFF7E8497), // Steel grey-blue
      isIncome: false,
    ),
    CategoryModel(
      id: 'other',
      name: 'Otros',
      icon: Icons.category_rounded,
      color: Color(0xFF9E9E9E), // Soft grey
      isIncome: false,
    ),
  ];

  static const List<CategoryModel> incomeCategories = [
    CategoryModel(
      id: 'salary',
      name: 'Sueldo',
      icon: Icons.payments_rounded,
      color: Color(0xFF6F8F72), // Forest sage green
      isIncome: true,
    ),
    CategoryModel(
      id: 'freelance',
      name: 'Freelance',
      icon: Icons.devices_rounded,
      color: Color(0xFF7C8EA6), // Denim steel
      isIncome: true,
    ),
    CategoryModel(
      id: 'extra',
      name: 'Ingreso Extra',
      icon: Icons.add_card_rounded,
      color: Color(0xFFB392AC), // Dusky rose
      isIncome: true,
    ),
  ];

  static List<CategoryModel> get all => [...expenseCategories, ...incomeCategories];

  static CategoryModel getById(String id) {
    return all.firstWhere(
      (cat) => cat.id == id,
      orElse: () => const CategoryModel(
        id: 'other',
        name: 'Otros',
        icon: Icons.category_rounded,
        color: Color(0xFF9E9E9E),
        isIncome: false,
      ),
    );
  }
}
