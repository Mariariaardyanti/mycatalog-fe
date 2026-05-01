import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:shopping_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopping_app/core/widgets/auth_header.dart';
import 'package:shopping_app/core/widgets/loading_overlay.dart';
import 'package:shopping_app/core/widgets/custom_button.dart';
import 'package:email_validator/email_validator.dart';
import 'package:shopping_app/core/routes/app_router.dart';
import 'package:shopping_app/core/constants/api_colors.dart'; 

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});
  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  Timer? _timer;
  bool   _resendCooldown = false;
  int    _countdown = 60;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (!mounted) return;
      final auth    = context.read<AuthProvider>();
      final success = await auth.checkEmailVerified();
      if (success && mounted) {
        _timer?.cancel();
        Navigator.pushReplacementNamed(context, AppRouter.catalog);
      }
    });
  }

  Future<void> _resendEmail() async {
    if (_resendCooldown) return;
    await context.read<AuthProvider>().resendVerificationEmail();

    setState(() { _resendCooldown = true; _countdown = 60; });
    Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() { _countdown--; });
      if (_countdown <= 0) {
        t.cancel();
        setState(() => _resendCooldown = false);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email verifikasi sudah dikirim ulang')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().firebaseUser;

    return Scaffold(
      backgroundColor: AppColors.background, 
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Image.network(
                    'https://i.ibb.co.com/HLY7qRxC/Pink-Simple-Illustration-Fashion-Store-Logo-1-removebg-preview.png',
                    height: 120,
                    width: 120,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const SizedBox(
                        height: 80,
                        width: 80,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.mark_email_unread_outlined,
                      size: 80,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Verifikasi Email Kamu',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary, 
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Kami sudah mengirim link verifikasi ke email di bawah ini.',
                    style: TextStyle(color: AppColors.textSecondary), 
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Email user
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryFill, 
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryLight), 
                ),
                child: Text(
                  user?.email ?? '-',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary, 
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary, 
                ),
                const SizedBox(width: 12),
                const Text(
                  'Menunggu konfirmasi...',
                  style: TextStyle(color: AppColors.textSecondary), 
                ),
              ]),
              const SizedBox(height: 32),

              CustomButton(
                label: _resendCooldown
                    ? 'Kirim Ulang ($_countdown detik)'
                    : 'Kirim Ulang Email',
                variant: ButtonVariant.outlined,
                onPressed: _resendCooldown ? null : _resendEmail,
              ),
              const SizedBox(height: 16),

              CustomButton(
                label: 'Ganti Akun / Logout',
                variant: ButtonVariant.text,
                onPressed: () {
                  context.read<AuthProvider>().logout();
                  Navigator.pushReplacementNamed(context, AppRouter.login);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}