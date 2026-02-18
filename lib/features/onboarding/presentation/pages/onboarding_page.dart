import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hometasks/core/routes/app_routes.dart';
import 'package:hometasks/core/services/member_service.dart';
import 'package:hometasks/core/settings/app_settings_cubit.dart';
import 'package:hometasks/core/theme/app_theme.dart';
import 'package:hometasks/features/home/presentation/widgets/create_member_sheet.dart';
import 'package:hometasks/features/home/presentation/widgets/member_mock_data.dart';

/// Flujo de bienvenida de dos pasos:
///   Paso 1 — Nombre del hogar
///   Paso 2 — Agregar miembros de la familia
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  final _homeNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    _homeNameController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    setState(() => _currentPage = page);
  }

  Future<void> _finish() async {
    final cubit = context.read<AppSettingsCubit>();
    await cubit.completeOnboarding(_homeNameController.text.trim());
    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _ProgressIndicator(currentPage: _currentPage, totalPages: 2),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _Step1HomeNamePage(
                    formKey: _formKey,
                    controller: _homeNameController,
                    onNext: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        _goToPage(1);
                      }
                    },
                  ),
                  _Step2MembersPage(
                    onFinish: _finish,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Indicador de progreso ────────────────────────────────────────────────────

class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator({
    required this.currentPage,
    required this.totalPages,
  });

  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x2l,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        children: List.generate(totalPages, (i) {
          final isActive = i <= currentPage;
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: i < totalPages - 1 ? 6 : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: isActive
                    ? const LinearGradient(
                        colors: [AppColors.indigo500, AppColors.violet600],
                      )
                    : null,
                color: isActive
                    ? null
                    : AppColors.cardDarkBorder,
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Paso 1: nombre del hogar ─────────────────────────────────────────────────

class _Step1HomeNamePage extends StatelessWidget {
  const _Step1HomeNamePage({
    required this.formKey,
    required this.controller,
    required this.onNext,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x2l),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.x2l),
            const _WelcomeIcon(),
            const SizedBox(height: AppSpacing.x2l),
            Text(
              '¡Bienvenido a HomeTasks!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '¿Cómo se llama tu hogar?\nEste nombre aparecerá en tu pantalla principal.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.x2l),
            TextFormField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: 'Ej: Casa García, Nido Familiar...',
                prefixIcon: const Icon(Icons.home_outlined),
                filled: true,
                fillColor: cs.surface,
                border: const OutlineInputBorder(
                  borderRadius: AppRadius.card,
                  borderSide: BorderSide.none,
                ),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: AppRadius.card,
                  borderSide: BorderSide(
                    color: AppColors.cardDarkBorder,
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: AppRadius.card,
                  borderSide: BorderSide(
                    color: AppColors.indigo500,
                    width: 2,
                  ),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Ingresa un nombre para tu hogar';
                }
                return null;
              },
            ),
            const Spacer(),
            _PrimaryButton(label: 'Continuar', onTap: onNext),
            const SizedBox(height: AppSpacing.x2l),
          ],
        ),
      ),
    );
  }
}

class _WelcomeIcon extends StatelessWidget {
  const _WelcomeIcon();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.indigo500, AppColors.violet600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.x3l),
          boxShadow: [
            BoxShadow(
              color: AppColors.indigo500.withOpacity(0.4),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.home_rounded,
          size: 44,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ── Paso 2: agregar miembros ─────────────────────────────────────────────────

class _Step2MembersPage extends StatelessWidget {
  const _Step2MembersPage({required this.onFinish});

  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x2l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.x2l),
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.categoryGardenFg, AppColors.indigo500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadius.x3l),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.indigo500.withOpacity(0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.group_rounded,
                size: 44,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.x2l),
          Text(
            '¿Quiénes viven aquí?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Agrega a los miembros que participarán en las tareas. Puedes agregar más personas después.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.x2l),
          _MemberCountBadge(),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: () => showCreateMemberSheet(context),
            icon: const Icon(Icons.person_add_outlined),
            label: const Text('Agregar miembro'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              side: const BorderSide(color: AppColors.indigo500),
              foregroundColor: AppColors.indigo400,
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
            ),
          ),
          const Spacer(),
          _PrimaryButton(label: 'Comenzar', onTap: onFinish),
          const SizedBox(height: AppSpacing.x2l),
        ],
      ),
    );
  }
}

class _MemberCountBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<FamilyMember>>(
      valueListenable: MemberService.instance.membersNotifier,
      builder: (context, members, _) {
        if (members.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.indigo500.withOpacity(0.12),
            borderRadius: AppRadius.card,
            border: Border.all(color: AppColors.indigo500.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 18,
                color: AppColors.indigo400,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                members.length == 1
                    ? '1 miembro agregado'
                    : '${members.length} miembros agregados',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.indigo400,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Botón primario reutilizable ───────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.indigo500, AppColors.violet600],
          ),
          borderRadius: AppRadius.card,
          boxShadow: [
            BoxShadow(
              color: AppColors.indigo500.withOpacity(0.45),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}
