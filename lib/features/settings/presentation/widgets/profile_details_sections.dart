import 'package:jobfy/core/theme/build_context_x.dart';
import 'package:jobfy/features/user/domain/entities/user_profile_entity.dart';
import 'package:jobfy/features/user/presentation/user_labels.dart';
import 'package:jobfy/features/user/presentation/widgets/experience_dialog.dart';
import 'package:jobfy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// The user's skills as chips (tap the x to remove), and a row to add one
/// with its level. Adding a skill the user already has changes its level.
class SkillsEditor extends StatefulWidget {
  final List<UserSkillEntity> skills;
  final bool isBusy;
  final Future<void> Function(String name, SkillLevel level) onAdd;
  final Future<void> Function(String name) onRemove;

  const SkillsEditor({
    super.key,
    required this.skills,
    required this.isBusy,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<SkillsEditor> createState() => _SkillsEditorState();
}

class _SkillsEditorState extends State<SkillsEditor> {
  final _nameController = TextEditingController();
  SkillLevel _level = SkillLevel.beginner;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || widget.isBusy) return;
    _nameController.clear();
    await widget.onAdd(name, _level);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 14,
      children: [
        if (widget.skills.isEmpty)
          Text(l10n.noSkillsYet, style: TextStyle(fontSize: 13, color: colors.textMuted))
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final skill in widget.skills)
                InputChip(
                  label: Text('${skill.name} · ${l10n.skillLevel(skill.level)}',
                      style: const TextStyle(fontSize: 12)),
                  visualDensity: VisualDensity.compact,
                  deleteButtonTooltipMessage: l10n.settingsRemove,
                  onDeleted: widget.isBusy ? null : () => widget.onRemove(skill.name),
                ),
            ],
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 220,
              child: TextField(
                controller: _nameController,
                maxLength: 80,
                onSubmitted: (_) => _add(),
                decoration: InputDecoration(
                  hintText: l10n.otherSkillHint,
                  isDense: true,
                  counterText: '',
                ),
              ),
            ),
            DropdownButton<SkillLevel>(
              value: _level,
              isDense: true,
              underline: const SizedBox.shrink(),
              onChanged: (v) => setState(() => _level = v!),
              items: [
                for (final level in SkillLevel.values)
                  DropdownMenuItem(
                    value: level,
                    child: Text(l10n.skillLevel(level), style: const TextStyle(fontSize: 13)),
                  ),
              ],
            ),
            TextButton.icon(
              onPressed: widget.isBusy ? null : _add,
              icon: const Icon(Icons.add, size: 16),
              label: Text(l10n.addSkill),
            ),
          ],
        ),
      ],
    );
  }
}

/// The user's experiences, each with a delete button, and the button that
/// opens the form to add one.
class ExperiencesEditor extends StatelessWidget {
  final List<ExperienceEntity> experiences;
  final bool isBusy;
  final Future<void> Function(ExperienceEntity experience) onAdd;
  final Future<void> Function(String experienceId) onDelete;

  const ExperiencesEditor({
    super.key,
    required this.experiences,
    required this.isBusy,
    required this.onAdd,
    required this.onDelete,
  });

  Future<void> _openForm(BuildContext context) async {
    final experience = await showDialog<ExperienceEntity>(
      context: context,
      builder: (_) => const ExperienceDialog(),
    );
    if (experience != null) await onAdd(experience);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        if (experiences.isEmpty)
          Text(l10n.noExperiencesYet, style: TextStyle(fontSize: 13, color: colors.textMuted)),
        for (final exp in experiences)
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.surfaceBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exp.jobTitle,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                      Text(
                        '${exp.companyName} · ${formatMonthYear(exp.startDate)} – '
                        '${exp.endDate == null ? l10n.experiencePresent : formatMonthYear(exp.endDate!)}',
                        style: TextStyle(fontSize: 12, color: colors.textMuted),
                      ),
                    ],
                  ),
                ),
                if (exp.id != null)
                  IconButton(
                    tooltip: l10n.settingsRemove,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    onPressed: isBusy ? null : () => onDelete(exp.id!),
                  ),
              ],
            ),
          ),
        OutlinedButton.icon(
          onPressed: isBusy ? null : () => _openForm(context),
          icon: const Icon(Icons.add, size: 16),
          label: Text(l10n.addExperience),
        ),
      ],
    );
  }
}
