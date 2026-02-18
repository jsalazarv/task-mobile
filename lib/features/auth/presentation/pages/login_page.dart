import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hometasks/core/routes/app_routes.dart';
import 'package:hometasks/core/theme/app_theme.dart';
import 'package:hometasks/core/widgets/widgets.dart';
import 'package:hometasks/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:hometasks/features/auth/presentation/bloc/auth_event.dart';
import 'package:hometasks/features/auth/presentation/bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<AuthBloc>().add(
          AuthLoginRequested(
            email: _emailController.text,
            password: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: _handleStateChange,
      builder: (context, state) => _LoginView(
        formKey: _formKey,
        emailController: _emailController,
        passwordController: _passwordController,
        isSubmitting: state is AuthSubmitting,
        errorMessage: state is AuthFailure ? state.message : null,
        onSubmit: () => _submit(context),
      ),
    );
  }

  void _handleStateChange(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
      context.go(AppRoutes.home);
    }
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isSubmitting,
    required this.onSubmit,
    this.errorMessage,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isSubmitting;
  final String? errorMessage;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(l10n: l10n),
                    const SizedBox(height: AppSpacing.x2l),
                    if (errorMessage != null) ...[
                      _ErrorBanner(message: errorMessage!),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    ShadInput(
                      label: l10n.email,
                      hint: l10n.emailPlaceholder,
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      enabled: !isSubmitting,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.emailRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ShadInput(
                      label: l10n.password,
                      hint: l10n.passwordPlaceholder,
                      controller: passwordController,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      enabled: !isSubmitting,
                      onSubmitted: (_) => onSubmit(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.passwordRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _ForgotPasswordLink(l10n: l10n),
                    const SizedBox(height: AppSpacing.xl),
                    ShadButton(
                      isLoading: isSubmitting,
                      onPressed: isSubmitting ? null : onSubmit,
                      child: Text(l10n.login),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _RegisterPrompt(l10n: l10n),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.welcomeBack, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.loginSubtitle,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.destructive.withOpacity(0.1),
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.destructive.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 16, color: AppColors.destructive),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.destructive),
            ),
          ),
        ],
      ),
    );
  }
}

class _ForgotPasswordLink extends StatelessWidget {
  const _ForgotPasswordLink({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          l10n.forgotPassword,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _RegisterPrompt extends StatelessWidget {
  const _RegisterPrompt({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.dontHaveAccount,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(width: AppSpacing.xs),
        GestureDetector(
          onTap: () => context.push(AppRoutes.register),
          child: Text(
            l10n.register,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}
