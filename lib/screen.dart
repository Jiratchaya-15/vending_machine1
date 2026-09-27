import 'package:flutter/material.dart';
import 'controller.dart';
import 'core.dart';
import 'stages.dart';

class VendingScreen extends StatefulWidget {
  const VendingScreen({super.key});
  @override
  State<VendingScreen> createState() => _VendingScreenState();
}
class _VendingScreenState extends State<VendingScreen> {
  late final VendingController controller;
  @override
  void initState() {
    super.initState();
    controller = VendingController();
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  Widget _currentStage() {
    switch (controller.step) {
      case AppStep.category:
        return CategoryStage(controller: controller);
      case AppStep.products:
        return ProductsStage(controller: controller);
      case AppStep.cart:
        return CartStage(controller: controller);
      case AppStep.payMethod:
        return PayMethodStage(controller: controller);
      case AppStep.qr:
        return QrStage(controller: controller);
      case AppStep.success:
        return SuccessStage(controller: controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            return _MachineCabinet(
              child: _ScreenPanel(
                controller: controller,
                stage: _currentStage(),
                footer: _FooterBar(controller: controller),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MachineCabinet extends StatelessWidget {
  final Widget child;
  const _MachineCabinet({required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.forest, AppColors.forestDark],
              ),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _vents(),
                Expanded(child: child),
                _dispenseSlot(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _vents() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 12),
      child: Row(
        children: List.generate(
          6,
          (i) => Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              height: 4,
              decoration:
                  BoxDecoration(color: Colors.white.withOpacity(.14), borderRadius: BorderRadius.circular(2)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dispenseSlot() {
    return Container(
      height: 10,
      margin: const EdgeInsets.fromLTRB(8, 12, 8, 4),
      decoration: BoxDecoration(color: Colors.black.withOpacity(.25), borderRadius: BorderRadius.circular(6)),
    );
  }
}

class _ScreenPanel extends StatelessWidget {
  final Widget stage;
  final Widget footer;
  final VendingController controller;
  const _ScreenPanel({required this.stage, required this.footer, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _topBar(controller.points),
          _stepIndicator(controller.step),
          Expanded(child: Padding(padding: const EdgeInsets.fromLTRB(18, 4, 18, 18), child: stage)),
          footer,
        ],
      ),
    );
  }

  Widget _topBar(int points) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
      child: Row(
        children: [
          Container(
            width: 11,
            height: 11,
            decoration: const BoxDecoration(color: Color.fromARGB(255, 232, 61, 198), shape: BoxShape.circle),
          ),
          const SizedBox(width: 9),
          const Text('HealthyVend', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.sageSoft,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.line),
            ),
            child: Text('⭐ แต้มสะสม $points',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.forest)),
          ),
        ],
      ),
    );
  }

  Widget _stepIndicator(AppStep current) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      child: Row(
        children: kStepOrder.map((s) {
          final on = kStepOrder.indexOf(s) <= kStepOrder.indexOf(current);
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 4,
              decoration:
                  BoxDecoration(color: on ? AppColors.forest : AppColors.line, borderRadius: BorderRadius.circular(3)),
            ),
          );
        }).toList(),
      ),
    );
  }
}

///Footer bar                                                             
class _FooterBar extends StatelessWidget {
  final VendingController controller;
  const _FooterBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.step == AppStep.category || controller.step == AppStep.success) {
      return const SizedBox.shrink();
    }

    Widget? action;
    if (controller.step == AppStep.products) {
      action = _actionButton(
          label: 'ดูสรุป', onPressed: controller.cartCount() == 0 ? null : () => controller.goTo(AppStep.cart));
    } else if (controller.step == AppStep.cart) {
      action = _actionButton(
          label: 'ชำระเงิน', onPressed: controller.cartCount() == 0 ? null : () => controller.goTo(AppStep.payMethod));
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: const BoxDecoration(color: AppColors.paper, border: Border(top: BorderSide(color: AppColors.line))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ตะกร้า · ${controller.cartCount()} รายการ',
                    style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft)),
                Text('${controller.cartTotal()} บาท', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          if (action != null) action,
        ],
      ),
    );
  }

  Widget _actionButton({required String label, required VoidCallback? onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.mango,
        disabledBackgroundColor: AppColors.line,
        foregroundColor: const Color(0xFF29200D),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
                                            
class StageHeading extends StatelessWidget {
  final String text;
  const StageHeading(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 3),
      child: Text(text, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
    );
  }
}

class StageSubtitle extends StatelessWidget {
  final String text;
  const StageSubtitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.inkSoft, height: 1.5)),
    );
  }
}

class ProductThumb extends StatelessWidget {
  final String imagePath;
  final String emojiFallback;
  final double size;
  const ProductThumb({super.key, required this.imagePath, required this.emojiFallback, this.size = 26});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          Text(emojiFallback, style: TextStyle(fontSize: size * 0.85)),
    );
  }
}

class BackRow extends StatelessWidget {
  final String label;
  final AppStep to;
  final VendingController controller;
  const BackRow({super.key, required this.label, required this.to, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          style: TextButton.styleFrom(
              padding: EdgeInsets.zero, foregroundColor: AppColors.forest, minimumSize: const Size(0, 0)),
          onPressed: () => controller.goTo(to),
          child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

class ToastList extends StatelessWidget {
  final List<String> toasts;
  const ToastList(this.toasts, {super.key});

  @override
  Widget build(BuildContext context) {
    if (toasts.isEmpty) return const SizedBox.shrink();
    return Column(
      children: toasts
          .map((t) => Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.mango, borderRadius: BorderRadius.circular(10)),
                child: Text(t,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF29200D))),
              ))
          .toList(),
    );
  }
}

class MangoButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const MangoButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mango,
          disabledBackgroundColor: AppColors.line,
          foregroundColor: const Color(0xFF29200D),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
