import 'package:flutter/material.dart';
import 'controller.dart';
import 'core.dart';
import 'screen.dart';

///1. Category                                                           
class CategoryStage extends StatelessWidget {
  final VendingController controller;
  const CategoryStage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const StageHeading('เลือกหมวดสินค้า'),
        const StageSubtitle('เครื่องดื่มและของว่างเพื่อสุขภาพ 12 รายการ — จ่ายด้วย QR เท่านั้น ไม่ต้องสมัครสมาชิก'),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.72,
          children: kCategories.map((c) => _CategoryCard(info: c, controller: controller)).toList(),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryInfo info;
  final VendingController controller;
  const _CategoryCard({required this.info, required this.controller});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => controller.selectCategory(info.id),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.sageSoft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Full-width photo banner instead of a small centered icon.
            SizedBox(
              width: double.infinity,
              height: 170,
              child: Image.asset(
                info.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.sageSoft,
                  alignment: Alignment.center,
                  child: Text(info.icon, style: const TextStyle(fontSize: 72)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(info.name, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(info.desc, style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

///2. Products                                                            */
class ProductsStage extends StatelessWidget {
  final VendingController controller;
  const ProductsStage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final cat = kCategories.firstWhere((c) => c.id == controller.activeCat);
    final list = kProducts.where((p) => p.cat == controller.activeCat).toList();

    return ListView(
      children: [
        ToastList(controller.toasts),
        BackRow(label: '‹ กลับไปเลือกหมวด', to: AppStep.category, controller: controller),
        StageHeading('${cat.icon} ${cat.name}'),
        const StageSubtitle('เลือกจำนวนที่ต้องการ แล้วกด "ดูสรุป" ด้านล่าง'),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.62,
          children: list.map((p) => _ProductCard(product: p, controller: controller)).toList(),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VendingController controller;
  const _ProductCard({required this.product, required this.controller});

  @override
  Widget build(BuildContext context) {
    final left = controller.stock[product.id] ?? 0;
    final qty = controller.cart[product.id] ?? 0;
    final out = left <= 0;
    final low = left > 0 && left < 3;

    return Opacity(
      opacity: out ? 0.55 : 1,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 136,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppColors.sageSoft, borderRadius: BorderRadius.circular(12)),
              child: ProductThumb(imagePath: product.image, emojiFallback: product.icon, size: 120),
            ),
            const SizedBox(height: 10),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              out ? 'สินค้าหมด' : (low ? 'เหลือ $left ชิ้น' : 'คงเหลือ $left ชิ้น'),
              style: TextStyle(
                fontSize: 11,
                color: (out || low) ? AppColors.berry : AppColors.inkSoft,
                fontWeight: (out || low) ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${product.price}฿', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                qty > 0 ? _qtyControl(qty, left) : _addButton(out),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyControl(int qty, int left) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _qtyButton('−', () => controller.dec(product.id)),
        SizedBox(
          width: 18,
          child: Text('$qty', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        ),
        _qtyButton('+', qty < left ? () => controller.inc(product.id) : null),
      ],
    );
  }

  Widget _qtyButton(String label, VoidCallback? onTap) {
    return SizedBox(
      width: 26,
      height: 26,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: const BorderSide(color: AppColors.line),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 15, color: AppColors.forest, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _addButton(bool out) {
    return ElevatedButton(
      onPressed: out ? null : () => controller.inc(product.id),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.forest,
        disabledBackgroundColor: AppColors.line,
        foregroundColor: Colors.white,
        disabledForegroundColor: AppColors.inkSoft,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(out ? 'หมด' : 'เพิ่ม', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

/// 3. Cart / summary                                                      */
class CartStage extends StatelessWidget {
  final VendingController controller;
  const CartStage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final entries = controller.cart.entries.where((e) => e.value > 0).toList();

    if (entries.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🧺', style: TextStyle(fontSize: 34)),
          const SizedBox(height: 10),
          const Text('ตะกร้ายังไม่มีสินค้า', style: TextStyle(color: AppColors.inkSoft)),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: controller.goCategory,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.forest, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('เลือกสินค้า', style: TextStyle(color: AppColors.forest)),
          ),
        ],
      );
    }

    return ListView(
      children: [
        ToastList(controller.toasts),
        BackRow(label: '‹ เลือกสินค้าเพิ่ม', to: AppStep.category, controller: controller),
        const StageHeading('สรุปรายการ'),
        const StageSubtitle('ตรวจสอบรายการและยอดรวมก่อนชำระเงิน'),
        ...entries.map((e) => _CartRow(id: e.key, qty: e.value, controller: controller)),
        _TotalLine(total: controller.cartTotal()),
        _DemoBox(controller: controller),
      ],
    );
  }
}

class _CartRow extends StatelessWidget {
  final String id;
  final int qty;
  final VendingController controller;
  const _CartRow({required this.id, required this.qty, required this.controller});

  @override
  Widget build(BuildContext context) {
    final p = controller.productById(id);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.line, width: 1))),
      child: Row(
        children: [
          ProductThumb(imagePath: p.image, emojiFallback: p.icon, size: 40),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, style: const TextStyle(fontSize: 13)),
                Text('$qty × ${p.price}฿', style: const TextStyle(fontSize: 11, color: AppColors.inkSoft)),
              ],
            ),
          ),
          Text('${qty * p.price}฿', style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold)),
          TextButton(
            onPressed: () => controller.removeFromCart(id),
            style: TextButton.styleFrom(foregroundColor: AppColors.berry),
            child: const Text('ลบ', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _TotalLine extends StatelessWidget {
  final int total;
  const _TotalLine({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12),
      margin: const EdgeInsets.only(top: 6),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.ink, width: 2))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('ยอดรวม', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          Text('$total บาท', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _DemoBox extends StatelessWidget {
  final VendingController controller;
  const _DemoBox({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.sageSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text.rich(
            TextSpan(children: [
              TextSpan(text: 'โหมดสาธิต: ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text: 'จำลองสถานการณ์ "สินค้าหมดพอดีตอนกดจ่าย" (ระบบอัปเดตสต๊อกไม่ทัน) '
                      'เพื่อดูวิธีที่ตู้จัดการ — เงินจะไม่ถูกตัดและมีการแนะนำสินค้าใกล้เคียงแทน'),
            ]),
            style: TextStyle(fontSize: 11.5, color: AppColors.inkSoft, height: 1.4),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: controller.simulateSuddenSoldOut,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.berry),
              foregroundColor: AppColors.berry,
              backgroundColor: AppColors.paper,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('ทดสอบสถานการณ์นี้', style: TextStyle(fontSize: 11.5)),
          ),
        ],
      ),
    );
  }
}

/// 4. Payment method                                                      */
class PayMethodStage extends StatelessWidget {
  final VendingController controller;
  const PayMethodStage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        BackRow(label: '‹ กลับไปสรุปรายการ', to: AppStep.cart, controller: controller),
        const StageHeading('เลือกวิธีชำระเงิน'),
        const StageSubtitle('รับชำระด้วย QR Code เท่านั้น เพื่อลดปัญหาเงินทอนและดูแลตู้ได้ง่ายขึ้น'),
        _PayCard(
          icon: '💳',
          title: 'พร้อมเพย์ (PromptPay)',
          subtitle: 'สแกนด้วยแอปธนาคารที่รองรับพร้อมเพย์',
          controller: controller,
        ),
        const SizedBox(height: 10),
        _PayCard(
          icon: '📱',
          title: 'Mobile Banking',
          subtitle: 'สแกนด้วยแอปธนาคารบนมือถือ',
          controller: controller,
        ),
        const SizedBox(height: 18),
        const Text('เบอร์โทรศัพท์ (ไม่บังคับ — ใส่เพื่อสะสมแต้ม)', style: TextStyle(fontSize: 12, color: AppColors.inkSoft)),
        const SizedBox(height: 6),
        TextField(
          controller: controller.phoneController,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          decoration: InputDecoration(
            hintText: '08X-XXX-XXXX',
            counterText: '',
            filled: true,
            fillColor: AppColors.paper,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.line)),
          ),
        ),
        const SizedBox(height: 5),
        const Text('ทุก 10 บาท = 1 แต้ม ผูกกับเบอร์โทรของคุณ ไม่ใส่ก็ซื้อได้ตามปกติ',
            style: TextStyle(fontSize: 11, color: AppColors.inkSoft)),
      ],
    );
  }
}

class _PayCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final VendingController controller;
  const _PayCard({required this.icon, required this.title, required this.subtitle, required this.controller});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => controller.selectPayment(title),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 5. QR confirm                                                          */
class QrStage extends StatelessWidget {
  final VendingController controller;
  const QrStage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final cells = controller.qrPattern();

    return ListView(
      children: [
        BackRow(label: '‹ เปลี่ยนวิธีชำระเงิน', to: AppStep.payMethod, controller: controller),
        const StageHeading('สแกนเพื่อชำระเงิน'),
        StageSubtitle('วิธีที่เลือก: ${controller.payLabel}'),
        Center(
          child: Column(
            children: [
              Container(
                width: 190,
                height: 190,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.line),
                ),
                child: GridView.count(
                  crossAxisCount: 11,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                  children:
                      cells.map((on) => Container(color: on ? const Color(0xFF1A1A1A) : Colors.transparent)).toList(),
                ),
              ),
              const SizedBox(height: 14),
              Text('${controller.cartTotal()} บาท', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              const Text('QR ตัวอย่างสำหรับสาธิต — กดยืนยันด้านล่างเพื่อจำลองการสแกนจ่ายสำเร็จ',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.inkSoft)),
              const SizedBox(height: 18),
              MangoButton(label: 'ฉันสแกนชำระเงินแล้ว', onPressed: controller.confirmPayment),
            ],
          ),
        ),
      ],
    );
  }
}

/// 6. Success / dispensing                                               */
class SuccessStage extends StatelessWidget {
  final VendingController controller;
  const SuccessStage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final pct = (controller.dispenseProgress * 100).round();
    final done = controller.dispenseProgress >= 1.0;

    return ListView(
      children: [
        Center(
          child: Column(
            children: [
              const Text('🎉 ชำระเงินสำเร็จ', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('กำลังปล่อยสินค้า...', style: TextStyle(fontSize: 13, color: AppColors.inkSoft)),
              const SizedBox(height: 18),
              _ProgressRing(progress: controller.dispenseProgress, pct: pct),
              if (done) ..._doneContent(),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _doneContent() {
    return [
      const SizedBox(height: 20),
      const Text('หยิบสินค้าได้เลย ที่ช่องรับสินค้าด้านล่างตู้',
          textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.inkSoft)),
      Container(
        margin: const EdgeInsets.only(top: 14),
        padding: const EdgeInsets.only(top: 12),
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.line))),
        child: Column(
          children: controller.dispensedSnapshot.map((d) {
            final p = d['product'] as Product;
            final qty = d['qty'] as int;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  ProductThumb(imagePath: p.image, emojiFallback: p.icon, size: 32),
                  const SizedBox(width: 8),
                  Expanded(child: Text('${p.name} × $qty', style: const TextStyle(fontSize: 13))),
                  Text('${qty * p.price}฿', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      if (controller.earnedPoints > 0)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text('⭐ ได้รับ ${controller.earnedPoints} แต้ม เข้าเบอร์ ${controller.phone}',
              style: const TextStyle(fontSize: 13, color: AppColors.inkSoft)),
        ),
      const SizedBox(height: 16),
      MangoButton(label: 'ทำรายการใหม่', onPressed: controller.restart),
    ];
  }
}

class _ProgressRing extends StatelessWidget {
  final double progress;
  final int pct;
  const _ProgressRing({required this.progress, required this.pct});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 96,
            height: 96,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              backgroundColor: AppColors.sageSoft,
              valueColor: const AlwaysStoppedAnimation(AppColors.forest),
            ),
          ),
          Text('$pct%', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
