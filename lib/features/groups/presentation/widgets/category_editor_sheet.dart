import 'package:flutter/material.dart';
import 'package:hometasks/core/constants/category_icons.dart';
import 'package:hometasks/core/models/task_category_model.dart';
import 'package:hometasks/core/theme/app_colors.dart';
import 'package:hometasks/core/theme/app_theme.dart';

/// Paleta de colores predefinidos para categorías (reutiliza los tokens
/// de [AppColors] para mantener consistencia visual).
const _categoryColorPalette = [
  AppColors.categoryCleaningFg, // Azul
  AppColors.categoryCookingFg, // Naranja
  AppColors.categoryGardenFg, // Verde
  AppColors.categoryLaundryFg, // Violeta
  AppColors.categoryShoppingFg, // Rojo
  AppColors.categoryOrganizingFg, // Ámbar
  AppColors.indigo500, // Índigo
  AppColors.streakOrange, // Naranja streak
  AppColors.xpGold, // Dorado XP
  AppColors.destructive, // Rojo destructivo
];

/// Abre un bottom sheet para crear o editar una categoría.
///
/// Retorna el modelo creado/editado, o `null` si se canceló.
Future<TaskCategoryModel?> showCategoryEditorSheet(
  BuildContext context, {
  TaskCategoryModel? existing,
}) async {
  return showModalBottomSheet<TaskCategoryModel>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CategoryEditorSheet(existing: existing),
  );
}

class _CategoryEditorSheet extends StatefulWidget {
  const _CategoryEditorSheet({this.existing});

  final TaskCategoryModel? existing;

  @override
  State<_CategoryEditorSheet> createState() => _CategoryEditorSheetState();
}

class _CategoryEditorSheetState extends State<_CategoryEditorSheet> {
  late final _nameController = TextEditingController(
    text: widget.existing?.name ?? '',
  );

  late int _selectedIconCodePoint =
      widget.existing?.iconCodePoint ?? CategoryIcons.all.first.codePoint;

  late Color _selectedColor =
      widget.existing?.color ?? _categoryColorPalette.first;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _canSave => _nameController.text.trim().isNotEmpty;

  void _save() {
    if (!_canSave) return;

    final category = TaskCategoryModel(
      id:
          widget.existing?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      iconCodePoint: _selectedIconCodePoint,
      color: _selectedColor,
    );

    Navigator.of(context).pop(category);
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final bottomSafe = MediaQuery.of(context).padding.bottom;

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
              _SheetHeader(
                isEditing: widget.existing != null,
                onClose: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: AppSpacing.x2l),

              // ── Nombre de la categoría ────────────────────────────────────
              _SectionLabel(label: 'NOMBRE'),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Ej: Lavandería, Mascotas...',
                  filled: true,
                  fillColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
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
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Selector de icono ──────────────────────────────────────────
              _SectionLabel(label: 'ICONO'),
              const SizedBox(height: AppSpacing.md),
              _IconPicker(
                selected: _selectedIconCodePoint,
                onSelected: (cp) => setState(() => _selectedIconCodePoint = cp),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Selector de color ──────────────────────────────────────────
              _SectionLabel(label: 'COLOR'),
              const SizedBox(height: AppSpacing.md),
              _ColorPicker(
                selected: _selectedColor,
                onSelected: (c) => setState(() => _selectedColor = c),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Vista previa ───────────────────────────────────────────────
              _Preview(
                name: _nameController.text.trim(),
                iconCodePoint: _selectedIconCodePoint,
                color: _selectedColor,
              ),
              const SizedBox(height: AppSpacing.x2l),

              // ── Botón guardar ──────────────────────────────────────────────
              _SaveButton(enabled: _canSave, onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Widgets internos ──────────────────────────────────────────────────────────

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.isEditing, required this.onClose});

  final bool isEditing;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Editar categoría' : 'Nueva categoría',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                isEditing
                    ? 'Modifica el nombre, ícono o color'
                    : 'Define nombre, ícono y color',
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
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

class _IconPicker extends StatelessWidget {
  const _IconPicker({required this.selected, required this.onSelected});

  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: 200,
      child: GridView.count(
        crossAxisCount: 5,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        children:
            CategoryIcons.all.map((iconData) {
              final isSelected = iconData.codePoint == selected;
              return GestureDetector(
                onTap: () => onSelected(iconData.codePoint),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: AppRadius.card,
                    border:
                        isSelected
                            ? Border.all(color: cs.primary, width: 2)
                            : Border.all(color: Colors.transparent, width: 2),
                  ),
                  child: Icon(
                    iconData,
                    size: 24,
                    color: isSelected ? cs.primary : cs.onSurfaceVariant,
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({required this.selected, required this.onSelected});

  final Color selected;
  final ValueChanged<Color> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children:
          _categoryColorPalette.map((color) {
            final isSelected = color == selected;
            return GestureDetector(
              onTap: () => onSelected(color),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 40,
                height: 40,
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
                              blurRadius: 10,
                            ),
                          ]
                          : null,
                ),
                child:
                    isSelected
                        ? const Icon(Icons.check, size: 20, color: Colors.white)
                        : null,
              ),
            );
          }).toList(),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({
    required this.name,
    required this.iconCodePoint,
    required this.color,
  });

  final String name;
  final int iconCodePoint;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final displayName = name.isEmpty ? 'Vista previa' : name;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.card,
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            IconData(iconCodePoint, fontFamily: 'MaterialIcons'),
            size: 24,
            color: color,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              displayName.toUpperCase(),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.enabled, required this.onPressed});

  final bool enabled;
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
            child: Text(
              'Guardar categoría',
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
