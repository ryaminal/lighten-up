import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lighten_up/core/constants/app_colors.dart';
import 'package:lighten_up/core/constants/app_text_styles.dart';
import 'package:lighten_up/core/constants/app_dimensions.dart';
import 'package:lighten_up/core/utils/extensions.dart';
import 'package:lighten_up/core/utils/validators.dart';
import 'package:lighten_up/core/widgets/app_button.dart';
import 'package:lighten_up/core/widgets/app_card.dart';
import 'package:lighten_up/core/widgets/app_text_field.dart';
import 'package:lighten_up/core/widgets/error_banner.dart';
import 'package:lighten_up/presentation/providers/auth_provider.dart';

/// Login screen for user authentication - Clean orchestrator
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await ref
          .read(authProvider.notifier)
          .login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      // Navigation will be handled by go_router based on auth state
    } catch (e) {
      // Error is already handled in the provider and shown in the UI
      if (mounted) {
        context.showError('Login failed: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.spaceLg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: AppDimensions.space2xl),
                  _buildLoginForm(authState),
                  const SizedBox(height: AppDimensions.spaceLg),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Icon(
          Icons.medical_services_rounded,
          size: 80,
          color: AppColors.primary,
        ),
        const SizedBox(height: AppDimensions.spaceLg),
        Text(
          'Lighten Up',
          style: AppTextStyles.headingLarge.copyWith(
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.spaceSm),
        Text(
          'Medical Office Communication',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm(dynamic authState) {
    return AppCard(
      variant: CardVariant.elevated,
      padding: const EdgeInsets.all(AppDimensions.spaceLg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Sign In',
              style: AppTextStyles.headingMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceLg),
            AppTextField(
              controller: _emailController,
              labelText: 'Email',
              hintText: 'Enter your email',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
              enabled: !authState.isLoading,
            ),
            const SizedBox(height: AppDimensions.spaceMd),
            AppTextField(
              controller: _passwordController,
              labelText: 'Password',
              hintText: 'Enter your password',
              prefixIcon: Icons.lock_outlined,
              obscureText: _obscurePassword,
              validator: (value) => Validators.required(value, 'Password'),
              enabled: !authState.isLoading,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            const SizedBox(height: AppDimensions.spaceSm),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: authState.isLoading
                    ? null
                    : () {
                        // TODO: Implement forgot password
                      },
                child: Text(
                  'Forgot Password?',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spaceMd),
            AppButton(
              label: 'Sign In',
              onPressed: _handleLogin,
              isLoading: authState.isLoading,
              fullWidth: true,
              size: AppButtonSize.large,
            ),
            if (authState.error != null) ...[
              const SizedBox(height: AppDimensions.spaceMd),
              ErrorBanner(message: authState.error!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Text(
      'Version 1.0.0',
      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
      textAlign: TextAlign.center,
    );
  }
}
