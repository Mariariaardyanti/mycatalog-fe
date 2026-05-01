import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/core/constants/api_colors.dart';
import 'package:shopping_app/features/catalog/presentation/providers/product_provider.dart';
import 'package:shopping_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopping_app/core/routes/app_router.dart';
import 'package:shopping_app/features/catalog/data/models/product_model.dart';
import 'package:shopping_app/features/cart/presentation/providers/cart_provider.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage>
    with SingleTickerProviderStateMixin {
  String _selectedCategory = 'All';
  final _searchCtrl = TextEditingController();

  late AnimationController _bannerCtrl;
  late Animation<double> _bannerFade;

  final List<Map<String, dynamic>> _categories = [
    {'label': 'All',          'icon': Icons.grid_view_rounded},
    {'label': 'Ransel',       'icon': Icons.backpack_outlined},
    {'label': 'Tas Tangan',   'icon': Icons.shopping_bag_outlined},
    {'label': 'Tas Olahraga', 'icon': Icons.sports_basketball_outlined},
  ];


  @override
  void initState() {
    super.initState();
    _bannerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _bannerFade = CurvedAnimation(
        parent: _bannerCtrl, curve: Curves.easeOut);
    _bannerCtrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _bannerCtrl.dispose();
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

  List<ProductModel> _filteredProducts(List<ProductModel> products) {
    final query = _searchCtrl.text.toLowerCase();
    return products.where((p) {
      final matchCat = _selectedCategory == 'All' ||
          p.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchQ = query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          p.category.toLowerCase().contains(query);
      return matchCat && matchQ;
    }).toList();
  }

  void _addToCart(BuildContext context, ProductModel p) {
    context.read<CartProvider>().addToCart(p);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppColors.textOnGold, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${p.name} ditambahkan ke keranjang',
                style: const TextStyle(
                    color: AppColors.textOnGold, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AuthProvider auth) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shopping_bag_rounded,
                color: AppColors.textOnGold, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Yuliana Fashion Store',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                'Halo, ${auth.firebaseUser?.displayName ?? auth.firebaseUser?.email ?? 'Fashionista'}! 👋',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: () async {
            final auth = context.read<AuthProvider>();
            await auth.logout();
            if (!mounted) return;
            Navigator.pushNamedAndRemoveUntil(
                context, AppRouter.login, (route) => false);
          },
          child: const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.logout_rounded,
                color: AppColors.textSecondary, size: 22),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.divider),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Cari tas, ransel, & aksesoris...',
          hintStyle: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.7), fontSize: 13),
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColors.primary, size: 20),
          filled: true,
          fillColor: AppColors.primaryFill,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: AppColors.primaryLight, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  static const String _promoBannerImageUrl =
      'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=400&q=80';

  Widget _buildPromoBanner() {
    return FadeTransition(
      opacity: _bannerFade,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        height: 130,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryDark, AppColors.primary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowGold,
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.textOnGold.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'NEW COLLECTION ✨',
                          style: TextStyle(
                            fontSize: 9,
                            color: AppColors.textOnGold,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Diskon hingga 50%',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textOnGold,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Untuk transaksi pertamamu',
                        style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textOnGold),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'SHOP NOW →',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(
                width: 120,
                height: 130,
                child: Image.network(
                  _promoBannerImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Container(color: AppColors.primaryDark);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        itemCount: _categories.length,
        itemBuilder: (_, i) {
          final cat = _categories[i];
          final label = cat['label'] as String;
          final icon = cat['icon'] as IconData;
          final isSelected = label == _selectedCategory;

          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.primaryFill,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.primaryLight,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.shadowGold,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon,
                      size: 14,
                      color: isSelected
                          ? AppColors.textOnGold
                          : AppColors.textSecondary),
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.textOnGold
                          : AppColors.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Container(
            width: 4, height: 18,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              )),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count item',
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel p) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16)),
                child: SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: Image.network(
                    p.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.primaryFill,
                      child: const Center(
                        child: Icon(Icons.shopping_bag_outlined,
                            size: 40, color: AppColors.primaryLight),
                      ),
                    ),
                  ),
                ),
              ),
              // Category badge
              Positioned(
                top: 8, left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primaryDark.withOpacity(0.08),
                          blurRadius: 4)
                    ],
                  ),
                  child: Text(
                    p.category,
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
              // Wishlist
              Positioned(
                top: 6, right: 6,
                child: Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primaryDark.withOpacity(0.08),
                          blurRadius: 4)
                    ],
                  ),
                  child: const Icon(Icons.favorite_border_rounded,
                      size: 16, color: AppColors.primary),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    ...List.generate(
                        5,
                        (i) => Icon(
                              i < 4
                                  ? Icons.star_rounded
                                  : Icons.star_half_rounded,
                              size: 12,
                              color: AppColors.primary,
                            )),
                    const SizedBox(width: 4),
                    const Text('4.5',
                        style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  _formatPrice(p.price),
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 34,
                  child: ElevatedButton.icon(
                    onPressed: () => _addToCart(context, p),
                    icon: const Icon(
                        Icons.add_shopping_cart_rounded, size: 14),
                    label: const Text('Tambah',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnGold,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final product = context.watch<ProductProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(auth),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: switch (product.status) {
              ProductStatus.loading || ProductStatus.initial => const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      SizedBox(height: 16),
                      Text('Memuat koleksi...',
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),

              ProductStatus.error => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80, height: 80,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.error_outline_rounded,
                            size: 40, color: AppColors.primary),
                      ),
                      const SizedBox(height: 16),
                      Text(product.error ?? 'Terjadi kesalahan',
                          style: const TextStyle(
                              color: AppColors.textSecondary)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('Coba Lagi'),
                        onPressed: () => product.fetchProducts(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textOnGold,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),

              ProductStatus.loaded => Builder(builder: (context) {
                  final filtered = _filteredProducts(product.products);
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () => product.fetchProducts(),
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(child: _buildPromoBanner()),

                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Text(
                                    'KATEGORI',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textSecondary,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildCategoryChips(),
                              ],
                            ),
                          ),
                        ),

                        SliverToBoxAdapter(
                          child: _buildSectionHeader(
                              'Untuk Kamu', filtered.length),
                        ),

                        if (filtered.isEmpty)
                          const SliverFillRemaining(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off_rounded,
                                      size: 56,
                                      color: AppColors.primaryLight),
                                  SizedBox(height: 12),
                                  Text('Produk tidak ditemukan',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      )),
                                ],
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding:
                                const EdgeInsets.fromLTRB(14, 12, 14, 24),
                            sliver: SliverGrid.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.58,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: filtered.length,
                              itemBuilder: (ctx, i) =>
                                  _buildProductCard(ctx, filtered[i]),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
            },
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle:
            const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        elevation: 12,
        currentIndex: 0, 
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.pushNamed(context, '/cart');
              break;
            case 2:
              break;
            case 3:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined), label: 'Cart'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border_rounded), label: 'Favorite'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded), label: 'Account'),
        ],
      ),
    );
  }
}