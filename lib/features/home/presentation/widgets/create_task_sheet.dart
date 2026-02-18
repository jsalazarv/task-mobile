import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hometasks/core/theme/app_colors.dart';
import 'package:hometasks/core/theme/app_theme.dart';
import 'package:hometasks/features/home/presentation/widgets/assignee_picker_sheet.dart';
import 'package:hometasks/features/home/presentation/widgets/member_mock_data.dart';
import 'package:hometasks/features/home/presentation/widgets/task_mock_data.dart';

/// Muestra el bottom sheet de creación de tarea sobre un overlay con blur.
void showCreateTaskSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.transparent,
    builder: (_) => const _BlurOverlay(child: _CreateTaskSheet()),
  );
}

/// Overlay con blur que envuelve el sheet.
class _BlurOverlay extends StatelessWidget {
  const _BlurOverlay({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Blur sobre toda la pantalla
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: Colors.black.withOpacity(0.25)),
            ),
          ),
        ),
        // Sheet en la parte inferior
        Align(alignment: Alignment.bottomCenter, child: child),
      ],
    );
  }
}

class _CreateTaskSheet extends StatefulWidget {
  const _CreateTaskSheet();

  @override
  State<_CreateTaskSheet> createState() => _CreateTaskSheetState();
}

class _CreateTaskSheetState extends State<_CreateTaskSheet> {
  final _taskController = TextEditingController();
  final _descController = TextEditingController();
  final _timeController = TextEditingController();
  TaskCategory? _selectedCategory;
  FamilyMember? _selectedAssignee;

  @override
  void dispose() {
    _taskController.dispose();
    _descController.dispose();
    _timeController.dispose();
    super.dispose();
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetHeader(onClose: () => Navigator.of(context).pop()),
              const SizedBox(height: AppSpacing.x2l),
              _SectionLabel(label: l10n.taskFieldLabel),
              const SizedBox(height: AppSpacing.sm),
              _TaskField(controller: _taskController, hint: l10n.taskFieldHint),
              const SizedBox(height: AppSpacing.lg),
              _SectionLabel(label: l10n.descFieldLabel, suffix: l10n.descFieldOptional),
              const SizedBox(height: AppSpacing.sm),
              _DescriptionField(controller: _descController, hint: l10n.descFieldHint),
              const SizedBox(height: AppSpacing.lg),
              _SectionLabel(label: l10n.categoryLabel),
              const SizedBox(height: AppSpacing.md),
              _CategoryGrid(
                selected: _selectedCategory,
                onSelected: (cat) => setState(() => _selectedCategory = cat),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionLabel(label: l10n.timeLabel),
                        const SizedBox(height: AppSpacing.sm),
                        _TimeField(controller: _timeController),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionLabel(label: l10n.assigneeLabel),
                        const SizedBox(height: AppSpacing.sm),
                        _AssigneePicker(
                          selected: _selectedAssignee,
                          hint: l10n.assigneeHint,
                          onTap: () async {
                            final picked = await showAssigneePickerSheet(
                              context,
                            );
                            if (picked != null) {
                              setState(() => _selectedAssignee = picked);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.x2l),
              _SubmitButton(
                label: l10n.addTask,
                onPressed: _canSubmit ? _submit : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _canSubmit => _taskController.text.trim().isNotEmpty;

  void _submit() {
    Navigator.of(context).pop();
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.onClose});

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
                l10n.newTask,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                l10n.localeName == 'en' ? 'Today' : 'Hoy',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onClose,
          child: Builder(
            builder: (context) => Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 18),
            ),
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
      decoration: _inputDecoration(context, '--:-- ----').copyWith(
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
              ),
            Icon(
              Icons.expand_more,
              size: 18,
              color: cs.onSurfaceVariant,
            ),
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
        image: imagePath != null
            ? DecorationImage(
                image: FileImage(File(imagePath)),
                fit: BoxFit.cover,
              )
            : null,
      ),
      alignment: Alignment.center,
      child: imagePath == null
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

InputDecoration _inputDecoration(BuildContext context, String hint) {
  final cs = Theme.of(context).colorScheme;
  return InputDecoration(
    hintText: hint,
    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: cs.onSurfaceVariant,
        ),
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
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.primary,
        width: 1.5,
      ),
    ),
  );
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.selected,
    required this.onSelected,
  });

  final TaskCategory? selected;
  final ValueChanged<TaskCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    const categories = TaskCategory.values;

    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: AppSpacing.sm,
      mainAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: categories.map((cat) {
        final isSelected = cat == selected;
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

  final TaskCategory category;
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
          border: isSelected
              ? Border.all(color: cs.primary, width: 1.5)
              : Border.all(color: Colors.transparent, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(category.emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              category.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    // El borde (cs.primary) ya indica selección;
                    // el texto usa onSurface para garantizar legibilidad.
                    color: cs.onSurface,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return AnimatedOpacity(
      opacity: isEnabled ? 1.0 : 0.4,
      duration: const Duration(milliseconds: 150),
      child: SizedBox(
        height: 52,
        width: double.infinity,
        child: GestureDetector(
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.indigo500, AppColors.violet600],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: AppRadius.card,
              boxShadow: isEnabled
                  ? [
                      BoxShadow(
                        color: AppColors.indigo500.withOpacity(0.55),
                        blurRadius: 18,
                        spreadRadius: 0,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
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
