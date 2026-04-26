import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:shopping_app/core/routes/app_router.dart';
import 'package:shopping_app/core/widgets/custom_button.dart'; 

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _isLoading = false;

  final _addressController = TextEditingController();
  final _notesController   = TextEditingController();

  // Metode pembayaran — saat ini hanya Cash, bisa ditambah nanti
  final List<_PaymentMethod> _paymentMethods = [
    _PaymentMethod(id: 'cash',     label: 'Cash',          icon: Icons.payments_outlined),
    _PaymentMethod(id: 'transfer', label: 'Transfer Bank', icon: Icons.account_balance_outlined),
    _PaymentMethod(id: 'ewallet',  label: 'E-Wallet',      icon: Icons.phone_android_outlined),
  ];
  String _selectedPayment = 'cash';

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatPrice(double price) {
    final str = price.toInt().toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    return 'Rp ${buffer.toString().split('').reversed.join()}';
  }

  void _simulateCheckout() async {
    // Validasi alamat wajib diisi
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Alamat pengiriman wajib diisi'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final cart = context.read<CartProvider>();
    cart.clearCart();

    setState(() => _isLoading = false);

    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  color: Colors.green, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              'Pesanan Berhasil!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pesananmu sedang diproses.\nTerima kasih sudah berbelanja!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.55),
                  ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              label: 'Kembali ke Catalog',
              icon: const Icon(Icons.storefront_outlined, size: 18),
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                AppRouter.catalog,
                (route) => false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart        = context.watch<CartProvider>();
    final theme       = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Checkout',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Ringkasan Pesanan',
                    trailing: '${cart.items.length} item',
                    colorScheme: colorScheme,
                    theme: theme,
                  ),
                  const SizedBox(height: 10),
                  ...cart.items.map((item) => _CheckoutItemTile(
                        item: item,
                        colorScheme: colorScheme,
                        theme: theme,
                        formatPrice: _formatPrice,
                      )),

                  const SizedBox(height: 20),

                  // ── Alamat Pengiriman ─────────────────────────────
                  _SectionHeader(
                    icon: Icons.location_on_outlined,
                    title: 'Alamat Pengiriman',
                    colorScheme: colorScheme,
                    theme: theme,
                  ),
                  const SizedBox(height: 10),
                  _InputCard(
                    controller: _addressController,
                    hint: 'Masukkan alamat lengkap pengiriman...',
                    maxLines: 3,
                    colorScheme: colorScheme,
                  ),

                  const SizedBox(height: 20),

                  // ── Catatan ───────────────────────────────────────
                  _SectionHeader(
                    icon: Icons.notes_rounded,
                    title: 'Catatan (Opsional)',
                    colorScheme: colorScheme,
                    theme: theme,
                  ),
                  const SizedBox(height: 10),
                  _InputCard(
                    controller: _notesController,
                    hint: 'Contoh: titip ke satpam, dll...',
                    maxLines: 2,
                    colorScheme: colorScheme,
                  ),

                  const SizedBox(height: 20),

                  // ── Metode Pembayaran ─────────────────────────────
                  _SectionHeader(
                    icon: Icons.wallet_outlined,
                    title: 'Metode Pembayaran',
                    colorScheme: colorScheme,
                    theme: theme,
                  ),
                  const SizedBox(height: 10),
                  ..._paymentMethods.map((method) => _PaymentTile(
                        method: method,
                        isSelected: _selectedPayment == method.id,
                        colorScheme: colorScheme,
                        theme: theme,
                        onTap: () =>
                            setState(() => _selectedPayment = method.id),
                      )),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // ── Bottom Panel ──────────────────────────────────────────
          _buildBottomPanel(cart, colorScheme, theme),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(
      CartProvider cart, ColorScheme colorScheme, ThemeData theme) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withOpacity(0.12),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          _summaryRow('Subtotal', _formatPrice(cart.totalPrice),
              colorScheme, theme),
          const SizedBox(height: 6),
          _summaryRow('Ongkos Kirim', 'Gratis', colorScheme, theme,
              valueColor: Colors.green),
          const SizedBox(height: 6),
          _summaryRow(
            'Pembayaran',
            _paymentMethods
                .firstWhere((m) => m.id == _selectedPayment)
                .label,
            colorScheme,
            theme,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(
                color: colorScheme.onSurface.withOpacity(0.08), height: 1),
          ),
          _summaryRow('Total Pembayaran', _formatPrice(cart.totalPrice),
              colorScheme, theme,
              isBold: true),
          const SizedBox(height: 16),
          CustomButton(
            label: 'Konfirmasi Checkout',
            icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
            isLoading: _isLoading,
            onPressed: _simulateCheckout,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value,
    ColorScheme colorScheme,
    ThemeData theme, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(isBold ? 0.9 : 0.55),
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            fontSize: isBold ? 15 : 13,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: valueColor ??
                (isBold ? colorScheme.primary : colorScheme.onSurface),
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            fontSize: isBold ? 16 : 13,
          ),
        ),
      ],
    );
  }
}

// Section Header
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.colorScheme,
    required this.theme,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? trailing;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        if (trailing != null) ...[
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              trailing!,
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// Input Card
class _InputCard extends StatelessWidget {
  const _InputCard({
    required this.controller,
    required this.hint,
    required this.colorScheme,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: colorScheme.onSurface.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(
          fontSize: 13,
          color: colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.35),
            fontSize: 13,
          ),
          contentPadding: const EdgeInsets.all(14),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _PaymentMethod {
  final String id;
  final String label;
  final IconData icon;
  const _PaymentMethod(
      {required this.id, required this.label, required this.icon});
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.method,
    required this.isSelected,
    required this.colorScheme,
    required this.theme,
    required this.onTap,
  });

  final _PaymentMethod method;
  final bool isSelected;
  final ColorScheme colorScheme;
  final ThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withOpacity(0.07)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.onSurface.withOpacity(0.08),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(method.icon,
                  size: 20, color: colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Text(
              method.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurface.withOpacity(0.25),
                  width: isSelected ? 6 : 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutItemTile extends StatelessWidget {
  const _CheckoutItemTile({
    required this.item,
    required this.colorScheme,
    required this.theme,
    required this.formatPrice,
  });

  final dynamic item;
  final ColorScheme colorScheme;
  final ThemeData theme;
  final String Function(double) formatPrice;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: colorScheme.onSurface.withOpacity(0.07)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 60,
              height: 60,
              color: colorScheme.primary.withOpacity(0.06),
              child: Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.shopping_bag_outlined,
                  size: 28,
                  color: colorScheme.primary.withOpacity(0.4),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.quantity}x ${formatPrice(item.price)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          Text(
            formatPrice(item.total),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}