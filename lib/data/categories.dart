import 'package:flutter/material.dart';

import 'package:final_project/models/category.dart';

const categories = {
  Categories.clothes: Category(
    'Clothes',
    Icon(Icons.checkroom),
  ),
  Categories.restaurant: Category(
    'Restaurant',
    Icon(Icons.restaurant),
  ),
  Categories.entertainment: Category(
    'Entertainment',
    Icon(Icons.sports_esports),
  ),
  Categories.gas: Category(
    'Gas',
    Icon(Icons.local_gas_station),
  ),
  Categories.gift: Category(
    'Gift',
    Icon(Icons.card_giftcard),
  ),
  Categories.travel: Category(
    'Travel',
    Icon(Icons.flight_takeoff),
  ),
  Categories.kids: Category(
    'Kids',
    Icon(Icons.escalator_warning),
  ),
  Categories.shopping: Category(
    'Shopping',
    Icon(Icons.shopping_cart),
  ),
  Categories.sports: Category(
    'Sports',
    Icon(Icons.sports_martial_arts),
  ),
  Categories.transportation: Category(
    'Transportation',
    Icon(Icons.train),
  ),
  Categories.otherExpenses: Category(
    'Other Expenses',
    Icon(Icons.attach_money),
  ),
  Categories.transfer: Category(
    'Transfer',
    Icon(Icons.currency_exchange),
  ),
  Categories.salary: Category(
    'Salary',
    Icon(Icons.credit_score),
  ),
  Categories.otherIncome: Category(
    'Other Income',
    Icon(Icons.savings),
  ),
};
