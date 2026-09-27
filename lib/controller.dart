import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'core.dart';

class VendingController extends ChangeNotifier {
  final Map<String, int> stock = {};
  final Map<String, int> cart = {};
  final Set<String> notified = {};
  final List<String> toasts = [];
  final List<Map<String, dynamic>> dispensedSnapshot = [];
  final TextEditingController phoneController = TextEditingController();

  AppStep step = AppStep.category;
  Cat? activeCat;
  String phone = '';
  int points = 0;
  String payLabel = '';
  int earnedPoints = 0;
  double dispenseProgress = 0;
  Timer? _dispenseTimer;

  VendingController() {
    const seeds = [6, 2, 8, 1, 5, 7, 4, 0, 9, 2, 6, 5];
    for (var i = 0; i < kProducts.length; i++) {
      stock[kProducts[i].id] = seeds[i];
    }
  }

  @override
  void dispose() {
    _dispenseTimer?.cancel();
    phoneController.dispose();
    super.dispose();
  }

  /// derived values
  int cartCount() => cart.values.fold(0, (a, b) => a + b);
  int cartTotal() {
    var sum = 0;
    cart.forEach((id, qty) => sum += productById(id).price * qty);
    return sum;
  }
  Product productById(String id) => kProducts.firstWhere((p) => p.id == id);

  /// navigation 
  void goTo(AppStep target) {
    step = target;
    notifyListeners();
  }
  void goCategory() => goTo(AppStep.category);
  void selectCategory(Cat cat) {
    activeCat = cat;
    step = AppStep.products;
    notifyListeners();
  }
  void selectPayment(String label) {
    phone = phoneController.text.trim();
    payLabel = label;
    step = AppStep.qr;
    notifyListeners();
  }

  ///toasts / alerts 
  void _pushToast(String text) => toasts.add(text);
  void _checkLowStock(String id) {
    final p = productById(id);
    final left = stock[id] ?? 0;
    if (left > 0 && left < 3 && !notified.contains(id)) {
      notified.add(id);
      _pushToast('🔔 แจ้งทีมเติมสินค้าอัตโนมัติ: "${p.name}" เหลือ $left ชิ้น');
    }
  }

  ///cart mutations 
  void inc(String id) {
    final left = stock[id] ?? 0;
    final have = cart[id] ?? 0;
    if (have < left) {
      cart[id] = have + 1;
      notifyListeners();
    }
  }
  void dec(String id) {
    final have = cart[id] ?? 0;
    cart[id] = max(0, have - 1);
    notifyListeners();
  }
  void removeFromCart(String id) {
    cart.remove(id);
    notifyListeners();
  }

  void simulateSuddenSoldOut() {
    final ids = cart.keys.where((id) => (cart[id] ?? 0) > 0).toList();
    if (ids.isEmpty) return;
    final id = ids[Random().nextInt(ids.length)];
    final p = productById(id);
    final removedQty = cart[id]!;
    stock[id] = 0;
    cart.remove(id);
    toasts.clear();
    Product? alt;
    for (final x in kProducts) {
      if (x.cat == p.cat && x.id != id && (stock[x.id] ?? 0) > 0) {
        alt = x;
        break;
      }
    }
    final altText = alt != null
        ? ' แนะนำสินค้าใกล้เคียง: ${alt.icon} ${alt.name} (${alt.price}฿)'
        : ' ขออภัย ไม่มีสินค้าใกล้เคียงเหลืออยู่ในหมวดนี้';
    _pushToast(
      '⚠️ ขออภัย "${p.name}" $removedQty ชิ้นหมดสต๊อกพอดี — ไม่มีการตัดเงินสำหรับรายการนี้$altText',
    );
    notifyListeners();
  }

  ///QR pattern (decorative) 
  List<bool> qrPattern() {
    final seed = cartTotal() + payLabel.length;
    final rand = Random(seed == 0 ? 1 : seed);
    final cells = List.generate(121, (_) => rand.nextDouble() > 0.52);
    for (final i in [0, 1, 2, 11, 12, 13, 22, 23, 24]) {
      cells[i] = true;
    }
    return cells;
  }

  /// payment + dispensing 
  void confirmPayment() {
    final snapshot = <Map<String, dynamic>>[];
    var total = 0;
    cart.forEach((id, qty) {
      if (qty <= 0) return;
      final p = productById(id);
      stock[id] = max(0, (stock[id] ?? 0) - qty);
      snapshot.add({'product': p, 'qty': qty});
      total += p.price * qty;
    });
    for (final id in cart.keys) {
      _checkLowStock(id);
    }
    dispensedSnapshot
      ..clear()
      ..addAll(snapshot);
    earnedPoints = phone.isNotEmpty ? (total ~/ 10) : 0;
    points += earnedPoints;
    cart.clear();
    toasts.clear();
    step = AppStep.success;
    dispenseProgress = 0;
    notifyListeners();
    _runDispenseAnimation();
  }
  void _runDispenseAnimation() {
    _dispenseTimer?.cancel();
    final durationMs = 5000 + Random().nextInt(5000); // 5–10s per spec
    final start = DateTime.now().millisecondsSinceEpoch;
    _dispenseTimer = Timer.periodic(const Duration(milliseconds: 60), (t) {
      final now = DateTime.now().millisecondsSinceEpoch;
      dispenseProgress = ((now - start) / durationMs).clamp(0.0, 1.0);
      notifyListeners();
      if (dispenseProgress >= 1.0) t.cancel();
    });
  }
  void restart() {
    cart.clear();
    toasts.clear();
    step = AppStep.category;
    activeCat = null;
    dispenseProgress = 0;
    phoneController.clear();
    phone = '';
    notifyListeners();
  }
}
