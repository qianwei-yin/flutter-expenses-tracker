import 'package:flutter/material.dart';

enum Categories {
  clothes,
  restaurant,
  entertainment,
  gas,
  gift,
  travel,
  kids,
  shopping,
  sports,
  transportation,
  otherExpenses,
  transfer,
  salary,
  otherIncome,
}

class Category {
  const Category(this.title, this.icon);

  final String title;
  final Icon icon;
}
