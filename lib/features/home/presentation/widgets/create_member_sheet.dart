import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hometasks/core/services/member_service.dart';
import 'package:hometasks/core/theme/app_colors.dart';
import 'package:hometasks/core/theme/app_theme.dart';
import 'package:hometasks/features/home/presentation/widgets/member_mock_data.dart';
import 'package:image_picker/image_picker.dart';

void showCreateMemberSheet(BuildContext context) {
  _openMemberFormSheet(context);
}

void showEditMemberSheet(BuildContext context, FamilyMember member) {
  _openMemberFormSheet(context, existing: member);
}

void _openMemberFormSheet(BuildContext context, {FamilyMember? existing}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.transparent,
    builder: (_) => _BlurOverlay(child: _CreateMemberSheet(existing: existing)),
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
          // Listener en lugar de GestureDetector: no participa en la arena de
          // gestos, por lo que el drag nativo del ModalBottomSheet recibe los
          // eventos verticales y el swipe-down para cerrar funciona correctamente.
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerUp: (_) => Navigator.of(context).pop(),
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

class _CreateMemberSheet extends StatefulWidget {
  const _CreateMemberSheet({this.existing});

  final FamilyMember? existing;

  @override
  State<_CreateMemberSheet> createState() => _CreateMemberSheetState();
}

class _CreateMemberSheetState extends State<_CreateMemberSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _nicknameController;
  late Color _selectedColor;
  String? _avatarImagePath;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameController = TextEditingController(text: e?.name ?? '');
    _nicknameController = TextEditingController(text: e?.nickname ?? '');
    _selectedColor = e?.avatarColor ?? kAvatarColors.first;
    _avatarImagePath = e?.avatarImagePath;
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  bool get _canSave => _nameController.text.trim().isNotEmpty;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() => _avatarImagePath = picked.path);
  }

  Future<void> _save() async {
    if (!_canSave || _saving) return;
    setState(() => _saving = true);

    final name = _nameController.text.trim();
    final nickname = _nicknameController.text.trim().isEmpty
        ? null
        : _nicknameController.text.trim();

    if (_isEditing) {
      final updated = widget.existing!.copyWith(
        name: name,
        nickname: nickname,
        avatarColor: _selectedColor,
        avatarImagePath: _avatarImagePath,
      );
      await MemberService.instance.update(updated);
    } else {
      final member = FamilyMember(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        nickname: nickname,
        avatarColor: _selectedColor,
        avatarImagePath: _avatarImagePath,
      );
      await MemberService.instance.add(member);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                isEditing: _isEditing,
                onClose: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: AppSpacing.x2l),

              // ── Avatar preview + pick imagen ────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: _AvatarPreview(
                    name: _nameController.text.trim(),
                    color: _selectedColor,
                    imagePath: _avatarImagePath,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Nombre ──────────────────────────────────────────────────
              _SectionLabel(label: 'NOMBRE'),
              const SizedBox(height: AppSpacing.sm),
              _Field(
                controller: _nameController,
                hint: 'Ej. Laura',
                onChanged: (_) => setState(() {}),
                maxLength: 30,
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Apodo (opcional) ────────────────────────────────────────
              _SectionLabel(label: 'APODO', suffix: '(opcional)'),
              const SizedBox(height: AppSpacing.sm),
              _Field(
                controller: _nicknameController,
                hint: 'Ej. Lau',
                maxLength: 20,
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Selector de color ───────────────────────────────────────
              _SectionLabel(label: 'COLOR DE AVATAR'),
              const SizedBox(height: AppSpacing.md),
              _ColorPicker(
                selected: _selectedColor,
                onSelected: (c) => setState(() => _selectedColor = c),
              ),
              const SizedBox(height: AppSpacing.x2l),

              // ── Botón guardar ───────────────────────────────────────────
              _SaveButton(
                label: _isEditing ? 'Guardar cambios' : 'Guardar miembro',
                enabled: _canSave,
                saving: _saving,
                onPressed: _save,
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Editar miembro' : 'Nuevo miembro',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                isEditing
                    ? 'Modifica los datos del miembro'
                    : 'Agrega un integrante a tu hogar',
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

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    this.onChanged,
    this.maxLength,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.next,
      style: Theme.of(context).textTheme.bodyMedium,
      inputFormatters: [
        if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
      ],
      decoration: InputDecoration(
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
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _AvatarPreview extends StatelessWidget {
  const _AvatarPreview({
    required this.name,
    required this.color,
    this.imagePath,
  });

  final String name;
  final Color color;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    const size = 80.0;

    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withOpacity(0.25),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2.5),
            image: imagePath != null
                ? DecorationImage(
                    image: FileImage(File(imagePath!)),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          alignment: Alignment.center,
          child: imagePath == null
              ? Text(
                  name.isEmpty ? '?' : name[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: size * 0.38,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                )
              : null,
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.surface,
                width: 2,
              ),
            ),
            child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
          ),
        ),
      ],
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
      children: kAvatarColors.map((color) {
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
              border: isSelected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: 3,
                    )
                  : null,
              boxShadow: isSelected
                  ? [BoxShadow(color: color.withOpacity(0.6), blurRadius: 8)]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, size: 18, color: Colors.white)
                : null,
          ),
        );
      }).toList(),
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
              boxShadow: enabled
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
            child: saving
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
