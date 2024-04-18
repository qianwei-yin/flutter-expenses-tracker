import 'package:flutter/material.dart';

import 'package:final_project/models/category.dart';

const categories = {
  Categories.clothes: Category(
    'Clothes',
    Icon(Icons.checkroom, color: Color(0xfff87171)),
  ),
  Categories.restaurant: Category(
    'Restaurant',
    Icon(Icons.restaurant, color: Color(0xfff87171)),
  ),
  Categories.entertainment: Category(
    'Entertainment',
    Icon(Icons.sports_esports, color: Color(0xfff87171)),
  ),
  Categories.gas: Category(
    'Gas',
    Icon(Icons.local_gas_station, color: Color(0xfff87171)),
  ),
  Categories.gift: Category(
    'Gift',
    Icon(Icons.card_giftcard, color: Color(0xfff87171)),
  ),
  Categories.travel: Category(
    'Travel',
    Icon(Icons.flight_takeoff, color: Color(0xfff87171)),
  ),
  Categories.kids: Category(
    'Kids',
    Icon(Icons.escalator_warning, color: Color(0xfff87171)),
  ),
  Categories.shopping: Category(
    'Shopping',
    Icon(Icons.shopping_cart, color: Color(0xfff87171)),
  ),
  Categories.sports: Category(
    'Sports',
    Icon(Icons.sports_martial_arts, color: Color(0xfff87171)),
  ),
  Categories.transportation: Category(
    'Transportation',
    Icon(Icons.train, color: Color(0xfff87171)),
  ),
  Categories.otherExpenses: Category(
    'Other Expenses',
    Icon(Icons.attach_money, color: Color(0xfff87171)),
  ),
  Categories.transfer: Category(
    'Transfer',
    Icon(Icons.currency_exchange, color: Color(0xffa3e635)),
  ),
  Categories.salary: Category(
    'Salary',
    Icon(Icons.credit_score, color: Color(0xffa3e635)),
  ),
  Categories.otherIncome: Category(
    'Other Income',
    Icon(Icons.savings, color: Color(0xffa3e635)),
  ),
};
