import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopping_app/core/constants/api_colors.dart';
import 'package:shopping_app/core/routes/app_router.dart';
import 'package:shopping_app/core/widgets/custom_button.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.firebaseUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Profil Saya',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined,
                color: AppColors.textPrimary, size: 22),
            onPressed: () => _showSettingsSheet(context),
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
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
        currentIndex: 3, 
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/catalog');
              break;
            case 1:
              Navigator.pushNamed(context, '/cart');
              break;
            case 2:
              break;
            case 3:
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
      body: ListView(
        children: [
          _buildProfileHeader(context, user),

          const SizedBox(height: 16),

          _buildSectionLabel('Akun'),
          _buildMenuCard([
            _MenuItem(
              icon: Icons.receipt_long_outlined,
              label: 'Riwayat Pesanan',
              onTap: () => Navigator.pushNamed(context, '/orders'),
            ),
            _MenuItem(
              icon: Icons.location_on_outlined,
              label: 'Alamat Pengiriman',
              onTap: () => _showAddressSheet(context),
            ),
            _MenuItem(
              icon: Icons.lock_outline,
              label: 'Ganti Password',
              onTap: () => _showChangePasswordDialog(context),
            ),
          ]),

          const SizedBox(height: 12),

          _buildSectionLabel('Pengaturan'),
          _buildMenuCard([
            _MenuItem(
              icon: Icons.notifications_none_outlined,
              label: 'Notifikasi',
              onTap: () {},
              trailing: Switch(
                value: true,
                onChanged: (_) {},
                activeColor: AppColors.primary,
              ),
            ),
            _MenuItem(
              icon: Icons.language_outlined,
              label: 'Bahasa',
              onTap: () {},
              trailingText: 'Indonesia',
            ),
            _MenuItem(
              icon: Icons.help_outline_rounded,
              label: 'Bantuan & FAQ',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.info_outline_rounded,
              label: 'Tentang Aplikasi',
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CustomButton(
              label: 'Keluar',
              icon: const Icon(Icons.logout_rounded, size: 18),
              variant: ButtonVariant.outlined,
              onPressed: () => _showLogoutDialog(context, auth),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, user) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryLight, width: 2),
                ),
                child: ClipOval(
                  child: user?.photoURL != null
                      ? Image.network(
                          user!.photoURL!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildAvatarFallback(user.displayName),
                        )
                      : _buildAvatarFallback(user?.displayName),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_outlined,
                        size: 13, color: AppColors.textOnGold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'Pengguna',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '-',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _showEditProfileDialog(context, user),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryFill,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primaryLight),
                    ),
                    child: const Text(
                      'Edit Profil',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildAvatarFallback(String? name) {
    final initial = (name?.isNotEmpty == true) ? name![0].toUpperCase() : '?';
    return Container(
      color: AppColors.primaryFill,
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDark,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<_MenuItem> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isLast = i == items.length - 1;
          return Column(
            children: [
              InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.vertical(
                  top: i == 0 ? const Radius.circular(16) : Radius.zero,
                  bottom: isLast ? const Radius.circular(16) : Radius.zero,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primaryFill,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item.icon,
                            size: 18, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.label,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (item.trailing != null) item.trailing!,
                      if (item.trailingText != null)
                        Text(
                          item.trailingText!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      if (item.trailing == null && item.trailingText == null)
                        const Icon(Icons.chevron_right_rounded,
                            size: 18, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 64,
                  color: AppColors.divider,
                ),
            ],
          );
        }),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar?'),
        content: const Text('Kamu akan keluar dari akun ini.'),
        actions: [
          CustomButton(
            label: 'Batal',
            variant: ButtonVariant.text,
            height: 40,
            onPressed: () => Navigator.pop(context),
          ),
          CustomButton(
            label: 'Keluar',
            variant: ButtonVariant.outlined,
            height: 40,
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, AppRouter.login, (r) => false);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, user) {
    final nameCtrl =
        TextEditingController(text: user?.displayName ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Profil'),
        content: TextField(
          controller: nameCtrl,
          decoration: InputDecoration(
            labelText: 'Nama Lengkap',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
        actions: [
          CustomButton(
            label: 'Batal',
            variant: ButtonVariant.text,
            height: 40,
            onPressed: () => Navigator.pop(context),
          ),
          CustomButton(
            label: 'Simpan',
            height: 40,
            onPressed: () async {
              // FIX #3: Validasi nama tidak boleh kosong
              final name = nameCtrl.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nama tidak boleh kosong')),
                );
                return;
              }
              await user?.updateDisplayName(name);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profil berhasil diperbarui')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final passCtrl = TextEditingController();
    final pass2Ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Ganti Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password Baru',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pass2Ctrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Konfirmasi Password',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        actions: [
          CustomButton(
            label: 'Batal',
            variant: ButtonVariant.text,
            height: 40,
            onPressed: () => Navigator.pop(context),
          ),
          CustomButton(
            label: 'Simpan',
            height: 40,
            onPressed: () async {
              // FIX #4: Validasi password tidak boleh kosong
              if (passCtrl.text.isEmpty || pass2Ctrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Password tidak boleh kosong')),
                );
                return;
              }
              if (passCtrl.text != pass2Ctrl.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Password tidak cocok')),
                );
                return;
              }
              if (passCtrl.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Password minimal 6 karakter')),
                );
                return;
              }
              await context
                  .read<AuthProvider>()
                  .firebaseUser
                  ?.updatePassword(passCtrl.text);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Password berhasil diubah')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showAddressSheet(BuildContext context) {
    final addrCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Alamat Pengiriman',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: addrCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Masukkan alamat lengkap...',
                hintStyle:
                    const TextStyle(color: AppColors.textSecondary),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              label: 'Simpan Alamat',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pengaturan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.error),
              title: const Text(
                'Hapus Akun',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () {},
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  final String? trailingText;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.trailingText,
  });
}