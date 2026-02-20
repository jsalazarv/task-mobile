import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hometasks/core/models/group.dart';
import 'package:hometasks/core/routes/app_routes.dart';
import 'package:hometasks/core/services/group_service.dart';
import 'package:hometasks/core/services/member_service.dart';
import 'package:hometasks/core/settings/app_settings_cubit.dart';
import 'package:hometasks/core/theme/app_theme.dart';
import 'package:hometasks/core/theme/app_colors.dart';
import 'package:hometasks/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:hometasks/features/auth/presentation/bloc/auth_state.dart';
import 'package:hometasks/features/home/presentation/widgets/create_member_sheet.dart';
import 'package:hometasks/features/home/presentation/widgets/member_mock_data.dart';

/// Flujo de bienvenida de dos pasos:
///   Paso 1 — Nombre del grupo + tipo
///   Paso 2 — Agregar miembros al grupo
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  final _groupNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  GroupType _selectedType = GroupType.home;
  int _currentPage = 0;
  String? _createdGroupId;

  @override
  void dispose() {
    _pageController.dispose();
    _groupNameController.dispose();
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

  Future<void> _createGroupAndContinue() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final groupName = _groupNameController.text.trim();
    final group = Group(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: groupName,
      type: _selectedType,
      color: AppColors.indigo500,
      createdAt: DateTime.now(),
    );

    await GroupService.instance.add(group);

    // Agregar al usuario logueado como primer miembro del grupo.
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      await MemberService.instance.addOwnerIfAbsent(
        userId: authState.user.id,
        userName: authState.user.name,
        groupId: group.id,
      );
    }

    final cubit = context.read<AppSettingsCubit>();
    await cubit.completeOnboarding(groupName, groupId: group.id);

    setState(() => _createdGroupId = group.id);
    _goToPage(1);
  }

  Future<void> _finish() async {
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
                  _Step1GroupPage(
                    formKey: _formKey,
                    controller: _groupNameController,
                    selectedType: _selectedType,
                    onTypeChanged: (t) => setState(() => _selectedType = t),
                    onNext: _createGroupAndContinue,
                  ),
                  _Step2MembersPage(
                    groupId: _createdGroupId ?? '',
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
                gradient:
                    isActive
                        ? const LinearGradient(
                          colors: [AppColors.indigo500, AppColors.violet600],
                        )
                        : null,
                color: isActive ? null : AppColors.cardDarkBorder,
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Paso 1: nombre y tipo del grupo ─────────────────────────────────────────

class _Step1GroupPage extends StatelessWidget {
  const _Step1GroupPage({
    required this.formKey,
    required this.controller,
    required this.selectedType,
    required this.onTypeChanged,
    required this.onNext,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final GroupType selectedType;
  final ValueChanged<GroupType> onTypeChanged;
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
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.x2l),
                    _WelcomeIcon(type: selectedType),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      '¡Bienvenido a HomeTasks!',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Crea tu primer grupo para empezar a organizar tareas.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Selector de tipo de grupo ────────────────────────────────
                    _GroupTypeSelector(
                      selected: selectedType,
                      onChanged: onTypeChanged,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Nombre del grupo ─────────────────────────────────────────
                    TextFormField(
                      controller: controller,
                      autofocus: false,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: selectedType.namePlaceholder,
                        prefixIcon: Icon(selectedType.icon),
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
                          return 'Ingresa un nombre para tu grupo';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.x2l),
                  ],
                ),
              ),
            ),
            _PrimaryButton(label: 'Continuar', onTap: onNext),
            const SizedBox(height: AppSpacing.x2l),
          ],
        ),
      ),
    );
  }
}

class _GroupTypeSelector extends StatelessWidget {
  const _GroupTypeSelector({required this.selected, required this.onChanged});

  final GroupType selected;
  final ValueChanged<GroupType> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children:
            GroupType.values.map((type) {
              final isSelected = type == selected;
              return GestureDetector(
                onTap: () => onChanged(type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 72,
                  margin: const EdgeInsets.only(right: AppSpacing.sm),
                  decoration: BoxDecoration(
                    gradient:
                        isSelected
                            ? const LinearGradient(
                              colors: [
                                AppColors.indigo500,
                                AppColors.violet600,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                            : null,
                    color:
                        isSelected
                            ? null
                            : Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                    borderRadius: AppRadius.card,
                    border:
                        isSelected
                            ? null
                            : Border.all(color: AppColors.cardDarkBorder),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        type.icon,
                        size: 28,
                        color: isSelected ? Colors.white : null,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        type.label,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color:
                              isSelected
                                  ? Colors.white
                                  : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}

class _WelcomeIcon extends StatelessWidget {
  const _WelcomeIcon({required this.type});

  final GroupType type;

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
              color: AppColors.indigo500.withValues(alpha: 0.4),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(child: Icon(type.icon, size: 40, color: Colors.white)),
      ),
    );
  }
}

// ── Paso 2: agregar miembros ─────────────────────────────────────────────────

class _Step2MembersPage extends StatelessWidget {
  const _Step2MembersPage({required this.groupId, required this.onFinish});

  final String groupId;
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
          Text(
            '¿Quiénes participan?',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Ya estás incluido como miembro. Agrega a las demás personas que participarán.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          // Lista reactiva de miembros del grupo.
          Expanded(
            child: ValueListenableBuilder<List<FamilyMember>>(
              valueListenable: MemberService.instance.membersNotifier,
              builder: (context, allMembers, _) {
                final members =
                    allMembers.where((m) => m.groupId == groupId).toList();
                return ListView.separated(
                  itemCount: members.length,
                  separatorBuilder:
                      (_, __) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder:
                      (context, i) => _OnboardingMemberTile(member: members[i]),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: () => showCreateMemberSheet(context, groupId: groupId),
            icon: const Icon(Icons.person_add_outlined),
            label: const Text('Agregar otro miembro'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              side: const BorderSide(color: AppColors.indigo500),
              foregroundColor: AppColors.indigo400,
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _PrimaryButton(label: 'Comenzar', onTap: onFinish),
          const SizedBox(height: AppSpacing.x2l),
        ],
      ),
    );
  }
}

class _OnboardingMemberTile extends StatelessWidget {
  const _OnboardingMemberTile({required this.member});

  final FamilyMember member;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: member.avatarColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: member.avatarColor, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(
              member.initial,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: member.avatarColor,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              member.displayName,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Icon(Icons.check_circle_rounded, size: 20, color: member.avatarColor),
        ],
      ),
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
              color: AppColors.indigo500.withValues(alpha: 0.45),
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

// ── Extensiones de conveniencia para GroupType ────────────────────────────────

extension _GroupTypeUI on GroupType {
  String get namePlaceholder => switch (this) {
    GroupType.home => 'Ej: Casa García, Nido Familiar...',
    GroupType.work => 'Ej: Equipo Alpha, Marketing...',
    GroupType.friends => 'Ej: Los del barrio, Squad...',
    GroupType.school => 'Ej: Clase 3B, Proyecto Final...',
    GroupType.other => 'Ej: Mi grupo...',
  };
}
