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

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<AuthBloc>().add(
          AuthRegisterRequested(
            name: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: _handleStateChange,
      builder: (context, state) => _RegisterView(
        formKey: _formKey,
        nameController: _nameController,
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

class _RegisterView extends StatelessWidget {
  const _RegisterView({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.isSubmitting,
    required this.onSubmit,
    this.errorMessage,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isSubmitting;
  final String? errorMessage;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
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
                      label: l10n.name,
                      hint: l10n.namePlaceholder,
                      controller: nameController,
                      textInputAction: TextInputAction.next,
                      enabled: !isSubmitting,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.nameRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
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
                    const SizedBox(height: AppSpacing.xl),
                    ShadButton(
                      isLoading: isSubmitting,
                      onPressed: isSubmitting ? null : onSubmit,
                      child: Text(l10n.register),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _LoginPrompt(l10n: l10n),
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
        Text(l10n.createAccount, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.registerSubtitle,
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

class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.alreadyHaveAccount,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(width: AppSpacing.xs),
        GestureDetector(
          onTap: () => context.pop(),
          child: Text(
            l10n.login,
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
