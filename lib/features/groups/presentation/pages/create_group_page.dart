import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hometasks/core/models/group.dart';
import 'package:hometasks/core/models/task_category_model.dart';
import 'package:hometasks/core/services/group_service.dart';
import 'package:hometasks/core/services/member_service.dart';
import 'package:hometasks/core/settings/app_settings_cubit.dart';
import 'package:hometasks/core/theme/app_colors.dart';
import 'package:hometasks/core/theme/app_theme.dart';
import 'package:hometasks/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:hometasks/features/auth/presentation/bloc/auth_state.dart';
import 'package:hometasks/features/groups/presentation/widgets/category_editor_sheet.dart';

const int kMaxGroupCategories = 6;

// ── Pantalla de creación ──────────────────────────────────────────────────────

/// Pantalla para crear un nuevo grupo.
class CreateGroupPage extends StatelessWidget {
  const CreateGroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _GroupFormPage(
      title: 'Nuevo grupo',
      saveLabel: 'Crear grupo',
      onSave: (group) async {
        await GroupService.instance.add(group);

        // Agregar al usuario logueado como miembro inicial del grupo.
        if (context.mounted) {
          final authState = context.read<AuthBloc>().state;
          if (authState is AuthAuthenticated) {
            await MemberService.instance.addOwnerIfAbsent(
              userId: authState.user.id,
              userName: authState.user.name,
              groupId: group.id,
            );
          }
        }

        if (!context.mounted) return;
        final cubit = context.read<AppSettingsCubit>();
        if (cubit.state.activeGroupId == null) {
          await cubit.setActiveGroup(group.id);
        }
        if (!context.mounted) return;
        context.pop();
      },
    );
  }
}

// ── Pantalla de edición ───────────────────────────────────────────────────────

/// Pantalla para editar un grupo existente.
class EditGroupPage extends StatelessWidget {
  const EditGroupPage({required this.group, super.key});

  final Group group;

  @override
  Widget build(BuildContext context) {
    return _GroupFormPage(
      title: 'Editar grupo',
      saveLabel: 'Guardar cambios',
      existing: group,
      onSave: (updated) async {
        await GroupService.instance.update(updated);
        if (!context.mounted) return;
        context.pop();
      },
    );
  }
}

// ── Formulario compartido ─────────────────────────────────────────────────────

class _GroupFormPage extends StatefulWidget {
  const _GroupFormPage({
    required this.title,
    required this.saveLabel,
    required this.onSave,
    this.existing,
  });

  final String title;
  final String saveLabel;
  final Group? existing;
  final Future<void> Function(Group group) onSave;

  @override
  State<_GroupFormPage> createState() => _GroupFormPageState();
}

class _GroupFormPageState extends State<_GroupFormPage> {
  late final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(
    text: widget.existing?.name ?? '',
  );
  late final _descriptionController = TextEditingController(
    text: widget.existing?.description ?? '',
  );

  late GroupType _selectedType = widget.existing?.type ?? GroupType.home;
  late Color _selectedColor = widget.existing?.color ?? AppColors.indigo500;
  late List<TaskCategoryModel> _selectedCategories = List.of(
    widget.existing?.categories ?? DefaultCategories.all,
  );
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _canSave => _nameController.text.trim().isNotEmpty;

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false) || _saving) return;
    setState(() => _saving = true);

    final group = Group(
      id:
          widget.existing?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      description:
          _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
      type: _selectedType,
      color: _selectedColor,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
      categories: _selectedCategories,
    );

    await widget.onSave(group);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Header(title: widget.title, onBack: () => context.pop()),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.x2l,
                    vertical: AppSpacing.lg,
                  ),
                  children: [
                    // ── Tipo de grupo ────────────────────────────────────
                    _SectionLabel(label: 'TIPO DE GRUPO'),
                    const SizedBox(height: AppSpacing.md),
                    _GroupTypeSelector(
                      selected: _selectedType,
                      onChanged: (t) => setState(() => _selectedType = t),
                    ),
                    const SizedBox(height: AppSpacing.x2l),

                    // ── Nombre ───────────────────────────────────────────
                    _SectionLabel(label: 'NOMBRE DEL GRUPO'),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: _selectedType.namePlaceholder,
                        prefixIcon: Icon(_selectedType.icon),
                        filled: true,
                        fillColor: cs.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.card,
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppRadius.card,
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppRadius.card,
                          borderSide: BorderSide(color: cs.primary, width: 1.5),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Ingresa un nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Descripción (opcional) ───────────────────────────
                    _SectionLabel(label: 'DESCRIPCIÓN', suffix: '(opcional)'),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Ej: Tareas de la casa de los García',
                        filled: true,
                        fillColor: cs.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.card,
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppRadius.card,
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppRadius.card,
                          borderSide: BorderSide(color: cs.primary, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x2l),

                    // ── Color del grupo ──────────────────────────────────
                    _SectionLabel(label: 'COLOR'),
                    const SizedBox(height: AppSpacing.md),
                    _ColorPicker(
                      selected: _selectedColor,
                      onSelected: (c) => setState(() => _selectedColor = c),
                    ),
                    const SizedBox(height: AppSpacing.x2l),

                    // ── Categorías de tareas (máx 6) ─────────────────────
                    Row(
                      children: [
                        const _SectionLabel(label: 'CATEGORÍAS DE TAREAS'),
                        const Spacer(),
                        Text(
                          '${_selectedCategories.length}/$kMaxGroupCategories',
                          style: Theme.of(
                            context,
                          ).textTheme.labelSmall?.copyWith(
                            color:
                                _selectedCategories.length >=
                                        kMaxGroupCategories
                                    ? AppColors.streakOrange
                                    : cs.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Mínimo 1, máximo $kMaxGroupCategories categorías.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _CategorySelector(
                      selected: _selectedCategories,
                      onChanged:
                          (cats) => setState(() => _selectedCategories = cats),
                    ),
                    const SizedBox(height: AppSpacing.x2l),

                    // ── Botón guardar ────────────────────────────────────
                    _SaveButton(
                      label: widget.saveLabel,
                      enabled: _canSave,
                      saving: _saving,
                      onPressed: _save,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets internos ──────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, this.suffix});

  final String label;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        if (suffix != null) ...[
          const SizedBox(width: AppSpacing.xs),
          Text(
            suffix!,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _GroupTypeSelector extends StatelessWidget {
  const _GroupTypeSelector({required this.selected, required this.onChanged});

  final GroupType selected;
  final ValueChanged<GroupType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children:
          GroupType.values.map((type) {
            final isSelected = type == selected;
            return GestureDetector(
              onTap: () => onChanged(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  gradient:
                      isSelected
                          ? const LinearGradient(
                            colors: [AppColors.indigo500, AppColors.violet600],
                          )
                          : null,
                  color:
                      isSelected
                          ? null
                          : Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                  borderRadius: AppRadius.button,
                  border:
                      isSelected
                          ? null
                          : Border.all(color: AppColors.cardDarkBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      type.icon,
                      size: 16,
                      color: isSelected ? Colors.white : null,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      type.label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color:
                            isSelected
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({required this.selected, required this.onSelected});

  final Color selected;
  final ValueChanged<Color> onSelected;

  static const _colors = [
    AppColors.indigo500,
    AppColors.violet600,
    AppColors.categoryGardenFg,
    AppColors.categoryCleaningFg,
    AppColors.categoryCookingFg,
    AppColors.categoryLaundryFg,
    AppColors.streakOrange,
    AppColors.destructive,
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children:
          _colors.map((color) {
            final isSelected = color == selected;
            return GestureDetector(
              onTap: () => onSelected(color),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border:
                      isSelected
                          ? Border.all(
                            color: Theme.of(context).colorScheme.surface,
                            width: 3,
                          )
                          : null,
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.6),
                              blurRadius: 8,
                            ),
                          ]
                          : null,
                ),
                child:
                    isSelected
                        ? const Icon(Icons.check, size: 18, color: Colors.white)
                        : null,
              ),
            );
          }).toList(),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({required this.selected, required this.onChanged});

  final List<TaskCategoryModel> selected;
  final ValueChanged<List<TaskCategoryModel>> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final atMax = selected.length >= kMaxGroupCategories;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        // Lista de categorías existentes
        ...selected.map((cat) {
          return GestureDetector(
            onTap: () async {
              final edited = await showCategoryEditorSheet(
                context,
                existing: cat,
              );
              if (edited != null) {
                final updated = List<TaskCategoryModel>.from(selected);
                final idx = updated.indexWhere((c) => c.id == cat.id);
                if (idx != -1) {
                  updated[idx] = edited;
                  onChanged(updated);
                }
              }
            },
            onLongPress: () {
              if (selected.length > 1) {
                final updated = List<TaskCategoryModel>.from(selected);
                updated.removeWhere((c) => c.id == cat.id);
                onChanged(updated);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: cat.foreground.withValues(alpha: 0.15),
                borderRadius: AppRadius.button,
                border: Border.all(color: cat.foreground),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(cat.icon, size: 14, color: cat.foreground),
                  const SizedBox(width: 4),
                  Text(
                    cat.name,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: cat.foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),

        // Botón "Agregar categoría" si no está al máximo
        if (!atMax)
          GestureDetector(
            onTap: () async {
              final newCat = await showCategoryEditorSheet(context);
              if (newCat != null) {
                final updated = List<TaskCategoryModel>.from(selected);
                updated.add(newCat);
                onChanged(updated);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: AppRadius.button,
                border: Border.all(color: cs.primary, style: BorderStyle.solid),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 14, color: cs.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Agregar',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.label,
    required this.enabled,
    required this.saving,
    required this.onPressed,
  });

  final String label;
  final bool enabled;
  final bool saving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.4,
      duration: const Duration(milliseconds: 150),
      child: SizedBox(
        height: 52,
        width: double.infinity,
        child: GestureDetector(
          onTap: enabled ? onPressed : null,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.indigo500, AppColors.violet600],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: AppRadius.card,
              boxShadow:
                  enabled
                      ? [
                        BoxShadow(
                          color: AppColors.indigo500.withValues(alpha: 0.55),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ]
                      : null,
            ),
            alignment: Alignment.center,
            child:
                saving
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : Text(
                      label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}

// ── Extensiones de UI para GroupType ─────────────────────────────────────────

extension GroupTypeUI on GroupType {
  String get namePlaceholder => switch (this) {
    GroupType.home => 'Ej: Casa García, Nido Familiar...',
    GroupType.work => 'Ej: Equipo Alpha, Marketing...',
    GroupType.friends => 'Ej: Los del barrio, Squad...',
    GroupType.school => 'Ej: Clase 3B, Proyecto Final...',
    GroupType.other => 'Ej: Mi grupo...',
  };
}
