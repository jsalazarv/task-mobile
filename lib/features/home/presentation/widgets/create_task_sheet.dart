import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hometasks/l10n/generated/app_localizations.dart';
import 'package:hometasks/core/models/task_category_model.dart';
import 'package:hometasks/core/services/group_service.dart';
import 'package:hometasks/core/services/member_service.dart';
import 'package:hometasks/core/services/task_service.dart';
import 'package:hometasks/core/settings/app_settings_cubit.dart';
import 'package:hometasks/core/theme/app_colors.dart';
import 'package:hometasks/core/theme/app_theme.dart';
import 'package:hometasks/features/home/presentation/widgets/assignee_picker_sheet.dart';
import 'package:hometasks/features/home/presentation/widgets/member_mock_data.dart';
import 'package:hometasks/features/home/presentation/widgets/task_mock_data.dart';

/// Abre el sheet para crear una tarea nueva en [date].
void showCreateTaskSheet(BuildContext context, {DateTime? date}) {
  final groupId = context.read<AppSettingsCubit>().state.activeGroupId ?? '';
  _openTaskFormSheet(context, date: date ?? DateTime.now(), groupId: groupId);
}

/// Abre el sheet para editar [task] existente.
void showEditTaskSheet(BuildContext context, Task task) {
  _openTaskFormSheet(
    context,
    existing: task,
    date: task.date,
    groupId: task.groupId,
  );
}

void _openTaskFormSheet(
  BuildContext context, {
  required DateTime date,
  required String groupId,
  Task? existing,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.transparent,
    builder:
        (ctx) => _BlurOverlay(
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.85,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            snap: true,
            snapSizes: const [0.85, 0.95],
            builder:
                (_, scrollController) => _TaskFormSheet(
                  date: date,
                  groupId: groupId,
                  existing: existing,
                  scrollController: scrollController,
                ),
          ),
        ),
  );
}

class _BlurOverlay extends StatelessWidget {
  const _BlurOverlay({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          // Solo registra onTap para cerrar — no declara handlers de drag para
          // que el BottomSheet nativo pueda ganar la arena de gestos verticales.
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: Colors.black.withOpacity(0.25)),
            ),
          ),
        ),
        Align(alignment: Alignment.bottomCenter, child: child),
      ],
    );
  }
}

class _TaskFormSheet extends StatefulWidget {
  const _TaskFormSheet({
    required this.date,
    required this.groupId,
    required this.scrollController,
    this.existing,
  });

  final DateTime date;
  final String groupId;
  final Task? existing;
  final ScrollController scrollController;

  @override
  State<_TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<_TaskFormSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _timeCtrl;
  late TaskCategoryModel? _category;
  late FamilyMember? _assignee;
  late DateTime _date;
  late int _xpValue;

  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final t = widget.existing;
    _titleCtrl = TextEditingController(text: t?.title ?? '');
    _descCtrl = TextEditingController(text: t?.description ?? '');
    _timeCtrl = TextEditingController(text: t?.time ?? '');
    _category = t != null ? TaskService.instance.resolveCategory(t) : null;
    _date = t?.date ?? widget.date;
    _xpValue = t?.xpValue ?? 10;

    // Resuelve el FamilyMember del assigneeId existente.
    final members = MemberService.instance.members;
    _assignee =
        t?.assigneeId == null
            ? null
            : members.where((m) => m.id == t!.assigneeId).firstOrNull;

    _titleCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit => _titleCtrl.text.trim().isNotEmpty && _category != null;

  Future<void> _submit() async {
    if (!_canSubmit || _saving) return;
    setState(() => _saving = true);

    if (_isEditing) {
      final updated = widget.existing!.copyWith(
        title: _titleCtrl.text.trim(),
        description:
            _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        time: _timeCtrl.text.isEmpty ? null : _timeCtrl.text,
        categoryId: _category!.id,
        date: _date,
        assigneeId: _assignee?.id,
        clearAssignee: _assignee == null,
        xpValue: _xpValue,
      );
      await TaskService.instance.update(updated);
    } else {
      final task = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleCtrl.text.trim(),
        description:
            _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        time: _timeCtrl.text.isEmpty ? null : _timeCtrl.text,
        categoryId: _category!.id,
        date: _date,
        groupId: widget.groupId,
        assigneeId: _assignee?.id,
        xpValue: _xpValue,
      );
      await TaskService.instance.add(task);
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.x2l,
          AppSpacing.x2l,
          AppSpacing.x2l,
          keyboardHeight > 0
              ? keyboardHeight + AppSpacing.lg
              : bottomSafe + AppSpacing.x2l,
        ),
        child: SingleChildScrollView(
          // El scrollController del DraggableScrollableSheet coordina el scroll
          // interno con el drag del sheet: cuando el scroll llega al tope,
          // el gesto pasa al sheet para que lo cierre con swipe-down.
          controller: widget.scrollController,
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetHeader(
                isEditing: _isEditing,
                onClose: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: AppSpacing.x2l),

              _SectionLabel(label: l10n.taskFieldLabel),
              const SizedBox(height: AppSpacing.sm),
              _TaskField(controller: _titleCtrl, hint: l10n.taskFieldHint),
              const SizedBox(height: AppSpacing.lg),

              _SectionLabel(
                label: l10n.descFieldLabel,
                suffix: l10n.descFieldOptional,
              ),
              const SizedBox(height: AppSpacing.sm),
              _DescriptionField(
                controller: _descCtrl,
                hint: l10n.descFieldHint,
              ),
              const SizedBox(height: AppSpacing.lg),

              _SectionLabel(label: l10n.categoryLabel),
              const SizedBox(height: AppSpacing.md),
              _CategoryGrid(
                groupId: widget.groupId,
                selected: _category,
                onSelected: (cat) => setState(() => _category = cat),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Hora + Fecha
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionLabel(label: l10n.timeLabel),
                        const SizedBox(height: AppSpacing.sm),
                        _TimeField(controller: _timeCtrl),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionLabel(label: 'FECHA'),
                        const SizedBox(height: AppSpacing.sm),
                        _DateField(date: _date, onTap: _pickDate),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Responsable + XP
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionLabel(label: l10n.assigneeLabel),
                        const SizedBox(height: AppSpacing.sm),
                        _AssigneePicker(
                          selected: _assignee,
                          hint: l10n.assigneeHint,
                          onTap: () async {
                            final picked = await showAssigneePickerSheet(
                              context,
                              groupId: widget.groupId,
                            );
                            if (picked != null) {
                              setState(() => _assignee = picked);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionLabel(label: 'XP'),
                        const SizedBox(height: AppSpacing.sm),
                        _XpPicker(
                          value: _xpValue,
                          onChanged: (v) => setState(() => _xpValue = v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.x2l),

              _SubmitButton(
                label: _isEditing ? 'Guardar cambios' : l10n.addTask,
                enabled: _canSubmit,
                saving: _saving,
                onPressed: () => _submit(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────────

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.isEditing, required this.onClose});

  final bool isEditing;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Editar tarea' : l10n.newTask,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                isEditing
                    ? 'Modifica los detalles de la tarea'
                    : l10n.localeName == 'en'
                    ? 'Today'
                    : 'Hoy',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onClose,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, size: 18),
          ),
        ),
      ],
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

class _TaskField extends StatefulWidget {
  const _TaskField({required this.controller, required this.hint});
  final TextEditingController controller;
  final String hint;

  @override
  State<_TaskField> createState() => _TaskFieldState();
}

class _TaskFieldState extends State<_TaskField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      textInputAction: TextInputAction.next,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: _inputDecoration(context, widget.hint),
    );
  }
}

class _DescriptionField extends StatelessWidget {
  const _DescriptionField({required this.controller, required this.hint});
  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 3,
      minLines: 3,
      textInputAction: TextInputAction.newline,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: _inputDecoration(context, hint),
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: true,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: _inputDecoration(context, '--:-- --').copyWith(
        suffixIcon: Icon(
          Icons.access_time_outlined,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (picked != null) {
          final h = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
          final m = picked.minute.toString().padLeft(2, '0');
          final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
          controller.text = '$h:$m $period';
        }
      },
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.date, required this.onTap});

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final label = '${date.day}/${date.month}/${date.year}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: AppRadius.card,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ),
            Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: cs.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _AssigneePicker extends StatelessWidget {
  const _AssigneePicker({
    required this.selected,
    required this.hint,
    required this.onTap,
  });

  final FamilyMember? selected;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: AppRadius.card,
        ),
        child: Row(
          children: [
            if (selected != null) ...[
              _MiniAvatar(member: selected!),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  selected!.displayName,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ] else
              Expanded(
                child: Text(
                  hint,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
            Icon(Icons.expand_more, size: 18, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _MiniAvatar extends StatelessWidget {
  const _MiniAvatar({required this.member});

  final FamilyMember member;

  @override
  Widget build(BuildContext context) {
    const size = 26.0;
    final imagePath = member.avatarImagePath;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: member.avatarColor.withOpacity(0.25),
        shape: BoxShape.circle,
        border: Border.all(color: member.avatarColor, width: 1.5),
        image:
            imagePath != null
                ? DecorationImage(
                  image: FileImage(File(imagePath)),
                  fit: BoxFit.cover,
                )
                : null,
      ),
      alignment: Alignment.center,
      child:
          imagePath == null
              ? Text(
                member.initial,
                style: TextStyle(
                  fontSize: size * 0.42,
                  fontWeight: FontWeight.w800,
                  color: member.avatarColor,
                ),
              )
              : null,
    );
  }
}

// ── XP Picker ─────────────────────────────────────────────────────────────────

class _XpPicker extends StatelessWidget {
  const _XpPicker({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  static const _values = [5, 10, 15, 20, 25, 30, 40, 50, 75, 100];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: AppRadius.card,
      ),
      child: Row(
        children: [
          // Botón decrementar
          _XpArrow(
            icon: Icons.remove,
            onTap: () {
              final idx = _values.indexOf(value);
              if (idx > 0) onChanged(_values[idx - 1]);
            },
          ),
          // Valor central
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback:
                      (b) => const LinearGradient(
                        colors: [AppColors.xpGold, AppColors.streakOrange],
                      ).createShader(b),
                  blendMode: BlendMode.srcIn,
                  child: const Icon(Icons.bolt, size: 14, color: Colors.white),
                ),
                const SizedBox(width: 3),
                Text(
                  '$value',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.xpGold,
                  ),
                ),
              ],
            ),
          ),
          // Botón incrementar
          _XpArrow(
            icon: Icons.add,
            onTap: () {
              final idx = _values.indexOf(value);
              if (idx < _values.length - 1) onChanged(_values[idx + 1]);
            },
          ),
        ],
      ),
    );
  }
}

class _XpArrow extends StatelessWidget {
  const _XpArrow({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

// ── Category grid ─────────────────────────────────────────────────────────────

InputDecoration _inputDecoration(BuildContext context, String hint) {
  final cs = Theme.of(context).colorScheme;
  return InputDecoration(
    hintText: hint,
    hintStyle: Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
    filled: true,
    fillColor: cs.surfaceContainerHighest,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.md,
    ),
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
  );
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.groupId,
    required this.selected,
    required this.onSelected,
  });

  final String groupId;
  final TaskCategoryModel? selected;
  final ValueChanged<TaskCategoryModel> onSelected;

  @override
  Widget build(BuildContext context) {
    final group = GroupService.instance.findById(groupId);
    final categories = group?.categories ?? DefaultCategories.all;

    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: AppSpacing.sm,
      mainAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children:
          categories.map((cat) {
            final isSelected = cat.id == selected?.id;
            return _CategoryCell(
              category: cat,
              isSelected: isSelected,
              onTap: () => onSelected(cat),
            );
          }).toList(),
    );
  }
}

class _CategoryCell extends StatelessWidget {
  const _CategoryCell({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final TaskCategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: AppRadius.card,
          border:
              isSelected
                  ? Border.all(color: cs.primary, width: 1.5)
                  : Border.all(color: Colors.transparent, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              category.icon,
              size: 26,
              color: isSelected ? cs.primary : cs.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              category.name,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: cs.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
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
                          color: AppColors.indigo500.withOpacity(0.55),
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
                        color: AppColors.white,
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
