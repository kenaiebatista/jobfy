import 'package:jobfy/core/theme/build_context_x.dart';
import 'package:jobfy/features/user/domain/entities/user_profile_entity.dart';
import 'package:jobfy/features/user/presentation/user_labels.dart';
import 'package:jobfy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Form for one row of `experiences`. Pops with the [ExperienceEntity], or
/// null if cancelled.
class ExperienceDialog extends StatefulWidget {
  const ExperienceDialog({super.key});

  @override
  State<ExperienceDialog> createState() => _ExperienceDialogState();
}

class _ExperienceDialogState extends State<ExperienceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _start;
  DateTime? _end;
  bool _current = false;
  String? _dateError;

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<DateTime?> _pick(DateTime? initial) => showDatePicker(
        context: context,
        initialDate: initial ?? DateTime.now(),
        firstDate: DateTime(1950),
        lastDate: DateTime.now(),
      );

  void _save(AppLocalizations l10n) {
    final fieldsOk = _formKey.currentState!.validate();
    setState(() {
      _dateError = _start == null
          ? l10n.fieldRequired
          : (!_current && _end != null && _end!.isBefore(_start!))
              ? l10n.experienceDatesInvalid
              : null;
    });
    if (!fieldsOk || _dateError != null) return;

    final description = _descriptionController.text.trim();
    Navigator.pop(
      context,
      ExperienceEntity(
        jobTitle: _titleController.text.trim(),
        companyName: _companyController.text.trim(),
        description: description.isEmpty ? null : description,
        startDate: _start!,
        endDate: _current ? null : _end,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    String? required(String? v) =>
        (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null;

    return AlertDialog(
      title: Text(l10n.addExperience),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 12,
              children: [
                TextFormField(
                  controller: _titleController,
                  validator: required,
                  decoration: InputDecoration(labelText: l10n.experienceJobTitleLabel),
                ),
                TextFormField(
                  controller: _companyController,
                  validator: required,
                  decoration: InputDecoration(labelText: l10n.experienceCompanyLabel),
                ),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: '${l10n.experienceDescriptionLabel} ${l10n.optionalSuffix}',
                  ),
                ),
                Row(
                  spacing: 12,
                  children: [
                    Expanded(
                      child: _DateField(
                        label: l10n.experienceStartLabel,
                        value: _start,
                        onTap: () async {
                          final d = await _pick(_start);
                          if (d != null) setState(() => _start = d);
                        },
                      ),
                    ),
                    Expanded(
                      child: _DateField(
                        label: l10n.experienceEndLabel,
                        value: _current ? null : _end,
                        placeholder: _current ? l10n.experiencePresent : null,
                        onTap: _current
                            ? null
                            : () async {
                                final d = await _pick(_end ?? _start);
                                if (d != null) setState(() => _end = d);
                              },
                      ),
                    ),
                  ],
                ),
                CheckboxListTile(
                  value: _current,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(l10n.experienceCurrentJob, style: const TextStyle(fontSize: 13)),
                  onChanged: (v) => setState(() => _current = v!),
                ),
                if (_dateError != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _dateError!,
                      style: TextStyle(fontSize: 12, color: context.colors.danger),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.dialogCancel),
        ),
        ElevatedButton(
          onPressed: () => _save(l10n),
          child: Text(l10n.dialogAdd),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final String? placeholder;
  final VoidCallback? onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today_outlined, size: 16),
          enabled: onTap != null,
        ),
        child: Text(value == null ? (placeholder ?? '') : formatMonthYear(value!)),
      ),
    );
  }
}
