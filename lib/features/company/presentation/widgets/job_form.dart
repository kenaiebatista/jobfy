import 'package:jobfy/core/theme/app_breakpoints.dart';
import 'package:jobfy/core/theme/build_context_x.dart';
import 'package:jobfy/features/company/domain/entities/company_entity.dart';
import 'package:jobfy/features/company/presentation/company_labels.dart';
import 'package:jobfy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The job form (the `jobs` columns), used to publish a new job and, with
/// [initial], to edit an existing one.
class JobForm extends StatefulWidget {
  final String companyId;

  /// The job being edited; null for a new job.
  final JobEntity? initial;
  final String submitLabel;
  final bool isBusy;

  /// Message shown above the button, e.g. the last save error.
  final String? errorText;

  /// Saves the job. The form clears itself after a successful publish (not
  /// after an edit, where the dialog closes).
  final Future<bool> Function(NewJobEntity job) onSubmit;

  const JobForm({
    super.key,
    required this.companyId,
    this.initial,
    required this.submitLabel,
    required this.onSubmit,
    this.isBusy = false,
    this.errorText,
  });

  @override
  State<JobForm> createState() => _JobFormState();
}

class _JobFormState extends State<JobForm> {
  final _formKey = GlobalKey<FormState>();
  late final _titleController = TextEditingController(text: widget.initial?.title);
  late final _areaController = TextEditingController(text: widget.initial?.area);
  late final _descriptionController = TextEditingController(text: widget.initial?.description);
  late final _locationController = TextEditingController(text: widget.initial?.location);
  late final _salaryMinController = TextEditingController(text: widget.initial?.salaryMin?.toString());
  late final _salaryMaxController = TextEditingController(text: widget.initial?.salaryMax?.toString());
  late final _workloadController = TextEditingController(text: widget.initial?.workload);
  late final _requirementsController = TextEditingController(text: widget.initial?.requirements);
  late final _benefitsController = TextEditingController(text: widget.initial?.benefits);
  late WorkMode? _workMode = _workModeOf(widget.initial?.workMode);
  late ContractType? _contractType = ContractType.fromDb(widget.initial?.contractType);

  static WorkMode? _workModeOf(String? dbValue) {
    for (final mode in WorkMode.values) {
      if (mode.dbValue == dbValue) return mode;
    }
    return null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _areaController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    _workloadController.dispose();
    _requirementsController.dispose();
    _benefitsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await widget.onSubmit(NewJobEntity(
      companyId: widget.companyId,
      title: _titleController.text.trim(),
      area: _areaController.text.trim(),
      location: _locationController.text.trim(),
      workMode: _workMode!,
      description: _descriptionController.text.trim(),
      contractType: _contractType!,
      salaryMin: int.parse(_salaryMinController.text),
      salaryMax: int.parse(_salaryMaxController.text),
      workload: _workloadController.text,
      requirements: _requirementsController.text,
      benefits: _benefitsController.text,
    ));
    if (!ok || !mounted || widget.initial != null) return;

    _formKey.currentState!.reset();
    setState(() {
      _workMode = null;
      _contractType = null;
    });
  }

  String? _required(AppLocalizations l10n, String? value) =>
      value == null || value.trim().isEmpty ? l10n.fieldRequired : null;

  /// Side by side from tablet up; stacked on phones.
  Widget _fieldPair(BuildContext context, Widget first, Widget second) {
    return Flex(
      direction: context.isMobile ? Axis.vertical : Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        for (final field in [first, second])
          context.isMobile ? field : Expanded(child: field),
      ],
    );
  }

  /// Whole reais only: 8 digits is the most `jobs.salary_*` (DECIMAL(10,2)) holds.
  Widget _salaryField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(8),
      ],
      decoration: InputDecoration(labelText: label),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          TextFormField(
            controller: _titleController,
            maxLength: 150,
            decoration: InputDecoration(
              labelText: l10n.jobTitleLabel,
              hintText: l10n.jobTitleHint,
              counterText: '',
            ),
            validator: (v) => _required(l10n, v),
          ),
          _fieldPair(
            context,
            TextFormField(
              controller: _areaController,
              maxLength: 80,
              decoration: InputDecoration(
                labelText: l10n.jobAreaLabel,
                hintText: l10n.jobAreaHint,
                counterText: '',
              ),
            ),
            TextFormField(
              controller: _locationController,
              maxLength: 100,
              decoration: InputDecoration(
                labelText: l10n.jobLocationLabel,
                hintText: l10n.jobLocationHint,
                counterText: '',
              ),
              validator: (v) => _required(l10n, v),
            ),
          ),
          _fieldPair(
            context,
            DropdownButtonFormField<WorkMode>(
              initialValue: _workMode,
              isExpanded: true,
              onChanged: (v) => setState(() => _workMode = v),
              decoration: InputDecoration(labelText: l10n.jobWorkModeLabel),
              items: [
                for (final mode in WorkMode.values)
                  DropdownMenuItem(value: mode, child: Text(l10n.workMode(mode))),
              ],
              validator: (v) => v == null ? l10n.fieldRequired : null,
            ),
            DropdownButtonFormField<ContractType>(
              initialValue: _contractType,
              isExpanded: true,
              onChanged: (v) => setState(() => _contractType = v),
              decoration: InputDecoration(labelText: l10n.jobContractTypeLabel),
              items: [
                for (final type in ContractType.values)
                  DropdownMenuItem(value: type, child: Text(l10n.contractType(type))),
              ],
              validator: (v) => v == null ? l10n.fieldRequired : null,
            ),
          ),
          _fieldPair(
            context,
            _salaryField(
              controller: _salaryMinController,
              label: l10n.jobSalaryMinLabel,
              validator: (v) => _required(l10n, v),
            ),
            _salaryField(
              controller: _salaryMaxController,
              label: l10n.jobSalaryMaxLabel,
              validator: (v) {
                final min = int.tryParse(_salaryMinController.text);
                final max = int.tryParse(v ?? '');
                if (max == null) return l10n.fieldRequired;
                return min != null && max < min ? l10n.jobSalaryRangeError : null;
              },
            ),
          ),
          TextFormField(
            controller: _workloadController,
            maxLength: 60,
            decoration: InputDecoration(
              labelText: l10n.jobWorkloadLabel,
              hintText: l10n.jobWorkloadHint,
              counterText: '',
            ),
          ),
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l10n.jobDescriptionLabel,
              hintText: l10n.jobDescriptionHint,
            ),
            validator: (v) => _required(l10n, v),
          ),
          TextFormField(
            controller: _requirementsController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l10n.jobRequirementsLabel,
              hintText: l10n.jobRequirementsHint,
            ),
          ),
          TextFormField(
            controller: _benefitsController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: l10n.jobBenefitsLabel,
              hintText: l10n.jobBenefitsHint,
            ),
          ),
          if (widget.errorText != null)
            Text(widget.errorText!, style: TextStyle(color: colors.danger, fontSize: 13)),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: widget.isBusy ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.accent,
                foregroundColor: colors.onAccent,
              ),
              child: Text(widget.submitLabel),
            ),
          ),
        ],
      ),
    );
  }
}
