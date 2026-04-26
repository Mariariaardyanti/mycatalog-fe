import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'package:shopping_app/core/widgets/custom_button.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final theme = Theme.of(context);
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
          'Keranjang',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
        actions: [
          if (cart.items.isNotEmpty)
            CustomButton(
              label: 'Hapus Semua',
              variant: ButtonVariant.text,
              width: 120,
              height: 36,
              onPressed: () => _showClearDialog(context, cart),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: cart.items.isEmpty
          ? _buildEmptyState(context, theme, colorScheme)
          : Column(
              children: [
                // Item count badge
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${cart.items.length} item',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Cart item list
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final item = cart.items[i];
                      return _CartItemCard(
                        item: item,
                        cart: cart,
                        colorScheme: colorScheme,
                        theme: theme,
                      );
                    },
                  ),
                ),

                // Bottom summary panel
                _buildSummaryPanel(context, cart, colorScheme, theme),
              ],
            ),
    );
  }

  void _showClearDialog(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Kosongkan Keranjang?'),
        content: const Text('Semua item akan dihapus dari keranjang.'),
        actions: [
          CustomButton(
            label: 'Batal',
            variant: ButtonVariant.text,
            height: 40,
            onPressed: () => Navigator.pop(context),
          ),
          CustomButton(
            label: 'Hapus',
            variant: ButtonVariant.outlined,
            height: 40,
            onPressed: () {
              cart.clearCart();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 48,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Keranjang Kosong',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Yuk, tambah produk ke keranjangmu!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 28),
            CustomButton(
              label: 'Mulai Belanja',
              icon: const Icon(Icons.storefront_outlined, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryPanel(BuildContext context, CartProvider cart,
      ColorScheme colorScheme, ThemeData theme) {
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
          // Drag handle
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

          _summaryRow(
            label: 'Subtotal (${cart.items.length} item)',
            value: 'Rp ${cart.totalPrice.toStringAsFixed(0)}',
            colorScheme: colorScheme,
            theme: theme,
          ),
          const SizedBox(height: 6),
          _summaryRow(
            label: 'Ongkos Kirim',
            value: 'Gratis',
            colorScheme: colorScheme,
            theme: theme,
            valueColor: Colors.green,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(
                color: colorScheme.onSurface.withOpacity(0.08), height: 1),
          ),
          _summaryRow(
            label: 'Total Pembayaran',
            value: 'Rp ${cart.totalPrice.toStringAsFixed(0)}',
            colorScheme: colorScheme,
            theme: theme,
            isBold: true,
          ),
          const SizedBox(height: 16),

          CustomButton(
            label: 'Checkout Sekarang',
            icon: const Icon(Icons.shopping_bag_outlined, size: 18),
            onPressed: () => Navigator.pushNamed(context, '/checkout'),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow({
    required String label,
    required String value,
    required ColorScheme colorScheme,
    required ThemeData theme,
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

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
    required this.cart,
    required this.colorScheme,
    required this.theme,
  });

  final dynamic item;
  final CartProvider cart;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.onSurface.withOpacity(0.07)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 88,
              height: 88,
              color: colorScheme.primary.withOpacity(0.06),
              child: Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.shopping_bag_outlined,
                  size: 36,
                  color: colorScheme.primary.withOpacity(0.4),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category label (opsional — tampil hanya jika ada)
                if (item.category != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.category,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                const SizedBox(height: 6),
                Text(
                  item.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp ${item.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 10),

                // Stepper + delete
                Row(
                  children: [
                    _QuantityStepper(
                      quantity: item.quantity,
                      colorScheme: colorScheme,
                      onDecrease: () {
                        if (item.quantity > 1) {
                          cart.decreaseQuantity(item.id);
                        } else {
                          cart.removeFromCart(item.id);
                        }
                      },
                      onIncrease: () => cart.increaseQuantity(item.id),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => cart.removeFromCart(item.id),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: colorScheme.error.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.colorScheme,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int quantity;
  final ColorScheme colorScheme;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
              icon: Icons.remove, onTap: onDecrease, colorScheme: colorScheme),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$quantity',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          _StepButton(
              icon: Icons.add, onTap: onIncrease, colorScheme: colorScheme),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.onTap,
    required this.colorScheme,
  });

  final IconData icon;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 30,
        height: 32,
        child: Icon(icon, size: 16, color: colorScheme.primary),
      ),
    );
  }
}