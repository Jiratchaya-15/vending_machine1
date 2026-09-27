import 'package:flutter/material.dart';

import 'screen.dart';

/// App
class VendingApp extends StatelessWidget {
  const VendingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthyVend',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 217, 47, 180)),
        scaffoldBackgroundColor: AppColors.bg,
      ),
      home: const VendingScreen(),
    );
  }
}

/// Color tokens
class AppColors {
  static const bg = Color(0xFFEFEBE0);
  static const paper = Color(0xFFFCFBF7);
  static const ink = Color(0xFF17241D);
  static const inkSoft = Color(0xFF4B5A50);
  static const forest = Color(0xFF1F4B3F);
  static const forestDark = Color(0xFF16362D);
  static const sage = Color(0xFF8FAE93);
  static const sageSoft = Color(0xFFE4EDDF);
  static const mango = Color(0xFFE2A33B);
  static const berry = Color(0xFFB84B4B);
  static const berrySoft = Color(0xFFF7E4E1);
  static const line = Color(0xFFDCD5C2);
}

/// Products & categories
enum Cat { drink, snack, dried }

class CategoryInfo {
  final Cat id;
  final String name;
  final String icon; 
  final String image; 
  final String desc;
  const CategoryInfo(this.id, this.name, this.icon, this.image, this.desc);
}

class Product {
  final String id;
  final Cat cat;
  final String name;
  final String icon; 
  final String image; 
  final int price;
  const Product(this.id, this.cat, this.name, this.icon, this.image, this.price);
}
const List<CategoryInfo> kCategories = [
  CategoryInfo(Cat.drink, 'เครื่องดื่ม', '🧃', 'assets/images/category_drink.jpg', '15–35 บาท'),
  CategoryInfo(Cat.snack, 'โปรตีน & ของว่าง', '💪', 'assets/images/category_snack.jpg', '20–42 บาท'),
  CategoryInfo(Cat.dried, 'ผลไม้อบแห้ง', '🍓', 'assets/images/category_dried.jpg', '22–35 บาท'),
];

const List<Product> kProducts = [
  Product('p1', Cat.drink, 'ชาเขียว', '🍵', 'assets/images/green_tea.jpg', 20),
  Product('p2', Cat.drink, 'กาแฟดำ', '☕', 'assets/images/black_coffee.jpg', 18),
  Product('p3', Cat.drink, 'น้ำแร่', '💧', 'assets/images/mineral_water.jpg', 15),
  Product('p4', Cat.drink, 'นมอัลมอนด์', '🥛', 'assets/images/almond_milk.jpg', 28),
  Product('p5', Cat.drink, 'น้ำผลไม้', '🧃', 'assets/images/fruit_juice.jpg', 25),
  Product('p6', Cat.drink, 'น้ำมะพร้าว', '🥥', 'assets/images/coconut_water.jpg', 32),
  Product('p7', Cat.snack, 'โปรตีนบาร์', '🍫', 'assets/images/protein_bar.jpg', 42),
  Product('p8', Cat.snack, 'คุกกี้', '🍪', 'assets/images/cookie.jpg', 22),
  Product('p9', Cat.snack, 'ธัญพืชอบแห้ง', '🌾', 'assets/images/granola.jpg', 35),
  Product('p10', Cat.dried, 'สตอเบอร์รี่อบแห้ง', '🍓', 'assets/images/dried_strawberry.jpg', 32),
  Product('p11', Cat.dried, 'มะม่วงอบแห้ง', '🥭', 'assets/images/dried_mango.jpg', 28),
  Product('p12', Cat.dried, 'บลูเบอร์รี่อบแห้ง', '🫐', 'assets/images/dried_blueberry.jpg', 35),
];

/// Purchase flow steps, in order
enum AppStep { category, products, cart, payMethod, qr, success }

const List<AppStep> kStepOrder = [
  AppStep.category,
  AppStep.products,
  AppStep.cart,
  AppStep.payMethod,
  AppStep.qr,
  AppStep.success,
];